class User < ActiveRecord::Base

  has_many :microposts, dependent: :destroy

  # the follower has active relationships with the other users (followed)
  has_many :active_relationships, class_name:  "Relationship",
                                foreign_key: "follower_id",
                                dependent:   :destroy
  # the followed has passive relationships with users follwoing him
  has_many :passive_relationships, class_name:  "Relationship",
                                 foreign_key: "followed_id",
                                 dependent:   :destroy
  # 'source: :followed' is utilized in order to use :following instead of awkward followeds
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships

  # create an accessible attribute for "remember" method below
  attr_accessor :remember_token, :activation_token, :reset_token

  # Before saving the record in the database, change the address to downcase.
  # before_save applies to BOTH: Create and Update methods
  before_save   :downcase_email # method available in private methods below
  # before_create applies ONLY to Create method
  before_create :create_activation_digest # method available in private methods below

  validates :name, presence: true, length: { maximum: 50 }

  # REGEX = Regular Expression
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    # means this is true, but also case sensitive
                    uniqueness: { case_sensitive: false }

  has_secure_password # this method will provide:
      # The ability to save a securely hashed password_digest attribute to the database
      # A pair of virtual attributes (password and password_confirmation), including presence validations upon object     creation and a validation requiring that they match
      # An authenticate method that returns the user when the password is correct (and false otherwise)
    # Requirements:
      # User model must have an attribute called password_digest
      # gem 'bcrypt'

  # allow_blank is needed in order to be able to update the user info, without updating the password each time
  validates :password, length: { minimum: 6 }, allow_blank: true

  # Returns the hash digest of the given string. Needed for Fixtures in tests
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end


  # Returns a random token. Needed to make the user session persistent
  # https://www.railstutorial.org/book/log_in_log_out#sec-remember_token
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    # User.digest defined above
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    # check more on METAPROGRAMMING 'self.send(....)'
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  def activate
    # self IS OPTIONAL in the Model, as seen below
    self.update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # building users posts feed
  def feed
    following_ids = "SELECT followed_id FROM relationships
                 WHERE  follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                 OR user_id = :user_id", user_id: id)
  end

  # FOLLOWING ACTIONS
  # Follows a user.
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  # Unfollows a user.
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  #PRIVATE METHODS
  private
    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end

    # Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

end

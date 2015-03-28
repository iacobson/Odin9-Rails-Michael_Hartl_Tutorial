class User < ActiveRecord::Base
  # create an accessible attribute for "remember" method below
  attr_accessor :remember_token

  # before saving the record in the database, change the address to downcase
  before_save { self.email = email.downcase }

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
  validates :password, length: { minimum: 6 }

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
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

end

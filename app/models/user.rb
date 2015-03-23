class User < ActiveRecord::Base

  # before saving the record in the database, change the address to downcase
  before_save { self.email = email.downcase }

  validates :name, presence: true, length: { maximum: 50 }

  # REGEX = Regular Expression
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
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

end

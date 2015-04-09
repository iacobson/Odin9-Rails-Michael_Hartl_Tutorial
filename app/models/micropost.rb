class Micropost < ActiveRecord::Base
  belongs_to :user
  # Define the default order the element are retreived from Micropost table
  # The stabby lambda -> takes in a block and returns a Proc, which can then be evaluated with the call method.
  default_scope -> { order(created_at: :desc) }

  # add image upload
  mount_uploader :picture, PictureUploader


  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  validate  :picture_file_size

  private

    # Validates the file size of an uploaded picture.
    def picture_file_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end

end

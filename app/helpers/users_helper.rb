module UsersHelper

  # Returns the Gravatar for the given user.
  def gravatar_for(user)
    # details here: https://www.railstutorial.org/book/sign_up#sec-a_gravatar_image
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end

end

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Use Devise's built-in authentication filter
  before_action :authenticate_user!

  # No need for the custom require_login method anymore
  # private
  # def require_login
  #   ...
  # end
end

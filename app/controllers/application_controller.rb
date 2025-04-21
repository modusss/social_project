class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Remove the default authenticate_user! if it redirects elsewhere
  # before_action :authenticate_user! # Comentado ou removido

  # Add custom authentication check
  before_action :require_login

  private

  # Method to check if user is logged in
  def require_login
    # Redirect to the new session path (usually sessions#new) if not signed in
    unless user_signed_in? # Assumes user_signed_in? helper from your auth gem (like Devise)
      redirect_to new_session_path, alert: "Você precisa fazer login para continuar." # Or use flash[:alert]
    end
  end
end

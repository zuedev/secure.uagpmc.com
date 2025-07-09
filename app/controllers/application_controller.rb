class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  # Check if user is logged in via Discord
  def discord_user_logged_in?
    session[:discord_id].present?
  end

  # Check if current user has any of the specified roles
  def user_has_discord_roles?(role_ids)
    return false unless discord_user_logged_in?
    return true if role_ids.empty?

    user_roles = session[:user_roles] || []
    role_ids = role_ids.map(&:to_s)
    user_roles = user_roles.map(&:to_s)

    (role_ids & user_roles).any?
  end

  # Require Discord authentication
  def require_discord_auth
    unless discord_user_logged_in?
      flash[:alert] = "You must be logged in with Discord to access this page."
      redirect_to root_path
    end
  end

  # Require specific Discord roles
  def require_discord_roles(role_ids)
    require_discord_auth
    return if performed? # Don't continue if already redirected

    unless user_has_discord_roles?(role_ids)
      flash[:alert] = "You don't have the required permissions to access this page."
      redirect_to dashboard_path
    end
  end

  helper_method :discord_user_logged_in?, :user_has_discord_roles?
end

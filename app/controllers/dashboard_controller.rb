class DashboardController < ApplicationController
  before_action :require_discord_auth
  # Example: require specific roles for certain actions
  # before_action -> { require_discord_roles(['role_id_1', 'role_id_2']) }, only: [:admin_action]

  def show
    @discord_id = session[:discord_id]
    @username = session[:username]
    @email = session[:email]
    @avatar = session[:avatar]
    @user_roles = session[:user_roles] || []
  end

  private

  def authenticate_user!
    unless session[:discord_id]
      redirect_to root_path, alert: "You must be logged in to view this page."
    end
  end
end

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @discord_id = session[:discord_id]
    @username = session[:username]
    @email = session[:email]
  end

  private

  def authenticate_user!
    unless session[:discord_id]
      redirect_to root_path, alert: "You must be logged in to view this page."
    end
  end
end
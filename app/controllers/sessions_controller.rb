class SessionsController < ApplicationController
  def create
    auth_hash = request.env['omniauth.auth']
    @discord_id = auth_hash['uid'] # This is the user's Discord ID
    @username = auth_hash['info']['name'] # User's Discord username
    @email = auth_hash['info']['email'] # User's Discord email (if 'email' scope was requested)

    # Store the Discord ID (and other info) in the session
    session[:discord_id] = @discord_id
    session[:username] = @username
    session[:email] = @email

    # You might want to find_or_create a user in your database here
    # For this example, we'll just store in session and redirect

    redirect_to dashboard_path, notice: "Successfully logged in with Discord!"
  end

  def failure
    flash[:alert] = "Authentication failed: #{params[:message].humanize}"
    redirect_to root_path
  end

  # Optional: A logout action
  def destroy
    session[:discord_id] = nil
    session[:username] = nil
    session[:email] = nil
    redirect_to root_path, notice: "Logged out!"
  end
end

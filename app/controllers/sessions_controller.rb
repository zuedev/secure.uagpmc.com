class SessionsController < ApplicationController
  # Configuration - set these in environment variables or config
  REQUIRED_GUILD_ID = ENV["DISCORD_GUILD_ID"] # Your Discord server ID
  REQUIRED_ROLES = ENV["DISCORD_REQUIRED_ROLES"]&.split(",") || [] # Comma-separated role IDs

  def create
    auth_hash = request.env["omniauth.auth"]

    @discord_id = auth_hash["uid"] # This is the user's Discord ID
    @username = auth_hash["info"]["name"] # User's Discord username
    @email = auth_hash["info"]["email"] # User's Discord email (if 'email' scope was requested)
    @avatar = auth_hash["info"]["image"] || "https://cdn.discordapp.com/embed/avatars/0.png" # User's Discord avatar URL, default if not set

    # Get the access token for API calls
    access_token = auth_hash["credentials"]["token"]

    # Check guild membership and roles
    if REQUIRED_GUILD_ID.present?
      discord_service = DiscordApiService.new(access_token)

      unless discord_service.user_authorized?(REQUIRED_GUILD_ID, REQUIRED_ROLES)
        flash[:alert] = "Access denied. You must be a member of the required Discord server with appropriate roles."
        redirect_to root_path and return
      end

      # Store user's roles for later use if needed
      user_roles = discord_service.user_roles_in_guild(REQUIRED_GUILD_ID)
      session[:user_roles] = user_roles
    end

    # Store the Discord ID (and other info) in the session
    session[:discord_id] = @discord_id
    session[:username] = @username
    session[:email] = @email
    session[:avatar] = @avatar
    session[:access_token] = access_token # Store for future API calls if needed

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
    session[:avatar] = nil
    session[:access_token] = nil
    session[:user_roles] = nil
    redirect_to root_path, notice: "Logged out!"
  end
end

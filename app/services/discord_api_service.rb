class DiscordApiService
  include HTTParty
  base_uri "https://discord.com/api/v10"

  def initialize(access_token)
    @access_token = access_token
    @headers = {
      "Authorization" => "Bearer #{@access_token}",
      "Content-Type" => "application/json"
    }
  end

  # Check if user is in a specific guild
  def user_in_guild?(guild_id)
    response = self.class.get("/users/@me/guilds", headers: @headers)

    return false unless response.success?

    guilds = response.parsed_response
    guilds.any? { |guild| guild["id"] == guild_id.to_s }
  end

  # Get user's roles in a specific guild
  def user_roles_in_guild(guild_id)
    response = self.class.get("/users/@me/guilds/#{guild_id}/member", headers: @headers)

    return [] unless response.success?

    member_data = response.parsed_response
    member_data["roles"] || []
  end

  # Check if user has any of the specified roles in a guild
  def user_has_roles?(guild_id, required_role_ids)
    user_role_ids = user_roles_in_guild(guild_id)

    # Convert to strings for comparison
    required_role_ids = required_role_ids.map(&:to_s)
    user_role_ids = user_role_ids.map(&:to_s)

    # Check if user has any of the required roles
    (required_role_ids & user_role_ids).any?
  end

  # Combined check: user in guild AND has required roles
  def user_authorized?(guild_id, required_role_ids)
    return false unless user_in_guild?(guild_id)
    return true if required_role_ids.empty? # If no specific roles required, just being in guild is enough

    user_has_roles?(guild_id, required_role_ids)
  end

  # Get all user's guilds (for debugging/admin purposes)
  def user_guilds
    response = self.class.get("/users/@me/guilds", headers: @headers)
    response.success? ? response.parsed_response : []
  end
end

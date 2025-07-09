# Discord Guild and Role Authentication

This application includes Discord guild membership and role-based authentication. Users must be members of your Discord server and optionally have specific roles to access the application.

## Setup

### 1. Environment Variables

Copy `.env.example` to `.env` and configure:

```env
# Required: Your Discord application credentials
DISCORD_CLIENT_ID=your_discord_client_id_here
DISCORD_CLIENT_SECRET=your_discord_client_secret_here

# Required: Your Discord server (guild) ID
DISCORD_GUILD_ID=your_discord_server_id_here

# Optional: Comma-separated list of role IDs that grant access
# If empty, any member of the guild can access
DISCORD_REQUIRED_ROLES=role_id_1,role_id_2,role_id_3
```

### 2. Getting Discord IDs

**Guild ID:**
1. Enable Developer Mode in Discord (User Settings > Advanced > Developer Mode)
2. Right-click your server name and select "Copy Server ID"

**Role IDs:**
1. In your Discord server, go to Server Settings > Roles
2. Right-click any role and select "Copy Role ID"

## How It Works

### Authentication Flow

1. User clicks "Login with Discord"
2. Discord OAuth redirects back with user info and access token
3. Application checks if user is in the required guild
4. If guild membership is verified, check if user has any required roles
5. If authorized, user is logged in; otherwise, access is denied

### Authorization Methods

**In Controllers:**

```ruby
class SomeController < ApplicationController
  # Require Discord login for all actions
  before_action :require_discord_auth
  
  # Require specific roles for certain actions
  before_action -> { require_discord_roles(['admin_role_id']) }, only: [:admin_action]
  before_action -> { require_discord_roles(['mod_role_id', 'admin_role_id']) }, only: [:moderate]
end
```

**In Views:**

```erb
<!-- Show content only to users with specific roles -->
<% if user_has_discord_roles?(['admin_role_id']) %>
  <div class="admin-panel">
    <!-- Admin-only content -->
  </div>
<% end %>

<!-- Show content to users with any of multiple roles -->
<% if user_has_discord_roles?(['moderator_role_id', 'admin_role_id']) %>
  <div class="moderation-tools">
    <!-- Content for moderators and admins -->
  </div>
<% end %>
```

### Available Helper Methods

**`discord_user_logged_in?`**
- Returns true if user is logged in via Discord

**`user_has_discord_roles?(role_ids)`**
- Returns true if user has any of the specified roles
- Pass an array of role IDs as strings
- Returns true if role_ids is empty (no role requirement)

**`require_discord_auth`**
- Controller method to require Discord authentication
- Redirects to home page if not logged in

**`require_discord_roles(role_ids)`**
- Controller method to require specific roles
- Redirects to dashboard if user doesn't have required roles

## Session Data

After successful authentication, the following data is stored in the session:

- `session[:discord_id]` - User's Discord ID
- `session[:username]` - User's Discord username
- `session[:email]` - User's Discord email
- `session[:avatar]` - User's Discord avatar URL
- `session[:access_token]` - Discord API access token
- `session[:user_roles]` - Array of user's role IDs in the guild

## Discord API Service

The `DiscordApiService` class provides methods for interacting with Discord's API:

```ruby
service = DiscordApiService.new(access_token)

# Check if user is in a guild
service.user_in_guild?(guild_id)

# Get user's roles in a guild
service.user_roles_in_guild(guild_id)

# Check if user has specific roles
service.user_has_roles?(guild_id, ['role_id_1', 'role_id_2'])

# Combined authorization check
service.user_authorized?(guild_id, ['role_id_1', 'role_id_2'])
```

## Configuration Options

### No Role Requirements
If you only want to check guild membership without specific roles:
```env
DISCORD_GUILD_ID=your_guild_id
DISCORD_REQUIRED_ROLES=
```

### Multiple Roles (OR logic)
Users need ANY of the specified roles:
```env
DISCORD_REQUIRED_ROLES=role_id_1,role_id_2,role_id_3
```

### Open Access
To disable guild/role checking entirely, don't set `DISCORD_GUILD_ID`:
```env
# DISCORD_GUILD_ID=  # commented out or empty
```

## Troubleshooting

### Common Issues

1. **"Access denied" message**
   - Verify user is in the correct Discord server
   - Check that role IDs are correct
   - Ensure user has one of the required roles

2. **OAuth scope errors**
   - Make sure your Discord application has the correct scopes: `identify`, `email`, `guilds`, `guilds.members.read`

3. **API rate limits**
   - Discord API has rate limits; consider caching role checks for frequent access

### Testing

1. Create test roles in your Discord server
2. Assign yourself different roles to test access levels
3. Check the dashboard to see your current roles
4. Test with users who have different role combinations

puts "DISCORD_CLIENT_ID: #{ENV['DISCORD_CLIENT_ID'].present? ? 'Loaded' : 'NOT LOADED'}"
puts "DISCORD_CLIENT_SECRET: #{ENV['DISCORD_CLIENT_SECRET'].present? ? 'Loaded' : 'NOT LOADED'}"

# For security, OmniAuth 2.0+ defaults to only allowing POST requests
# to the /auth/:provider routes. If you need to allow GET (e.g., for direct links),
# you must explicitly enable it.
# WARNING: Allowing GET requests to initiate authentication can expose you to CSRF
# vulnerabilities if not properly mitigated. The recommended approach is to
# always use POST requests with CSRF protection.
OmniAuth.config.allowed_request_methods = [:get, :post]

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :discord, ENV['DISCORD_CLIENT_ID'], ENV['DISCORD_CLIENT_SECRET'], scope: 'identify email'
end

# Optional: To silence the warning about using GET for request methods
OmniAuth.config.silence_get_warning = true
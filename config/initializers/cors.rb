# Browser games are hosted on other origins (itch.io, their own sites, ...), so the public scores API
# accepts cross-origin requests from anywhere. Requests authenticate with a bearer token, not cookies.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*"
    resource %r{\A/games/[^/]+/scores(\.json)?\z}, headers: :any, methods: %i[ get post options ], max_age: 1.day.to_i
  end
end

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :woff, WoffWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FkPgyaAL8b9VU59tUDecWeucDYOLmOMPpP4eEz3D7cKfGYYXGFkhEnlx3TjKi0JE",
  render_errors: [view: WoffWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Woff.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :code_together,
  ecto_repos: [CodeTogether.Repo]

# Configures the endpoint
config :code_together, CodeTogether.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "AVuTPpDUFiABqhC7ft50mvbKIKGZKEmDiS1TbigyL/VvhS9/T2ZKWwRfW09wM9qF",
  render_errors: [view: CodeTogether.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CodeTogether.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

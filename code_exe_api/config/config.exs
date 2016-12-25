use Mix.Config

config :maru, CodeExeApi.API,
  http: [port: System.get_env("PORT") || 8080]

Application.ensure_all_started(:hound)
ExUnit.start
Mix.Task.run "ecto.create", ["--quiet"]
Mix.Task.run "ecto.migrate", ["--quiet"]

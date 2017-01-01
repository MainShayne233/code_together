if System.get_env("KILL_DOCKER") do
  IO.puts "Stopping and rming all docker containers"
  :os.cmd('docker stop $(docker ps -a -q)')
else
  IO.puts "KILL_DOCKER env not set. Could make some tests fail"
end
ExUnit.start
Ecto.Adapters.SQL.Sandbox.mode(CodeTogether.Repo, :manual)

defmodule CodeTogether do
  alias CodeTogether.CodeRoom
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [

      supervisor(CodeTogether.Repo, []),

      supervisor(CodeTogether.Endpoint, []),

      # in charge of closing inactive code_rooms
      # worker(CodeTogether.RoomWatcher, [])
    ]

    # builds image to address any updates
    CodeRoom.build_image!

    opts = [strategy: :one_for_one, name: CodeTogether.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    CodeTogether.Endpoint.config_change(changed, removed)
    :ok
  end
end

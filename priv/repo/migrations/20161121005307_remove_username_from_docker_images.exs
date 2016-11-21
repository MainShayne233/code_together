defmodule CodeTogether.Repo.Migrations.RemoveUsernameFromDockerImages do
  use Ecto.Migration

  def change do
    alter table(:docker_images) do
      remove :username
      add    :code_room_id, :integer
    end
  end
end

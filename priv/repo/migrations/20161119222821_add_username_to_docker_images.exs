defmodule CodeTogether.Repo.Migrations.AddUsernameToDockerImages do
  use Ecto.Migration

  def change do
    alter table(:docker_images) do
      add :username, :string
    end
  end
end

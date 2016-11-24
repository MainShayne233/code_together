defmodule CodeTogether.Repo.Migrations.AddDockerNameAndPortToCodeRooms do
  use Ecto.Migration

  def change do
    alter table(:code_rooms) do
      add :docker_name, :string
      add :port, :integer
    end
  end
end

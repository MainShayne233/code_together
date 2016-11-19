defmodule CodeTogether.Repo.Migrations.CreateDockerImage do
  use Ecto.Migration

  def change do
    create table(:docker_images) do
      add :port, :integer
      add :name, :string

      timestamps()
    end

  end
end

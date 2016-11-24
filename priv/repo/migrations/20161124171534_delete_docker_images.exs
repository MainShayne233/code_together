defmodule CodeTogether.Repo.Migrations.DeleteDockerImages do
  use Ecto.Migration

  def change do
    drop table(:docker_images)
  end
end

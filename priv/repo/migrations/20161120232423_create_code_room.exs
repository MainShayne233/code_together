defmodule CodeTogether.Repo.Migrations.CreateCodeRoom do
  use Ecto.Migration

  def change do
    create table(:code_rooms) do
      add :language, :string
      add :name, :string
      add :private_key, :string

      timestamps()
    end

  end
end

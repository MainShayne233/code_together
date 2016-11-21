defmodule CodeTogether.Repo.Migrations.AddOutputToCodeRooms do
  use Ecto.Migration

  def change do
    alter table(:code_rooms) do
      add :output, :text
    end
  end
end

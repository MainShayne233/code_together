defmodule CodeTogether.Repo.Migrations.AddCodeToCodeRooms do
  use Ecto.Migration

  def change do
    alter table(:code_rooms) do
      add :code, :text
    end
  end
end

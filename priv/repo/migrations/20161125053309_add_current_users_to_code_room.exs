defmodule CodeTogether.Repo.Migrations.AddCurrentUsersToCodeRoom do
  use Ecto.Migration

  def change do
    alter table(:code_rooms) do
      add :current_users, {:array, :string}
    end
  end
end

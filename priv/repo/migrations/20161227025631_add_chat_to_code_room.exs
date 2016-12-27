defmodule CodeTogether.Repo.Migrations.AddChatToCodeRoom do
  use Ecto.Migration

  def change do
    alter table(:code_rooms) do
      add :chat, :text
    end
  end
end

defmodule CodeTogether.Repo.Migrations.CreateCoderoomsTable do
  use Ecto.Migration

  def change do
    create table(:coderooms) do
      add :language,      :string
      add :name,          :string
      add :private_key,   :string
      add :code,          :text
      add :output,        :text
      add :chat,          :text
      add :docker_name,   :string
      add :port,          :integer
      add :current_users, {:array, :string}

      timestamps
    end
    create unique_index(:coderooms, [:name])
    create unique_index(:coderooms, [:private_key])
    create unique_index(:coderooms, [:docker_name])
    create unique_index(:coderooms, [:port])

  end
end

defmodule CodeTogether.User do
  use CodeTogether.Web, :model
  alias CodeTogether.{Repo, User}

  schema "users" do
    field :username, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username])
    |> validate_required([:username])
    |> unique_constraint(:username)
    |> validate_length(:username, min: 1)
  end

  def create(username) do
    changeset(%User{}, %{username: username})
    |> Repo.insert
    |> case do
      {:ok, user} -> {:ok, user}
      {:error, %{errors: errors}} ->
        {
          :error,
          errors
          |> Enum.map(fn {field, {error, _}} -> "#{field} #{error}" end)
        }
    end
  end

  def get(nil), do: {:error, "No username"}
  def get(username) do
    case Repo.get_by(User, %{username: username}) do
      nil  -> {:error, "User not found"}
      user -> {:ok, user}
    end
  end
end

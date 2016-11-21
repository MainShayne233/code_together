defmodule CodeTogether.CodeRoom do
  alias CodeTogether.CodeRoom
  alias CodeTogether.Repo
  use CodeTogether.Web, :model

  schema "code_rooms" do
    field :language, :string
    field :name, :string
    field :private_key, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:language, :name])
    |> validate_required([:language, :name])
  end

  def create_private(name, language) do
    if taken?(name) do
      %CodeRoom{}
      |> changeset(%{
        name: name,
        language: language,
        private_key: new_private_key
      })
      |> Repo.insert
    else
      {:error, :name_taken}
    end
  end

  def taken?(name) do
    find_for(name) == nil
  end

  def find_for(name) do
    Repo.all(
      from c in CodeRoom,
      where: c.name == ^name
    )
    |> List.first
  end

  def new_private_key do
    :os.system_time(:micro_seconds)
    |> Integer.to_string
  end
end

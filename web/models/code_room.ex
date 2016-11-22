defmodule CodeTogether.CodeRoom do
  alias CodeTogether.CodeRoom
  alias CodeTogether.Repo
  use CodeTogether.Web, :model

  schema "code_rooms" do
    field :language,    :string
    field :name,        :string
    field :private_key, :string
    field :code,        :string
    field :output,      :string
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:language, :name, :code, :output, :private_key])
    |> validate_required([:language, :name, :code, :output, :private_key])
  end

  def create_private(name, language) do
    if available?(name) do
      %CodeRoom{}
      |> changeset(%{
        name: name,
        language: language,
        private_key: new_private_key,
        code: default_code_for(language),
        output: default_output_for(language)
      })
      |> Repo.insert
    else
      {:error, :name_taken}
    end
  end

  def update(code_room, params) do
    changeset(code_room,params)
    |> Repo.update
  end

  def truncate(output) do
    character_count = String.length output
    if character_count > max_output_char_count do
      String.slice(output, character_count - max_output_char_count, character_count)
    else
      output
    end
  end

  def max_output_char_count, do: 6000

  def validate_name(name) do
    cond do
      taken?(name) -> {:error, "There is already a code room named #{name}"}
      true ->         {:ok,    "name is valid"}
    end
  end

  def available?(name) do
    find_for(name) == nil
  end

  def taken?(name) do
    !available?(name)
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


  def default_code_for("ruby") do
    "class String\n  "         <>
    "def palindrome?\n    "    <>
    "self == self.reverse\n  " <>
    "end\nend\n\n'racecar'.palindrome?"
  end

  def default_output_for("ruby"), do: "=> true"
end

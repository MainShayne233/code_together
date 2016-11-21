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
    |> cast(params, [:language, :name, :code, :output])
    |> validate_required([:language, :name, :code, :output])
  end

  def create_private(name, language) do
    if taken?(name) do
      %CodeRoom{}
      |> changeset(%{
        name: name,
        language: language,
        private_key: new_private_key,
        code: default_code_for(language)
      })
      |> Repo.insert
    else
      {:error, :name_taken}
    end
  end

  def update(code_room, %{output: output}) do
    changeset(code_room, %{output: truncate(output)})
    |> Repo.update
  end

  def truncate(output) do
    lines = String.split output, "\n"
    line_count = Enum.count(lines)
    if line_count > 25 do
      Enum.slice(lines, line_count-26, line_count-1)
    else
      lines
    end
    |> Enum.join("\n")
  end

  def update(code_room, %{code: code}) do
    changeset(code_room, %{code: code})
    |> Repo.update
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


  def default_code_for("ruby") do
    "class String\n  "         <>
    "def palindrome?\n    "    <>
    "self == self.reverse\n  " <>
    "end\nend\n\n'racecar'.palindrome?"
  end
end

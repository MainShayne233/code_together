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

  def validate_name(name) do
    [
      validate_uniq(name, :name),
      validate_length(name, :name)
    ]
    |> validity_check
  end

  def validity_check(validations) do
    case error_list(validations) do
      [] -> {:ok, "valid"}
      errors -> {:error, errors}
    end
  end

  def error_list(validations) do
    Enum.filter_map(validations, fn (validation) ->
      case validation do
        {:error, _} -> true
        _ -> false
      end
    end,
    fn (error) ->
      {:error, message} = error
      message
    end)
  end

  def validate_uniq(value, field) do
    case Repo.get_by(CodeRoom, %{field => value}) do
      nil -> {:ok, "#{field} is uniq"}
      _   -> {:error, "There is already a code room with a #{field}: #{value}"}
    end
  end

  def validate_length(value, field) do
    {min, max} = valid_lengths_for(field)
    cond do
      String.length(value) < min ->
        {:error, "#{field} must at least #{min} character(s) in length"}
      String.length(value) > max ->
        {:error, "#{field} cannot exceed #{max} character(s) in length"}
      true ->
        {:ok, "#{field} is of proper length"}
    end
  end

  def valid_lengths_for(:name), do: {1, 50}

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

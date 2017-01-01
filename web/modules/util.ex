defmodule CodeTogether.Util do

  def atomize_map(map) do
    atomize_map(%{}, map, Map.keys(map))
  end
  def atomize_map(atomized, _, []), do: atomized
  def atomize_map(atomized, map, [key | rest]) do
    value = Map.get(map, key)
    cond do
      is_map(value) ->
        nested_keys = Map.keys(value)
        nested_map = atomize_map(%{}, value, nested_keys)
        Map.merge(atomized, %{safe_atom(key) => nested_map})
        |> atomize_map(map, rest)
      is_list(value) ->
        if List.first(value) |> is_map do
          atomized
          |> Map.merge(
            %{safe_atom(key) => Enum.map(value, fn map -> atomize_map(map) end)}
          )
          |> atomize_map(map, rest)
        else
          Map.merge(atomized, %{safe_atom(key) => value})
          |> atomize_map(map, rest)
        end

      true ->
        Map.merge(atomized, %{safe_atom(key) => value})
        |> atomize_map(map, rest)
    end
  end

  def safe_float(n) when is_float(n),   do: n
  def safe_float(n) when is_integer(n), do: n + 0.0

  def safe_atom(s) when is_atom(s), do: s
  def safe_atom(s)                , do: String.to_atom(s)

end

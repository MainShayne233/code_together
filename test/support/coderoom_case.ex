defmodule CodeTogether.CoderoomCase do

  alias CodeTogether.{CodeRoom}

  use ExUnit.CaseTemplate

  using do
    quote do
      alias CodeTogether.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import CodeTogether.CoderoomCase
    end
  end

  setup tags do

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(CodeTogether.Repo, {:shared, self()})
    end

    :ok
  end

  def sample_coderoom_params(overwrite_params \\ %{}) do
    %{
      name:     "Test Coderoom",
      language: "ruby",
      private:  "true"
    }
    |> Map.merge(overwrite_params)
  end

  def create_coderoom(overwrite_params \\ %{}) do
    sample_coderoom_params(overwrite_params)
    |> CodeRoom.create_coderoom
  end


end

defmodule CodeTogether.ModelCase do

  use ExUnit.CaseTemplate

  using do
    quote do
      alias CodeTogether.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import CodeTogether.ModelCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(CodeTogether.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(CodeTogether.Repo, {:shared, self()})
    end

    :ok
  end

end

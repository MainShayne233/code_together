defmodule CodeTogether.CodeRoomTest do
  use CodeTogether.ModelCase

  alias CodeTogether.CodeRoom

  @valid_attrs %{key: "some content", language: "some content", name: "some content", private: true}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = CodeRoom.changeset(%CodeRoom{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = CodeRoom.changeset(%CodeRoom{}, @invalid_attrs)
    refute changeset.valid?
  end
end

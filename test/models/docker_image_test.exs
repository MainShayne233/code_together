defmodule CodeTogether.DockerImageTest do
  use CodeTogether.ModelCase

  alias CodeTogether.DockerImage

  @valid_attrs %{name: "some content", port: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = DockerImage.changeset(%DockerImage{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = DockerImage.changeset(%DockerImage{}, @invalid_attrs)
    refute changeset.valid?
  end
end

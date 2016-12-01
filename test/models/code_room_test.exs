defmodule CodeTogether.CodeRoomTest do
  use ExUnit.Case

  alias CodeTogether.CodeRoom

  test "creating private code room" do
    name = "room"
    CodeRoom.create_private(name, "ruby")
    code_room = CodeTogether.Repo.get_by(CodeRoom, name: name)
    assert code_room
    assert code_room.private_key
    assert {:error, :name_taken} == CodeRoom.create_private(name, "ruby")
  end

  test "new_docker_name" do
    assert(!!CodeRoom.new_docker_name)
  end
end

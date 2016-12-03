defmodule CodeTogether.CodeRoomIntegrationTest do
  use ExUnit.Case
  use Hound.Helpers
  alias CodeTogether.LoginPage
  alias CodeTogether.CodeRoomPage
  hound_session

  @code_room_name "coderoom name!"

  test "user should be able to login, create coderoom, write code, run code, get result" do
    CodeTogether.Repo.delete_all CodeTogether.CodeRoom
    LoginPage.login
    find_element(:id, "create-code-room")
    |> click
    input = find_element(:id, "code_room_name")
    fill_field(input, @code_room_name)
    submit_element(input)
    CodeRoomPage.wait_for_dev_env_setup
    find_element(:id, "run-code")
    |> click
    :timer.sleep(500)
    trues = String.split(visible_page_text, "true")
    |> Enum.count
    assert trues > 2
  end

end

defmodule CodeTogether.LogInTest do
  use ExUnit.Case
  use Hound.Helpers
  alias CodeTogether.LoginPage

  hound_session

  test "logging in" do
    navigate_to "/"
    assert current_url == LoginPage.path
    input = find_element(:id, "username")
    fill_field input, "user"
    submit_element input
    assert current_url == "http://localhost:4001/code_rooms"
  end

  test "coo" do
    LoginPage.login
  end


end

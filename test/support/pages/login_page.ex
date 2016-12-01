defmodule CodeTogether.LoginPage do
  use CodeTogether.PageHelpers

  def path, do: "http://localhost:4001/session/new"

  def login do
    navigate_to "/"
    input = find_element(:id, "username")
    fill_field input, "user"
    submit_element input
  end

end

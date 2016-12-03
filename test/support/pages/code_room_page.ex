defmodule CodeTogether.CodeRoomPage do
  use CodeTogether.PageHelpers

  def wait_for_dev_env_setup do
    :timer.sleep(1000)
    if String.contains?(visible_page_text, "Setting up dev environment") do
      wait_for_dev_env_setup
    end
  end

end

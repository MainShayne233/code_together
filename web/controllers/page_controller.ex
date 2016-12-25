defmodule CodeTogether.PageController do
  use CodeTogether.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

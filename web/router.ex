defmodule CodeTogether.Router do
  use CodeTogether.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    # plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CodeTogether do
    pipe_through :browser # Use the default browser stack

    get "/", SessionController, :start

    get "/code_rooms", CodeRoomsController, :index

    get "/session/new", SessionController, :new
    post "/session/create", SessionController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", CodeTogether do
  #   pipe_through :api
  # end
end

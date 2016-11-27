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

    get "/code_rooms/public/:name", CodeRoomsController, :show
    get "/code_rooms/private/:private_key", CodeRoomsController, :show
    resources "/code_rooms", CodeRoomsController

    get "/session/new", SessionController, :new
    post "/session/create", SessionController, :create
  end

  # Other scopes may use custom stacks.
  scope "/api", CodeTogether do
    pipe_through :api
    get "/code_rooms/:id/initial_data", CodeRoomsController, :initial_data
    get "/code_rooms/validate_name/:name", CodeRoomsController, :validate_name
  end
end

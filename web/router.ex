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

  scope "/api", CodeTogether do
    pipe_through :api

    post "/coderooms/get",    CoderoomController, :get
    post "/coderooms/create", CoderoomController, :create

    get "/session/current_user", SessionController, :current_user
    post "/session/create", SessionController, :create
  end

  scope "/", CodeTogether do
    pipe_through :browser

    get "*path", PageController, :index
  end
end

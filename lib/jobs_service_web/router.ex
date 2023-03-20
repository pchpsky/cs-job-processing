defmodule JobsServiceWeb.Router do
  use JobsServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", JobsServiceWeb do
    pipe_through :api
  end
end

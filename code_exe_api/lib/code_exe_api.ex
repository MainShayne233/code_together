defmodule CodeExeApi.Router.Homepage do
  use Maru.Router

  namespace :api do
    namespace :v1 do
      namespace :code do
        namespace :execute do
          params do
            requires :language, type: String
            optional :code,     type: String
          end
          post do
            case CodeExeApi.Execute.code(params) do
              {:ok, result} ->
                conn |> put_status(200) |> json(%{result: result})
            end
            json conn, "hello"
          end
        end
      end
    end
  end

end

defmodule CodeExeApi.API do
  use Maru.Router

  plug Plug.Parsers,
    pass: ["*/*"],
    json_decoder: Poison,
    parsers: [:urlencoded, :json, :multipart]

  mount CodeExeApi.Router.Homepage

  # rescue_from :all do
  #   conn
  #   |> put_status(500)
  #   |> text("Server Error")
  # end
end

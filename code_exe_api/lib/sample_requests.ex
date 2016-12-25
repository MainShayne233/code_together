defmodule SampleRequest do

  def api_url, do: "http://localhost:#{System.get_env("PORT") || 8888}/api/v1/code/execute"

  def ruby_test do
    HTTPotion.post(api_url,
      body: Poison.encode!(%{
        language: "ruby",
        code:     "[1,2,3,4].map {|i| i ** 2}",
      }),
      headers: ["Content-Type": "application/json"]
    )
    |> case do
      %HTTPotion.Response{status_code: 200, body: body} -> body
      %HTTPotion.ErrorResponse{message: message}        -> message
    end
  end

end

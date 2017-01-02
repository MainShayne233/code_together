defmodule CodeTogether.CoderoomControllerTest do
  use CodeTogether.{ConnCase, CoderoomCase}
  alias CodeTogether.{Coderoom, CoderoomCase}

  test "GET /api/coderooms/all/public", %{conn: conn} do
    (0..10)
    |> Enum.map(fn name ->
      CoderoomCase.create_coderoom(%{name: "#{name}", private: false})
      |> elem(1)
    end)
    %{"coderooms" => coderooms} = get(conn, "/api/coderooms/all/public")
    |> json_response(200)
    assert Enum.count(coderooms) == 11
  end

  test "GET /api/coderooms by id", %{conn: conn} do
    {:ok, %{id: id}} = CoderoomCase.create_coderoom
    order = get(conn, "api/coderooms", %{id: id})
    |> json_response(200)
    ["name", "id", "code", "output", "current_users", "chat"]
    |> Enum.each( &(assert(order[&1] != nil)) )
  end

  test "GET /api/coderooms get by name if public", %{conn: conn} do
    {:ok, %{name: name}} = CoderoomCase.create_coderoom(%{private: false})
    order = get(conn, "api/coderooms", %{name: name})
    |> json_response(200)
    ["name", "id", "code", "output", "current_users", "chat"]
    |> Enum.each( &(assert(order[&1] != nil)) )
  end

  test "GET /api/coderooms fail to get by name if private", %{conn: conn} do
    {:ok, %{name: name}} = CoderoomCase.create_coderoom(%{private: true})
    assert get(conn, "api/coderooms", %{name: name})
    |> json_response(400) == %{"error" => "failed to get coderoom"}
  end

  test "GET /api/coderooms get by private key", %{conn: conn} do
    {:ok, %{private_key: private_key}} = CoderoomCase.create_coderoom(%{private: true})
    order = get(conn, "api/coderooms", %{private_key: private_key})
    |> json_response(200)
    ["name", "id", "code", "output", "current_users", "chat"]
    |> Enum.each( &(assert(order[&1] != nil)) )
  end

  test "GET /api/coderooms fail get by private key if public", %{conn: conn} do
    {:ok, %{private_key: private_key}} = CoderoomCase.create_coderoom(%{private: false})
    assert get(conn, "api/coderooms", %{private_key: private_key})
    |> json_response(400) == %{"error" => "failed to get coderoom"}
  end

  test "POST /api/coderooms/create create valid coderoom", %{conn: conn} do
    assert Coderoom.all |> Enum.count == 0
    post(conn, "/api/coderooms/create", %{coderoom: CoderoomCase.sample_coderoom_params})
    |> json_response(200)
    assert Coderoom.all |> Enum.count == 1
  end

  test "POST /api/coderooms/create fail to create invalid coderoom", %{conn: conn} do
    assert Coderoom.all |> Enum.count == 0
    response = post(conn, "/api/coderooms/create", %{
      coderoom: CoderoomCase.sample_coderoom_params(%{name: []})
    })
    |> json_response(400)
    assert response["error"]
    assert Coderoom.all |> Enum.count == 0
  end

  test "GET /api/coderooms/start", %{conn: conn} do
    {:ok, %{id: id}} = CoderoomCase.create_coderoom
    response = post(conn, "/api/coderooms/start", %{id: id}) |> json_response(200)
    assert response["success"] == "Successfully started coderoom"
    :timer.sleep(1000)
    response = post(conn, "/api/coderooms/start", %{id: id}) |> json_response(200)
    assert response["success"] == "Coderoom already running"
    spawn fn ->
      :os.cmd 'docker stop $(docker ps -a -q)'
    end
  end

end

defmodule CodeTogether.CodeRoomTest do
  use ExUnit.Case
  use CodeTogether.ModelCase
  use CodeTogether.CoderoomCase

  alias CodeTogether.{Coderoom, CoderoomCase}

  test "creates a private coderoom" do
    {:ok, order} = CoderoomCase.sample_coderoom_params |> Coderoom.create
    Coderoom.all_fields
    |> Enum.each( &(assert Map.get(order, &1)) )
  end

  test "creates a public coderoom" do
    {:ok, order} = CoderoomCase.sample_coderoom_params(%{private: false}) |> Coderoom.create
    (Coderoom.all_fields -- [:private_key])
    |> Enum.each( &(assert Map.get(order, &1)) )
  end

  test "fail to create coderoom with taken name" do
    assert Coderoom.all |> Enum.count == 0
    CoderoomCase.create_coderoom
    assert Coderoom.all |> Enum.count == 1
    {:error, _} = CoderoomCase.create_coderoom
    assert Coderoom.all |> Enum.count == 1
  end

  test "sanitizes coderoom params" do
    params = CoderoomCase.sample_coderoom_params
    |> Coderoom.sanitized_params
    Coderoom.all_fields
    |> Enum.each( &(assert Map.get(params, &1)) )
  end

  test "should return all public coderooms" do
    (0..5)
    |> Enum.each(fn name ->
      CoderoomCase.sample_coderoom_params(%{name: "#{name}"})
      |> Coderoom.create
    end)
    (6..10)
    |> Enum.each(fn name ->
      CoderoomCase.sample_coderoom_params(%{name: "#{name}", private: false})
      |> Coderoom.create
    end)
    public_coderooms = Coderoom.all_public
    assert Enum.count(public_coderooms) == 5
    (6..10)
    |> Enum.each(fn name ->
      assert Enum.find(public_coderooms, &(&1.name == "#{name}")).private_key == nil
    end)
  end

  test "updates coderoom" do
    {:ok, coderoom} = CoderoomCase.sample_coderoom_params |> Coderoom.create
    Coderoom.update(coderoom, %{name: "New name"})
    assert Coderoom.get_by(%{name: coderoom.name}) == nil
    assert Coderoom.get_by(%{name: "New name"})
  end

end

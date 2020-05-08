defmodule Ext.GQL.Resolvers.CoordsTest do
  use ExUnit.Case

  describe ".call" do
    test "filled coords" do
      entity = %{pickup: %{coordinates: {2, 1}}}

      {:ok, %{lat: lat, long: long}} =
        Ext.GQL.Resolvers.Coords.call().(entity, nil, %{definition: %{schema_node: %{identifier: :pickup}}})

      assert lat == 1
      assert long == 2
    end

    test "empty coords" do
      entity = %{pickup: nil}

      {:ok, %{lat: lat, long: long}} =
        Ext.GQL.Resolvers.Coords.call().(entity, nil, %{definition: %{schema_node: %{identifier: :pickup}}})

      assert lat == nil
      assert long == nil
    end
  end
end

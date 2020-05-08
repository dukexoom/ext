defmodule Ext.ExUnit.Assertions do
  def assert_lists(list_1, list_2) do
    ExUnit.Assertions.assert(
      MapSet.new(list_1) |> MapSet.equal?(MapSet.new(list_2)),
      "lists:\n #{inspect(list_1)}\n\n and \n\n #{inspect(list_2)}\n\n are not equal"
    )
  end
end

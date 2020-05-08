defmodule Ext.Utils.String do
  require IEx

  def random(length), do: :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
end

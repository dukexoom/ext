defmodule Ext.Utils.Map do
  require IEx

  def a ||| b, do: Map.merge(a, b)
end

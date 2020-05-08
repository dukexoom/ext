defmodule Ext.BaseCommand do
  defmacro __using__(_) do
    quote do
      require Logger
      require IEx
      import Ext.Utils.Map
    end
  end
end

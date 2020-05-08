defmodule ExtTest do
  use ExUnit.Case
  doctest Ext.Utils.DateTime
  doctest Ext.GQL.Resolvers.Proxy
  doctest Ext.GQL.Resolvers.CamelCase
  doctest Ext.Utils.Base
  doctest Ext.Utils.Enum
  doctest Ext.Utils.Forms
  doctest Ext.Utils.List
  doctest Ext.Utils.Repo
  doctest Ext.GQL.Resolvers.Base
end

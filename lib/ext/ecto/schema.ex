defmodule Ext.Ecto.Schema do
  require IEx

  def get_schema_assoc(schema, assoc_schema) do
    assocs = schema.__schema__(:associations)
    Enum.find(assocs, &(schema.__schema__(:association, &1).related == assoc_schema))
  end
end

defmodule Ext.Ecto.GetCondition.Table2 do
  import Ecto.Query

  def call({key, {">", value}}, _extra), do: dynamic([entity, assoc1, assoc2], field(assoc2, ^key) > ^value)
  def call({key, {">=", value}}, _extra), do: dynamic([entity, assoc1, assoc2], field(assoc2, ^key) >= ^value)
  def call({key, {"<", value}}, _extra), do: dynamic([entity, assoc1, assoc2], field(assoc2, ^key) < ^value)
  def call({key, {"<=", value}}, _extra), do: dynamic([entity, assoc1, assoc2], field(assoc2, ^key) <= ^value)

  def call({key, {"~=", value}}, _extra),
    do:
      dynamic(
        [entity, assoc1, assoc2],
        like(
          fragment("lower(?)", fragment("cast(? as TEXT)", field(assoc2, ^key))),
          fragment("lower(?)", ^"%#{value}%")
        )
      )

  def call({key, value}, %{type: "="}) when is_list(value),
    do: dynamic([entity, assoc1, assoc2], field(assoc2, ^key) in ^value)

  def call({key, value}, %{type: "!="}) when is_list(value),
    do: dynamic([entity, assoc1, assoc2], field(assoc2, ^key) not in ^value)

  def call({key, nil}, %{type: "="}), do: dynamic([entity, assoc1, assoc2], is_nil(field(assoc2, ^key)))
  def call({key, nil}, %{type: "!="}), do: dynamic([entity, assoc1, assoc2], not is_nil(field(assoc2, ^key)))
  def call({key, value}, %{type: "="}), do: dynamic([entity, assoc1, assoc2], field(assoc2, ^key) == ^value)

  def call({key, value}, %{type: "!="}),
    do: dynamic([entity, assoc1, assoc2], field(assoc2, ^key) != ^value or is_nil(field(assoc2, ^key)))
end

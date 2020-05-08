defmodule Ext.Ecto.GetCondition.Table1 do
  import Ecto.Query

  def call({key, {">", value}}, _extra), do: dynamic([entity, assoc], field(assoc, ^key) > ^value)
  def call({key, {">=", value}}, _extra), do: dynamic([entity, assoc], field(assoc, ^key) >= ^value)
  def call({key, {"<", value}}, _extra), do: dynamic([entity, assoc], field(assoc, ^key) < ^value)
  def call({key, {"<=", value}}, _extra), do: dynamic([entity, assoc], field(assoc, ^key) <= ^value)

  def call({key, {"~=", value}}, _extra),
    do:
      dynamic(
        [entity, assoc],
        like(fragment("lower(?)", fragment("cast(? as TEXT)", field(assoc, ^key))), fragment("lower(?)", ^"%#{value}%"))
      )

  def call({key, value}, %{type: "="}) when is_list(value), do: dynamic([entity, assoc], field(assoc, ^key) in ^value)

  def call({key, value}, %{type: "!="}) when is_list(value),
    do: dynamic([entity, assoc], field(assoc, ^key) not in ^value)

  def call({key, nil}, %{type: "="}), do: dynamic([entity, assoc], is_nil(field(assoc, ^key)))
  def call({key, nil}, %{type: "!="}), do: dynamic([entity, assoc], not is_nil(field(assoc, ^key)))
  def call({key, value}, %{type: "="}), do: dynamic([entity, assoc], field(assoc, ^key) == ^value)

  def call({key, value}, %{type: "!="}),
    do: dynamic([entity, assoc], field(assoc, ^key) != ^value or is_nil(field(assoc, ^key)))
end

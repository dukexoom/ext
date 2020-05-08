defmodule Ext.Ecto.GetCondition.Table0 do
  import Ecto.Query

  def call({key, {">", value}}, _extra), do: dynamic([entity], field(entity, ^key) > ^value)
  def call({key, {">=", value}}, _extra), do: dynamic([entity], field(entity, ^key) >= ^value)
  def call({key, {"<", value}}, _extra), do: dynamic([entity], field(entity, ^key) < ^value)
  def call({key, {"<=", value}}, _extra), do: dynamic([entity], field(entity, ^key) <= ^value)

  def call({key, {"~=", value}}, _extra),
    do:
      dynamic(
        [entity],
        like(
          fragment("lower(?)", fragment("cast(? as TEXT)", field(entity, ^key))),
          fragment("lower(?)", ^"%#{value}%")
        )
      )

  def call({key, value}, %{type: "="}) when is_list(value), do: dynamic([entity], field(entity, ^key) in ^value)
  def call({key, value}, %{type: "!="}) when is_list(value), do: dynamic([entity], field(entity, ^key) not in ^value)
  def call({key, nil}, %{type: "="}), do: dynamic([entity], is_nil(field(entity, ^key)))
  def call({key, nil}, %{type: "!="}), do: dynamic([entity], not is_nil(field(entity, ^key)))
  def call({key, value}, %{type: "="}), do: dynamic([entity], field(entity, ^key) == ^value)

  def call({key, value}, %{type: "!="}),
    do: dynamic([entity], field(entity, ^key) != ^value or is_nil(field(entity, ^key)))
end

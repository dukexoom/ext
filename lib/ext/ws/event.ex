defmodule Ext.Ws.Event do
  @derive {Jason.Encoder, except: [:__meta__, :__struct__]}

  defstruct [:uuid, :data]

  def init(%{uuid: uuid, data: data}), do: %__MODULE__{uuid: uuid, data: data}
  def init(data), do: %__MODULE__{uuid: Ecto.UUID.generate(), data: data}
end

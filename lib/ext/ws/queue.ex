defmodule Ext.Ws.Queue do
  def clear(user_id, subscription_name, event_id) do
    Redix.pipeline!(:redix, [
      ["DEL", event_key(user_id, subscription_name, event_id)],
      ["LREM", key(user_id, subscription_name), 0, event_id]
    ])
  end

  def clear_all(user_id, subscription_name) do
    deleted_keys =
      Redix.command!(:redix, ["LRANGE", key(user_id, subscription_name), "0", "-1"])
      |> Enum.map(&event_key(user_id, subscription_name, &1))

    Redix.command!(:redix, ["DEL" | deleted_keys ++ [key(user_id, subscription_name)]])
  end

  def push(user_id, subscription_name, event_id, data) do
    expired = Ext.Config.get([:ext, :ws, :expired]) || 15 * 60

    Redix.pipeline!(:redix, [
      ["SETEX", event_key(user_id, subscription_name, event_id), expired, Jason.encode!(data)],
      ["RPUSH", key(user_id, subscription_name), event_id],
      ["EXPIRE", key(user_id, subscription_name), expired]
    ])

    data
  end

  def send_next(user_id, subscription_name, caller) do
    if event = first(user_id, subscription_name),
      do: caller.(user_id, subscription_name, event |> Jason.decode!() |> Ext.Utils.Base.to_atom())
  end

  defp key(user_id, subscription_name), do: "user:#{user_id}:#{Inflex.pluralize(subscription_name)}"
  defp event_key(user_id, subscription_name, event_id), do: "user:#{user_id}:#{subscription_name}:#{event_id}"

  defp first(user_id, subscription_name) do
    event_id = Redix.command!(:redix, ["LINDEX", key(user_id, subscription_name), 0])
    if event_id, do: Redix.command!(:redix, ["GET", event_key(user_id, subscription_name, event_id)])
  end
end

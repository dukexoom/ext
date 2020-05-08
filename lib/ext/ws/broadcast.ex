defmodule Ext.Ws.Broadcast do
  @moduledoc """
  Broadcast live event to connected user by topic `private:<user_id>`

  Let's see an example:
    Ext.Ws.Broadcast.call([1, 2], :fake, %{message: "fake_message"})
    Ext.Ws.Broadcast.call([%{id: 1}, %{id: 2}], :fake, %{message: "fake_message"})
    Ext.Ws.Broadcast.call(1, :fake, %{message: "fake_message"})
    Ext.Ws.Broadcast.call(:stable).(1, :fake, %{message: "fake_message"})
  """

  require Logger

  def list_subscriptions, do: Ext.Config.get([:ext, :ws, :subscriptions])

  def call(user_ids, subscription, data, stable \\ false)

  def call(user_ids, subscription, data, stable) when is_list(user_ids),
    do: Enum.each(user_ids, &call(&1, subscription, data, stable))

  def call(%{id: id}, subscription, event, stable),
    do: call(id, subscription, event, stable)

  def call(user_id, subscription, %Ext.Ws.Event{} = event, _stable) do
    [subscriptions: subscriptions, endpoint: endpoint] = Ext.Config.get([:ext, :ws])

    if subscription in subscriptions,
      do: {:ok, Absinthe.Subscription.publish(endpoint, event, [{subscription, "private:#{user_id}"}])},
      else: Logger.warn("Bad subscription, available subscriptions - #{inspect(subscriptions)}")
  end

  def call(user_id, subscription, data, stable) do
    event = data |> Ext.Ws.Event.init() |> save_event(user_id, subscription, stable)
    call(user_id, subscription, event, stable)
  end

  def call(:stable), do: &call(&1, &2, &3, true)

  defp save_event(data, _, _, false), do: data
  defp save_event(data, user_id, subscription, true), do: Ext.Ws.Queue.push(user_id, subscription, data.uuid, data)
end

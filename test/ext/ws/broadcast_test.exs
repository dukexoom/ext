defmodule Ext.Ws.BroadcastTest do
  use ExUnit.Case
  import Mock

  describe ".call" do
    test "simple event" do
      with_mocks([
        {Redix, [], [pipeline!: fn _, _ -> nil end]},
        {Absinthe.Subscription, [], [publish: fn _, _, _ -> nil end]}
      ]) do
        Ext.Ws.Broadcast.call(1, :subscription_1, %{fake: "fake"})
        refute called(Redix.pipeline!(:_, :_))
        assert called(Absinthe.Subscription.publish(:_, :_, :_))
      end
    end

    test "simple event by struct" do
      with_mocks([
        {Redix, [], [pipeline!: fn _, _ -> nil end]},
        {Absinthe.Subscription, [], [publish: fn _, _, _ -> nil end]}
      ]) do
        Ext.Ws.Broadcast.call(%{id: 1}, :subscription_1, %{fake: "fake"})
        refute called(Redix.pipeline!(:_, :_))
        assert called(Absinthe.Subscription.publish(:_, :_, :_))
      end
    end

    test "simple event, for multiple users" do
      with_mocks([
        {Redix, [], [pipeline!: fn _, _ -> nil end]},
        {Absinthe.Subscription, [], [publish: fn _, _, _ -> nil end]}
      ]) do
        Ext.Ws.Broadcast.call([1, 2], :subscription_1, %{fake: "fake"})
        refute called(Redix.pipeline!(:_, :_))
        assert called(Absinthe.Subscription.publish(:_, :_, :_))
      end
    end

    test "stable event" do
      with_mocks([
        {Redix, [], [pipeline!: fn _, _ -> nil end]},
        {Absinthe.Subscription, [], [publish: fn _, _, _ -> nil end]}
      ]) do
        Ext.Ws.Broadcast.call(:stable).(1, :subscription_1, %{fake: "fake"})
        assert called(Redix.pipeline!(:_, :_))
        assert called(Absinthe.Subscription.publish(:_, :_, :_))
      end
    end

    test "bad event" do
      with_mocks([
        {Absinthe.Subscription, [], [publish: fn _, _, _ -> nil end]}
      ]) do
        Ext.Ws.Broadcast.call(1, :bad_event_test, %{fake: "fake"})
        refute called(Absinthe.Subscription.publish(:_, :_, :_))
      end
    end

    test "send event from redis" do
      with_mocks([
        {Redix, [], [pipeline!: fn _, _ -> nil end]},
        {Absinthe.Subscription, [], [publish: fn _, _, _ -> nil end]}
      ]) do
        Ext.Ws.Broadcast.call(1, :subscription_1, %{uuid: "fake", data: %{fake: "fake"}})
        refute called(Redix.pipeline!(:_, :_))
        assert called(Absinthe.Subscription.publish(:_, :_, :_))
      end
    end
  end
end

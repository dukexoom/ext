defmodule Ext.Ws.QueueTest do
  use ExUnit.Case
  import Mock

  test ".clear" do
    with_mocks([
      {Redix, [], pipeline!: fn _, _ -> "" end}
    ]) do
      Ext.Ws.Queue.clear(1, :name, "event_id")
      assert called(Redix.pipeline!(:_, :_))
    end
  end

  test ".clear_all" do
    with_mocks([
      {Redix, [], command!: fn _, _ -> [] end}
    ]) do
      Ext.Ws.Queue.clear_all(1, :name)
      assert called(Redix.command!(:_, :_))
    end
  end

  test ".push" do
    with_mocks([
      {Redix, [], pipeline!: fn _, _ -> "" end}
    ]) do
      result = Ext.Ws.Queue.push(1, :name, "event_id", %{fake_key: "fake_value"})
      assert called(Redix.pipeline!(:_, :_))
      assert result == %{fake_key: "fake_value"}
    end
  end

  test ".send_next" do
    with_mocks([
      {Redix, [],
       command!: fn
         _, ["LINDEX", _, _] -> "event_id"
         _, _ -> "{\"from_redis\": \"value\"}"
       end},
      {Ext.Ws.Broadcast, [], call: fn _, _, _ -> "" end}
    ]) do
      Ext.Ws.Queue.send_next(1, :name, &Ext.Ws.Broadcast.call/3)
      assert called(Redix.command!(:_, :_))
      assert called(Ext.Ws.Broadcast.call(:_, :_, :_))
    end
  end
end

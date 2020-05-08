defmodule Ext.Ws.EventTest do
  use ExUnit.Case

  describe ".init" do
    test "check if has uuid" do
      event = Ext.Ws.Event.init(%{uuid: "fake", data: %{token: "token"}})
      assert event == %Ext.Ws.Event{uuid: "fake", data: %{token: "token"}}
    end

    test "check if no uuid" do
      event = Ext.Ws.Event.init(%{chanel: "channel"})
      assert event.uuid
      assert event.data == %{chanel: "channel"}
    end
  end
end

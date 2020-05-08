defmodule Ext.ConfigTest do
  use ExUnit.Case

  describe ".get" do
    test "is atom" do
      for_test = Ext.Config.get(:for_test)
      assert for_test == [slack: [token: "slack_token"], docker: %{user_name: "user_name"}]
    end

    test "is atom and bad key" do
      for_test = Ext.Config.get(:for_test_bad)
      assert for_test == []
    end

    test "is list for map" do
      docker = Ext.Config.get([:for_test, :docker])
      assert docker == %{user_name: "user_name"}

      docker_user_name = Ext.Config.get([:for_test, :docker, :user_name])
      assert docker_user_name == "user_name"
    end

    test "is list for map, bad key" do
      docker = Ext.Config.get([:for_test, :docker_1])
      assert docker == nil

      docker_user_name = Ext.Config.get([:for_test, :docker_1, :user_name])
      assert docker_user_name == nil
    end

    test "is list for keywords" do
      slack = Ext.Config.get([:for_test, :slack])
      assert slack == [token: "slack_token"]

      slack_token = Ext.Config.get([:for_test, :slack, :token])
      assert slack_token == "slack_token"
    end

    test "is list for keywords, bad key" do
      slack = Ext.Config.get([:for_test, :slack_1])
      assert slack == nil

      slack_token = Ext.Config.get([:for_test, :slack_1, :token])
      assert slack_token == nil
    end

    test "check default values" do
      slack = Ext.Config.get(:for_test_1, %{for: "default"})
      assert slack == %{for: "default"}

      slack_channel = Ext.Config.get([:for_test, :slack, :channel], "default_channel")
      assert slack_channel == "default_channel"
    end
  end
end

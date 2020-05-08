defmodule Ext.Utils.BaseTest do
  use ExUnit.Case
  import Mock
  require IEx
  require Logger
  import ExUnit.CaptureLog

  test ".check_env_variables" do
    with_mocks([
      {System, [:passthrough],
       get_env: fn
         "EXISTING" -> "TRUE"
         "NOT_EXISTING_1" -> nil
         "NOT_EXISTING_2" -> nil
       end}
    ]) do
      logs = capture_log(fn -> Ext.Utils.Base.check_env_variables("test/support/.test_env.sample") end)

      assert logs =~ "Environment variable NOT_EXISTING_1 does not set"
      assert logs =~ "Environment variable NOT_EXISTING_2 does not set"
    end
  end
end

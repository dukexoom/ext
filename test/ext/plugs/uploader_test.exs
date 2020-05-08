defmodule Ext.Plugs.UploaderTest do
  use ExUnit.Case
  import Ext.Utils.Map

  setup do
    conn_params = %{
      "query" => "query {\n  test_mutation {\n    id\n    name\n  }\n}",
      "variables" => nil
    }

    #    copy/past from Phoenix.ConnTest
    conn =
      Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :get, "/", nil)
      |> Plug.Conn.put_private(:plug_skip_csrf_protection, true)
      |> Plug.Conn.put_private(:phoenix_recycled, true)

    test_conn = conn ||| %{params: conn_params}
    %{test_conn: test_conn, conn_params: conn_params}
  end

  test ".init" do
    assert Ext.Plugs.Uploader.init(opts: "opts") == [opts: "opts"]
  end

  test ".normalize_operations" do
    resp =
      Ext.Plugs.Uploader.normalize_operations(
        ~S({"query":"mutation ($file: Upload!\) {\n  compare(file: $file\)\n}\n","variables":{"file":null}}),
        ~S({"0": ["variables.file"]})
      )

    assert resp == %{
             "query" => "mutation ($file: Upload!) {\n  compare(file: $file)\n}\n",
             "variables" => "{\"file\":\"0\"}"
           }
  end
end

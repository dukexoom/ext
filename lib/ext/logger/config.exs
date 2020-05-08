use Mix.Config

build_logs = fn list ->
  [{LoggerFileBackend, :common_json_log} | Enum.map(list, &{LoggerFileBackend, String.to_atom("#{&1}_log")})]
end

file_backends =
  cond do
    System.get_env("LOG_LEVEL") == "debug" -> build_logs.([:error, :warn, :info, :debug])
    System.get_env("LOG_LEVEL") == "info" -> build_logs.([:error, :warn, :info])
    System.get_env("LOG_LEVEL") == "warn" -> build_logs.([:error, :warn])
    System.get_env("LOG_LEVEL") == "error" -> build_logs.([:error])
    true -> []
  end

metadata = [:request_id, :sdk, :method, :url]
format = "$date $time $metadata[$level] $message\n"

config :logger,
  format: format,
  backends:
    [:console | file_backends] ++
      if(System.get_env("ENABLE_ROLLBAR") == "true", do: [{Ext.Logger.Rollbar.ErrorSend, :error_log}], else: [])

log_keyword = &[path: "log/#{&1}.log", format: format, metadata: metadata, level: &1]

config :logger, :error_log, log_keyword.(:error)
config :logger, :warn_log, log_keyword.(:warn)
config :logger, :info_log, log_keyword.(:info)
config :logger, :debug_log, log_keyword.(:debug)
config :logger, :console, format: format, metadata: metadata

config :logger, :common_json_log,
  path: "log/common.json.log",
  format: {Ext.Logger.Json, :format},
  metadata: metadata,
  level: "LOG_LEVEL" |> System.get_env("debug") |> String.to_atom()

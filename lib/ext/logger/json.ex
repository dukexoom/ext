defmodule Ext.Logger.Json do
  import Ext.Utils.Map
  alias Ext.Logger.Json.TimestampFormatter
  # Fork from https://github.com/soundtrackyourbrand/exlogger

  @spec format(
          Logger.level(),
          Logger.message(),
          Logger.Formatter.time(),
          Logger.Formatter.keyword()
        ) :: IO.chardata()
  def format(level, message, timestamp, metadata) do
    offset = :logger |> Application.fetch_env!(:utc_log) |> TimestampFormatter.utc_offset()
    time = TimestampFormatter.format(timestamp, offset)

    log_data = %{"msg" => normalize_msg(message), "level" => level, "ts" => time} ||| Map.new(metadata)
    "#{Jason.encode!(log_data)}\n"
  rescue
    _ -> "#{TimestampFormatter.format(timestamp, {0, 0})} #{metadata[level]} #{level} #{normalize_msg(message)}\n"
  end

  defp normalize_msg(msg) when is_binary(msg), do: msg
  defp normalize_msg(msg), do: inspect(msg)
end

defmodule Ext.Logger.Rollbar.ErrorSend do
  @moduledoc false

  @behaviour :gen_event
  require IEx
  require Logger

  @type path :: String.t()
  @type file :: :file.io_device()
  @type inode :: File.Stat.t()
  @type format :: String.t()
  @type level :: Logger.level()
  @type metadata :: [atom]

  @default_format "$time $metadata[$level] $message\n"

  @doc false
  def handle_call(request, _state) do
    exit({:bad_call, request})
  end

  def init({__MODULE__, name}) do
    {:ok, configure(name, [])}
  end

  def handle_event({:error, gl, {_logger, message, _date, stacktrace}}, state) when node(gl) == node() do
    Logger.info("ErrorSend handler, gl=#{inspect(node(gl))}, node=#{inspect(node())}, message=#{inspect(message)}")

    unless message =~ "(Rollbax)" do
      Rollbax.report_message(:error, "#{message}\n\n#{inspect(stacktrace)}")
    end

    {:ok, state}
  end

  def handle_event(_process, state), do: {:ok, state}

  def handle_info(_message, state) do
    {:ok, state}
  end

  defp configure(name, opts) do
    state = %{
      name: nil,
      path: nil,
      io_device: nil,
      inode: nil,
      format: nil,
      level: nil,
      metadata: nil,
      metadata_filter: nil,
      rotate: nil
    }

    configure(name, opts, state)
  end

  defp configure(name, opts, state) do
    env = Application.get_env(:logger, name, [])
    opts = Keyword.merge(env, opts)
    Application.put_env(:logger, name, opts)

    level = Keyword.get(opts, :level)
    metadata = Keyword.get(opts, :metadata, [])
    format_opts = Keyword.get(opts, :format, @default_format)
    format = Logger.Formatter.compile(format_opts)
    path = Keyword.get(opts, :path)
    metadata_filter = Keyword.get(opts, :metadata_filter)
    rotate = Keyword.get(opts, :rotate)

    %{
      state
      | name: name,
        path: path,
        format: format,
        level: level,
        metadata: metadata,
        metadata_filter: metadata_filter,
        rotate: rotate
    }
  end
end

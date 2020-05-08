defmodule Ext.Shell do
  def exec(exe, args, opts \\ [:stream]) when is_list(args) do
    port =
      Port.open(
        {:spawn_executable, exe},
        opts ++ [{:args, args}, :binary, :exit_status, :hide, :use_stdio, :stderr_to_stdout]
      )

    handle_output(port)
  end

  def handle_output(port) do
    receive do
      {^port, {:data, data}} ->
        {_, result} = data
        IO.inspect(result)
        handle_output(port)

      {^port, {:exit_status, status}} ->
        case status do
          0 -> status
          _ -> exit("Shell script stoped with error, status - #{status}")
        end
    end
  end
end

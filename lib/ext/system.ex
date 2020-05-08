defmodule Ext.System do
  require Logger
  def cmd(command, args \\ [])

  def cmd("ssh", args),
    do: do_cmd("ssh", ["-o ServerAliveInterval=5", "-o ServerAliveCountMax=2", "-o StrictHostKeyChecking=no"] ++ args)

  def cmd(command, args), do: do_cmd(command, args)

  def cmd!(command, args \\ []) do
    case cmd(command, args) do
      {:ok, res} -> res
      {:error, res} -> raise res.out
    end
  end

  defp do_cmd(command, args) do
    command = "#{command} #{Enum.join(args, " ")}"
    Logger.debug("System.cmd: #{command}")

    case Porcelain.shell(command, err: :out) do
      %{status: 0} = res -> {:ok, res}
      res -> {:error, res}
    end
  end
end

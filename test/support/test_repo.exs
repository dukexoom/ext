defmodule TestRepo do
  use Ecto.Repo, otp_app: :ecto, adapter: Ecto.Adapters.Postgres
  use Ext.Ecto.Repo

  def init(type, opts) do
    opts = [url: "ecto://user:pass@local/hello"] ++ opts
    opts[:parent] && send(opts[:parent], {__MODULE__, type, opts})
    {:ok, opts}
  end
end

TestRepo.start_link()

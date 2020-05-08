use Mix.Config

config :ext, ecto_repos: [TestRepo]
config :ext, :for_test, slack: [token: "slack_token"], docker: %{user_name: "user_name"}

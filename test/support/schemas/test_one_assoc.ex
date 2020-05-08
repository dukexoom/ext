defmodule TestOneAssoc do
  use Ecto.Schema

  schema "test_one_assocs" do
    field(:field, :string)
    belongs_to(:test_user, TestUser)
  end
end

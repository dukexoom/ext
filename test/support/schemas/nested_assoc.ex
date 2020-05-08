defmodule NestedAssoc do
  use Ecto.Schema

  schema "nested_assocs" do
    field(:field, :string)
    belongs_to(:test_many_assoc, TestManyAssoc)
  end
end

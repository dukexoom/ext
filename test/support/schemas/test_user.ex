defmodule TestUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "test_users" do
    field(:name, :string)
    field(:email, :string)
    field(:count, :integer)
    field(:locale, :string)
    has_many(:test_many_assocs, TestManyAssoc)
    has_one(:test_one_assoc, TestOneAssoc)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email])
    |> validate_required([:name, :email])
  end
end

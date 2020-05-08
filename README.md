# Ext

## Installation

```elixir
def deps do
  [
    {:ext, git: "https://github.com/dukexoom/ext.git"}
  ]
end
```

## Forms
The standard approach with `changeset` function has some limitations:

1. There are cases, when we should validate by different ways. e.g. creating smth from admin side and creating smth from user side
2. Sometimes validation rules grow and schema should be spilt
3. Sometime requested params don’t coincide schema params and we should add virtual params into schema. E.g. `password_confirmation`  when we `sign_up/sign_in`

In order to resolve these limitations, we added new abstraction `Forms`

### Usage
```elixir
# 1. Create the custom form
defmodule Managers.SaveForm do
  @moduledoc false
  use Ext.BaseForm

  Ext.BaseForm.schema "" do
    field :id, :integer
    field :email, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
  end

  def changeset(form) do
    form
    |> validate_length(:password, min: 6)
    |> Ext.Validators.Email.call(%{field: :email})
    |> custom_validation()
  end
   
  defp custom_validation(%{changes: %{context: %{extra_param: extra_param}}} = form) do
    if some_condition do
      form
    else
      add_error(form, :id, "Invalid extra param")
    end
  end

end

# 2. Use the form inside controller/resolver or other entry point
form = Managers.SaveForm.call(manager, %{extra_param: "one_two"})

if form.valid? do
  # make business logic through the Command
  Managers.Save.call(form)
else
  send_errors(form)
end
```

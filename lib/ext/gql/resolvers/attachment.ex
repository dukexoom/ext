defmodule Ext.GQL.Resolvers.Attachment do
  @moduledoc false

  def url(uploader) do
    fn parent, args, %{definition: %{schema_node: %{identifier: field_name}}} ->
      {:ok, uploader.url({Ext.Utils.Base.get_in(parent, [field_name]), parent}, args[:version], signed: true)}
    end
  end
end

defmodule Ext.GQL.Resolvers.BaseTest do
  use ExUnit.Case
  import Mock
  require IEx

  describe ".build_assoc_data " do
    test "has_many/many_to_many assoc" do
      test_assoc_list = [%TestManyAssoc{id: 1, field: "test1"}, %TestManyAssoc{id: 2, field: "test2"}]

      with_mock(TestRepoForMock, [:passthrough],
        where: fn _, _ -> :_ end,
        all: fn _ -> test_assoc_list end
      ) do
        {entity_params, preload_assoc} =
          Ext.GQL.Resolvers.Base.build_assoc_data(TestUser, TestRepoForMock, %{
            name: "test_name",
            test_many_assocs: [1, 2]
          })

        assert called(TestRepoForMock.where(TestManyAssoc, id: [1, 2]))
        assert entity_params == %{name: "test_name", test_many_assocs: test_assoc_list}
        assert preload_assoc == [:test_many_assocs]
      end
    end

    test "has_one assoc" do
      assoc_entity = %TestOneAssoc{id: 1, field: "test"}

      {entity_params, preload_assoc} =
        Ext.GQL.Resolvers.Base.build_assoc_data(TestUser, TestRepo, %{name: "test_name", test_one_assoc: assoc_entity})

      assert entity_params == %{name: "test_name", test_one_assoc: assoc_entity}
      assert preload_assoc == [:test_one_assoc]
    end
  end
end

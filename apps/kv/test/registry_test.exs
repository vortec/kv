defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  alias KV.Bucket, as: Bucket
  alias KV.Registry, as: Registry

  setup context do
    {:ok, registry} = Registry.start_link(context.test)
    {:ok, registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert Registry.lookup(registry, "shopping") == :error

    Registry.create(registry, "shopping")
    assert {:ok, bucket} = Registry.lookup(registry, "shopping")

    Bucket.put(bucket, "milk", 2)
    assert Bucket.get(bucket, "milk") == 2
  end

  test "removes buckets on exit", %{registry: registry} do
    Registry.create(registry, "shopping")
    {:ok, bucket} = Registry.lookup(registry, "shopping")

    ref = Process.monitor(bucket)
    Process.exit(bucket, :shutdown)

    assert_receive {:DOWN, ^ref, _, _, _}

    # TODO: could aswell just call Agent.stop(bucket, :shutdown)?

    assert Registry.lookup(registry, "shopping") == :error
  end
end

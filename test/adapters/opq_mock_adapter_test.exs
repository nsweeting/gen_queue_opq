defmodule GenQueue.OPQMockAdapterTest do
  use ExUnit.Case

  Application.put_env(:gen_queue_opq, GenQueue.OPQMockAdapterTest.Enqueuer, adapter: GenQueue.OPQMockAdapter)

  defmodule Enqueuer do
    use GenQueue, otp_app: :gen_queue_opq
  end
  
  defmodule Job do
  end

  setup do
    Process.register(self(), :gen_queue_opq)
    :ok
  end

  describe "push/2" do
    test "sends the job back to the registered process from module" do
      {:ok, _} = Enqueuer.push(Job)
      assert_receive({Job, [], %{}})
    end

    test "sends the job back to the registered process from module tuple" do
      {:ok, _} = Enqueuer.push({Job})
      assert_receive({Job, [], %{}})
    end

    test "sends the job back to the registered process from module and args" do
      {:ok, _} = Enqueuer.push({Job, ["foo", "bar"]})
      assert_receive({Job, ["foo", "bar"], %{}})
    end

    test "sends the job back to the registered process with opts" do
      {:ok, _} = Enqueuer.push({Job, []}, [opt: 0])
      assert_receive({Job, [], %{opt: 0}})
    end

    test "does nothing if process is not registered" do
      Process.unregister(:gen_queue_opq)
      {:ok, _} = Enqueuer.push(Job)
    end
  end
end

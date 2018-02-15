defmodule GenQueue.OPQMockAdapterTest do
  use ExUnit.Case

  defmodule Enqueuer do
    Application.put_env(:gen_queue_opq, __MODULE__, adapter: GenQueue.OPQMockAdapter)

    use GenQueue, otp_app: :gen_queue_opq
  end
  
  defmodule Job do
  end

  setup do
    GenQueue.OPQMockAdapter.setup_test(:gen_queue_opq)
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

    test "that the process reciever name can be set" do
      Process.unregister(:gen_queue_opq)
      GenQueue.OPQMockAdapter.set_process_receiver(:test)
      Process.register(self(), :test)
      {:ok, _} = Enqueuer.push(Job)
      assert_receive({Job, [], %{}})
    end
  end
end

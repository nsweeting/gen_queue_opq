defmodule GenQueue.Adapters.OPQMockTest do
  use ExUnit.Case

  import GenQueue.Test

  defmodule Enqueuer do
    Application.put_env(:gen_queue_opq, __MODULE__, adapter: GenQueue.Adapters.OPQMock)

    use GenQueue, otp_app: :gen_queue_opq
  end
  
  defmodule Job do
  end

  setup do
    setup_test_queue(Enqueuer)
  end

  describe "push/2" do
    test "sends the job back to the process from module" do
      {:ok, _} = Enqueuer.push(Job)
      assert_receive({Job, [], %{}})
    end

    test "sends the job back to the process from module tuple" do
      {:ok, _} = Enqueuer.push({Job})
      assert_receive({Job, [], %{}})
    end

    test "sends the job back to the process from module and args" do
      {:ok, _} = Enqueuer.push({Job, ["foo", "bar"]})
      assert_receive({Job, ["foo", "bar"], %{}})
    end

    test "sends the job back to the process with opts" do
      {:ok, _} = Enqueuer.push({Job, []}, [opt: 0])
      assert_receive({Job, [], %{opt: 0}})
    end

    test "does nothing if process is not registered" do
      reset_test_queue(Enqueuer)
      {:ok, _} = Enqueuer.push(Job)
    end

    test "sends the job back to a named process" do
      setup_global_test_queue(Enqueuer, :test)
      {:ok, _} = Enqueuer.push(Job)
      assert_receive({Job, [], %{}})
    end
  end
end

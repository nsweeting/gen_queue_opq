defmodule GenQueue.Adapters.OPQTest do
  use ExUnit.Case

  import GenQueue.Test
  import GenQueue.OPQTestHelpers

  defmodule Enqueuer do
    Application.put_env(:gen_queue_opq, __MODULE__, adapter: GenQueue.Adapters.OPQ)

    use GenQueue, otp_app: :gen_queue_opq
  end
  
  defmodule Job do
    def perform do
      send_item(Enqueuer, :performed)
    end
  
    def perform(arg1) do
      send_item(Enqueuer, {:performed, arg1})
    end
  end

  setup do
    setup_global_test_queue(Enqueuer, :gen_queue_opq)
  end

  describe "push/2" do
    test "enqueues and runs job from module" do
      {:ok, pid} = Enqueuer.start_link()
      {:ok, job} = Enqueuer.push(Job)
      assert_receive(:performed)
      assert %GenQueue.Job{module: Job, args: []} = job
      stop_process(pid)
    end

    test "enqueues and runs job from module tuple" do
      {:ok, pid} = Enqueuer.start_link()
      {:ok, job} = Enqueuer.push({Job})
      assert_receive(:performed)
      assert %GenQueue.Job{module: Job, args: []} = job
      stop_process(pid)
    end

    test "enqueues and runs job from module and args" do
      {:ok, pid} = Enqueuer.start_link()
      {:ok, job} = Enqueuer.push({Job, ["foo"]})
      assert_receive({:performed, "foo"})
      assert %GenQueue.Job{module: Job, args: ["foo"]} = job
      stop_process(pid)
    end
  end

  test "enqueuer can be started as part of a supervision tree" do
    {:ok, pid} = Supervisor.start_link([{Enqueuer, []}], strategy: :one_for_one)
    {:ok, job} = Enqueuer.push(Job)
    assert_receive(:performed)
    stop_process(pid)
  end
end

defmodule GenQueue.OPQAdapterTest do
  use ExUnit.Case

  import GenQueue.OPQTestHelpers

  defmodule Enqueuer do
    Application.put_env(:gen_queue_opq, __MODULE__, adapter: GenQueue.OPQAdapter)

    use GenQueue, otp_app: :gen_queue_opq
  end
  
  defmodule Job do
    def perform do
      send(:gen_queue_opq, :performed)
    end
  
    def perform(arg1) do
      send(:gen_queue_opq, {:performed, arg1})
    end
  end

  setup do
    Process.register(self(), :gen_queue_opq)
    :ok
  end

  describe "push/2" do
    test "enqueues and runs job from module" do
      {:ok, pid} = Enqueuer.start_link()
      {:ok, job} = Enqueuer.push(Job)
      assert_receive(:performed)
      assert {Job, [], %{}} = job
      stop_process(pid)
    end

    test "enqueues and runs job from module tuple" do
      {:ok, pid} = Enqueuer.start_link()
      {:ok, job} = Enqueuer.push({Job})
      assert_receive(:performed)
      assert {Job, [], %{}} = job
      stop_process(pid)
    end

    test "enqueues and runs job from module and args" do
      {:ok, pid} = Enqueuer.start_link()
      {:ok, job} = Enqueuer.push({Job, ["foo"]})
      assert_receive({:performed, "foo"})
      assert {Job, ["foo"], %{}} = job
      stop_process(pid)
    end
  end
end

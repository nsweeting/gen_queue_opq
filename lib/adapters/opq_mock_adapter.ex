defmodule GenQueue.OPQMockAdapter do
  use GenQueue.Adapter

  alias GenQueue.OPQAdapter

  def start_link(gen_queue, opts \\ []) do
    opts
    |> Keyword.merge(name: gen_queue)
    |> OPQ.init()
  end

  def handle_push(_gen_queue, module, opts) when is_atom(module) do
    do_return(module, [], opts)
  end

  def handle_push(_gen_queue, {module}, opts) do
    do_return(module, [], opts)
  end

  def handle_push(_gen_queue, {module, args}, opts) do
    do_return(module, args, opts)
  end

  def setup_test(name \\ :gen_queue_opq) do
    set_process_receiver(name)
    Process.register(self(), name)
  end

  def set_process_receiver(name) when is_atom(name) do
    Application.put_env(:gen_queue_opq, :process_receiver, name)
  end

  def get_process_receiver do
    Application.get_env(:gen_queue_opq, :process_receiver, :gen_queue_opq)
  end

  defp do_return(module, args, opts) do
    job = {module, args, OPQAdapter.build_opts_map(opts)}
    process_name = get_process_receiver()
    if Process.whereis(process_name), do: send(process_name, job)
    {:ok, job}
  end
end

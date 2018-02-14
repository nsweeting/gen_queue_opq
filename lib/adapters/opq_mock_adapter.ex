defmodule GenQueue.OPQMockAdapter do
  use GenQueue.Adapter

  alias GenQueue.OPQAdapter

  def start_link(gen_queue, opts \\ []) do
    opts
    |> Keyword.merge(name: gen_queue)
    |> OPQ.init()
  end

  def handle_push(gen_queue, module, opts) when is_atom(module) do
    do_enqueue(gen_queue, module, [], opts)
  end

  def handle_push(gen_queue, {module}, opts) do
    do_enqueue(gen_queue, module, [], opts)
  end

  def handle_push(gen_queue, {module, args}, opts) do
    do_enqueue(gen_queue, module, args, opts)
  end

  defp do_enqueue(gen_queue, module, args, opts) do
    job = {module, args, OPQAdapter.build_opts_map(opts)}
    if Process.whereis(:gen_queue_opq), do: send(:gen_queue_opq, job)
    {:ok, job}
  end
end

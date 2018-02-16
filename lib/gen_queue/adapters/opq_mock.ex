defmodule GenQueue.Adapters.OPQMock do
  use GenQueue.Adapter

  alias GenQueue.Adapters.OPQ, as: OPQAdapter

  def start_link(gen_queue, opts \\ []) do
    opts
    |> Keyword.merge(name: gen_queue)
    |> OPQ.init()
  end

  def handle_push(gen_queue, module, opts) when is_atom(module) do
    do_return(gen_queue, module, [], opts)
  end

  def handle_push(gen_queue, {module}, opts) do
    do_return(gen_queue, module, [], opts)
  end

  def handle_push(gen_queue, {module, args}, opts) do
    do_return(gen_queue, module, args, opts)
  end

  defp do_return(gen_queue, module, args, opts) do
    job = {module, args, OPQAdapter.build_opts_map(opts)}
    GenQueue.Test.send_item(gen_queue, job)
    {:ok, job}
  end
end

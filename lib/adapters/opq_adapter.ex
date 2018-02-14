defmodule GenQueue.OPQAdapter do
  use GenQueue.Adapter

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

  def build_opts_map(opts) do
    Enum.into(opts, %{})
  end

  defp do_enqueue(gen_queue, module, args, opts) do
    case OPQ.enqueue(gen_queue, module, :perform, args) do
      :ok -> {:ok, {module, args, build_opts_map(opts)}}
      error -> error
    end
  end
end

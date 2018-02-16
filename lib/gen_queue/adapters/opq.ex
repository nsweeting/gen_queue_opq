defmodule GenQueue.Adapters.OPQ do
  @moduledoc """
  An adapter for `GenQueue` to enable functionaility with `OPQ`.
  """

  @type job :: module | {module} | {module, any}
  @type pushed_job :: {module, list, map}

  use GenQueue.Adapter

  def start_link(gen_queue, opts \\ []) do
    opts
    |> Keyword.merge(name: gen_queue)
    |> OPQ.init()
  end

  @doc """
  Push a job for OPQ to consume.

  ## Parameters:
    * `gen_queue` - Any GenQueue module
    * `job` - Any valid job format
    * `opts` - A keyword list of job options

  ## Returns:
    * `{:ok, {module, args, opts}}` if the operation was successful
    * `{:error, reason}` if there was an error
  """
  @spec handle_push(GenQueue.t(), GenQueue.Adapters.OPQ.job(), list) ::
          {:ok, GenQueue.Adapters.OPQ.pushed_job()} | {:error, any}
  def handle_push(gen_queue, job, opts) when is_atom(job) do
    do_enqueue(gen_queue, job, [], opts)
  end

  def handle_push(gen_queue, {job}, opts) do
    do_enqueue(gen_queue, job, [], opts)
  end

  def handle_push(gen_queue, {job, args}, opts) when is_list(args) do
    do_enqueue(gen_queue, job, args, opts)
  end

  def handle_push(gen_queue, {job, arg}, opts) do
    do_enqueue(gen_queue, job, [arg], opts)
  end

  @doc false
  def handle_pop(_gen_queue, _opts) do
    {:error, :not_implemented}
  end

  @doc false
  def handle_flush(_gen_queue, _opts) do
    {:error, :not_implemented}
  end

  @doc false
  def handle_length(_gen_queue, _opts) do
    {:error, :not_implemented}
  end

  @doc false
  def build_opts_map(opts) do
    Enum.into(opts, %{})
  end

  defp do_enqueue(gen_queue, job, args, opts) do
    case OPQ.enqueue(gen_queue, job, :perform, args) do
      :ok -> {:ok, {job, args, build_opts_map(opts)}}
      error -> error
    end
  end
end

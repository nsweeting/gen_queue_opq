defmodule GenQueue.Adapters.OPQMock do
  @moduledoc """
  An adapter for `GenQueue` to enable mock functionaility with `OPQ`.
  """

  use GenQueue.Adapter

  alias GenQueue.Adapters.OPQ, as: OPQAdapter

  def start_link(gen_queue, opts \\ []) do
    opts
    |> Keyword.merge(name: gen_queue)
    |> OPQ.init()
  end

  @doc """
  Push a job that will be returned to the current (or globally set) processes
  mailbox.
  
  Please see `GenQueue.Test` for further details.

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
  def handle_push(gen_queue, module, opts) when is_atom(module) do
    do_return(gen_queue, module, [], opts)
  end

  def handle_push(gen_queue, {module}, opts) do
    do_return(gen_queue, module, [], opts)
  end

  def handle_push(gen_queue, {module, args}, opts) do
    do_return(gen_queue, module, args, opts)
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

  defp do_return(gen_queue, module, args, opts) do
    job = {module, args, OPQAdapter.build_opts_map(opts)}
    GenQueue.Test.send_item(gen_queue, job)
    {:ok, job}
  end
end

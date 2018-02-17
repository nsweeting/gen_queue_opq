defmodule GenQueue.Adapters.OPQ do
  @moduledoc """
  An adapter for `GenQueue` to enable functionaility with `OPQ`.
  """

  use GenQueue.JobAdapter

  def start_link(gen_queue, opts \\ []) do
    opts
    |> Keyword.merge(name: gen_queue)
    |> OPQ.init()
  end

  @doc """
  Push a `GenQueue.Job` for OPQ to consume.

  ## Parameters:
    * `gen_queue` - A `GenQueue` module
    * `job` - A `GenQueue.Job`

  ## Returns:
    * `{:ok, job}` if the operation was successful
    * `{:error, reason}` if there was an error
  """
  def handle_job(gen_queue, job) do
    case OPQ.enqueue(gen_queue, job.module, :perform, job.args) do
      :ok -> {:ok, job}
      error -> error
    end
  end
end

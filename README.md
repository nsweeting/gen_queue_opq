# GenQueue OPQ
[![GenQueue OPQ Version](https://img.shields.io/hexpm/v/gen_queue_opq.svg)](https://hex.pm/packages/gen_queue_opq)

This is an adapter for [GenQueue](https://github.com/nsweeting/gen_queue) to enable
functionaility with [OPQ](https://github.com/fredwu/opq).

## Installation

The package can be installed by adding `gen_queue_opq` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gen_queue_opq, "~> 0.1.0"}
  ]
end
```

## Documentation

See [HexDocs](https://hexdocs.pm/gen_queue_opq) for additional documentation.

## Configuration

Before starting, please refer to the [OPQ](https://github.com/fredwu/opq) documentation
for details on configuration. This adapter handles zero `OPQ` related config.

## Creating Enqueuers

We can start off by creating a new `GenQueue` module, which we will use to push jobs to
Exq.

```elixir
defmodule Enqueuer do
  use GenQueue, otp_app: :my_app
end
```

Once we have our module setup, ensure we have our config pointing to the `GenQueue.Adapters.OPQ`
adapter.

```elixir
config :my_app, Enqueuer, [
  adapter: GenQueue.Adapters.OPQ
]
```

## Starting Enqueuers

By default, `gen_queue_opq` does not start OPQ on application start. So we must add
our new `Enqueuer` module to our supervision tree.

```elixir
  children = [
    supervisor(Enqueuer, []),
  ]
```

## Creating Jobs

Jobs are simply modules with a `perform` method.

```elixir
defmodule MyJob do
  def perform(arg1) do
    IO.inspect(arg1)
  end
end
```

## Enqueuing Jobs

We can now easily enqueue jobs to `OPQ`. The adapter will handle a variety of argument formats.

```elixir
# Push MyJob to queue
{:ok, job} = Enqueuer.push(MyJob)

# Push MyJob to queue
{:ok, job} = Enqueuer.push({MyJob})

# Push MyJob to queue with "arg1"
{:ok, job} = Enqueuer.push({MyJob, "arg1"})

# Push MyJob to queue with no args
{:ok, job} = Enqueuer.push({MyJob, []})

# Push MyJob to queue with "arg1" and "arg2"
{:ok, job} = Enqueuer.push({MyJob, ["arg1", "arg2"]})
```

## Testing

Optionally, we can also have our tests use the `GenQueue.Adapters.OPQMock` adapter.

```elixir
config :my_app, Enqueuer, [
  adapter: GenQueue.Adapters.OPQMock
]
```

This mock adapter uses the standard `GenQueue.Test` helpers to send the job payload
back to the current processes mailbox (or another named process) instead of actually
enqueuing the job to redis.

```elixir
defmodule MyJobTest do
  use ExUnit.Case, async: true

  import GenQueue.Test

  setup do
    setup_test_queue(Enqueuer)
  end

  test "my enqueuer works" do
    {:ok, _} = Enqueuer.push(Job)
    assert_receive({Job, [], %{jid: _}})
  end
end
```

If your jobs are being enqueued outside of the current process, we can use named
processes to recieve the job. This wont be async safe.

```elixir
import GenQueue.Test

setup do
  setup_global_test_queue(Enqueuer, :my_process_name)
end
```

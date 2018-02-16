defmodule GenQueueOpq.MixProject do
  use Mix.Project

  def project do
    [
      app: :gen_queue_opq,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_queue, git: "https://github.com/nsweeting/gen_queue.git"},
      {:opq, "~> 3.0", runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end
end

defmodule SelectoLivebooks.NotebookVerifier do
  @moduledoc false

  def run(path) do
    path = Path.expand(path)
    source = File.read!(path)

    cells =
      Regex.scan(~r/^```elixir\s*\n(.*?)^```\s*$/ms, source, capture: :all_but_first)
      |> Enum.map(&hd/1)

    if cells == [] do
      raise ArgumentError, "no Elixir cells found in #{path}"
    end

    cells
    |> Enum.with_index(1)
    |> Enum.reduce({[], Code.env_for_eval(file: path)}, fn {cell, index}, {binding, env} ->
      IO.puts("RUN #{Path.basename(path)} cell #{index}/#{length(cells)}")
      ast = Code.string_to_quoted!(cell, file: path)
      {_result, next_binding, next_env} = Code.eval_quoted_with_env(ast, binding, env)
      {next_binding, next_env}
    end)

    IO.puts("PASS #{Path.relative_to_cwd(path)} (#{length(cells)} Elixir cells)")
  end
end

case System.argv() do
  [path] ->
    SelectoLivebooks.NotebookVerifier.run(path)

  _ ->
    IO.puts(:stderr, "usage: elixir scripts/verify_notebook.exs PATH.livemd")
    System.halt(64)
end

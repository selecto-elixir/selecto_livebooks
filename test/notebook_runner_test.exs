defmodule SelectoLivebooks.NotebookRunnerTest do
  use ExUnit.Case, async: true

  @runner Path.expand("../scripts/verify_notebook.exs", __DIR__)

  test "runner preserves bindings, aliases and imports across cells" do
    source = """
    # Runner fixture

    ```elixir
    alias String, as: Text
    ```

    ```elixir
    import Enum, only: [map: 2]
    numbers = [1, 2]
    ```

    ```elixir
    ["1", "2"] = map(numbers, &to_string/1)
    "OK" = Text.upcase("ok")
    ```
    """

    {output, status} = run_fixture(source)
    assert status == 0, output
    assert output =~ "3 Elixir cells"
  end

  test "runner stops at the failing cell and returns nonzero" do
    source = """
    # Failure fixture

    ```elixir
    :ok
    ```

    ```elixir
    raise "deliberate notebook failure"
    ```

    ```elixir
    IO.puts("SHOULD NOT RUN")
    ```
    """

    {output, status} = run_fixture(source)
    assert status != 0
    assert output =~ "cell 2/3"
    assert output =~ "deliberate notebook failure"
    refute output =~ "SHOULD NOT RUN"
    refute output =~ "PASS "
  end

  defp run_fixture(source) do
    token = Base.url_encode64(:crypto.strong_rand_bytes(12), padding: false)
    path = Path.join(System.tmp_dir!(), "livebook-runner-#{token}.livemd")

    File.write!(path, source, [:exclusive])
    on_exit(fn -> File.rm!(path) end)
    System.cmd(System.find_executable("elixir"), [@runner, path], stderr_to_stdout: true)
  end
end

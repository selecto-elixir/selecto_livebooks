defmodule SelectoExamplesTest do
  use ExUnit.Case
  doctest SelectoExamples

  test "greets the world" do
    assert SelectoExamples.hello() == :world
  end
end

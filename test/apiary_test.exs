defmodule ApiaryTest do
  use ExUnit.Case
  doctest Apiary

  test "greets the world" do
    assert Apiary.hello() == :world
  end
end

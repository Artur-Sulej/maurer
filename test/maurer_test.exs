defmodule MaurerTest do
  use ExUnit.Case
  doctest Maurer

  test "greets the world" do
    assert Maurer.hello() == :world
  end
end

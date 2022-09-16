defmodule ApiaryTest do
  use ExUnit.Case

  test "Utils.skipEmpty skips empty strings from list" do
    list = ["", "a", "", "b", "c", ""]
    assert ["a", "b", "c"] == Utils.skipEmpty(list)
  end

  test "Utils.safeIntParse returns replacement value" do
    assert :rep == Utils.safeIntParse("a", :rep)
  end

  test "Utils.safeIntParse returns integer value" do
    assert 1 == Utils.safeIntParse("1", :rep)
  end

  test "Utils.toInt returns integer value" do
    assert 1 == Utils.toInt("1")
  end

  test "Utils.toInt returns original value" do
    assert "a" == Utils.toInt("a")
  end

  test "Entities.createBoat creates boat" do
    boat = Entities.createBoat(1, 1, "д. тест", "Аврора", 1, 1)
    assert "Аврора" == boat["name"]
    assert "д. тест" == boat["dest"]
  end

  test "Entities.createPlane creates plane" do
    plane = Entities.createPlane(1, 1, "д. тест", "Су", 1, 1)
    assert "Су" == plane["name"]
    assert "д. тест" == plane["dest"]
  end

  test "Entities.createTrain creates train" do
    train = Entities.createTrain(1, 1, "д. тест", "Сапсан", 1)
    assert "Сапсан" == train["name"]
    assert "д. тест" == train["dest"]
  end

  test "LineExecutor.processLines dowsn't choke on empty list" do
    assert :ok == LineExecutor.processLines([])
  end

  test "LineExecutor.processLines processes lines" do
    assert :ok == LineExecutor.processLines(["ADD train Сапсан 1 1 1 д. тест"])
  end
end

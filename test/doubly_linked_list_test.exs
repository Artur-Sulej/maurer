defmodule DoublyLinkedListTest do
  use ExUnit.Case

  test "Appending and fetching items" do
    DoublyLinkedList.init(:my_ddl)
    DoublyLinkedList.append_head(:my_ddl, "Value A")
    DoublyLinkedList.append_head(:my_ddl, "Value B")
    DoublyLinkedList.append_head(:my_ddl, "Value C")

    item_1_id = DoublyLinkedList.get_head_id(:my_ddl)

    assert %{next: nil, prev: item_2_id, value: "Value C"} =
             DoublyLinkedList.get_item(:my_ddl, item_1_id)

    assert %{next: ^item_1_id, prev: item_3_id, value: "Value B"} =
             DoublyLinkedList.get_item(:my_ddl, item_2_id)

    assert %{next: ^item_2_id, prev: nil, value: "Value A"} =
             DoublyLinkedList.get_item(:my_ddl, item_3_id)
  end
end

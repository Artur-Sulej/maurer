defmodule SinglyLinkedListTest do
  use ExUnit.Case

  test "Appending and fetching items" do
    SinglyLinkedList.init(:my_ddl)
    SinglyLinkedList.append_tail(:my_ddl, "Value A")
    SinglyLinkedList.append_tail(:my_ddl, "Value B")
    SinglyLinkedList.append_tail(:my_ddl, "Value C")

    item_1_id = SinglyLinkedList.get_head_id(:my_ddl)
    assert %{next: item_2_id, value: "Value A"} = SinglyLinkedList.get_item(:my_ddl, item_1_id)
    assert %{next: item_3_id, value: "Value B"} = SinglyLinkedList.get_item(:my_ddl, item_2_id)
    assert %{next: nil, value: "Value C"} = SinglyLinkedList.get_item(:my_ddl, item_3_id)
  end
end

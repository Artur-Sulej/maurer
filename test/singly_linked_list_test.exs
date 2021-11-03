defmodule SinglyLinkedListTest do
  use ExUnit.Case

  test "Appending and fetching items" do
    SinglyLinkedList.init(:my_ddl)
    SinglyLinkedList.append_tail("Value A", :my_ddl)
    SinglyLinkedList.append_tail("Value B", :my_ddl)
    SinglyLinkedList.append_tail("Value C", :my_ddl)

    item_1_id = SinglyLinkedList.get_head_id(:my_ddl)
    assert %{next: item_2_id, value: "Value A"} = SinglyLinkedList.get_item(item_1_id, :my_ddl)
    assert %{next: item_3_id, value: "Value B"} = SinglyLinkedList.get_item(item_2_id, :my_ddl)
    assert %{next: nil, value: "Value C"} = SinglyLinkedList.get_item(item_3_id, :my_ddl)
  end
end

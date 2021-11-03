defmodule Maurer.MessagesLogTest do
  use ExUnit.Case
  alias Maurer.MessagesLog

  test "Appending and fetching items" do
    MessagesLog.init_topic(:my_topic)
    MessagesLog.append_tail("Value A", :my_topic)
    MessagesLog.append_tail("Value B", :my_topic)
    MessagesLog.append_tail("Value C", :my_topic)

    item_1_id = MessagesLog.get_head_id(:my_topic)
    assert %{next: item_2_id, value: "Value A"} = MessagesLog.get_item(item_1_id, :my_topic)
    assert %{next: item_3_id, value: "Value B"} = MessagesLog.get_item(item_2_id, :my_topic)
    assert %{next: nil, value: "Value C"} = MessagesLog.get_item(item_3_id, :my_topic)
  end
end

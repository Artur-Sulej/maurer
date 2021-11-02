defmodule DoublyLinkedList.Item do
  def build(value, neighbours \\ %{next: nil, prev: nil})

  def build(value, %{next: next, prev: prev}) do
    item_id = UUID.uuid4()
    {item_id, %{value: value, next: next, prev: prev}}
  end

  def update_prev(item, prev) do
    %{item | prev: prev}
  end

  def update_next(item, next) do
    %{item | next: next}
  end

  def get_value(item) do
    item.value
  end

  def get_next(item) do
    item.next
  end

  def get_prev(item) do
    item.prev
  end

  def head?(item) do
    get_next(item) == nil
  end

  def tail?(item) do
    get_prev(item) == nil
  end
end

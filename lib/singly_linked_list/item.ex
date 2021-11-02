defmodule SinglyLinkedList.Item do
  def build(value, next \\ nil)

  def build(value, next) do
    item_id = UUID.uuid4()
    {item_id, %{value: value, next: next}}
  end

  def update_next(item, next) do
    %{item | next: next}
  end
end

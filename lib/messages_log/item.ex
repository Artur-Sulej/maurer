defmodule Maurer.MessagesLog.Item do
  def build(value, next \\ nil) do
    item_id = UUID.uuid4()
    {item_id, %{value: value, next: next}}
  end
end

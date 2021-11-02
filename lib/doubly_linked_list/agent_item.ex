defmodule DoublyLinkedList.AgentItem do
  def create(value, next \\ nil, prev \\ nil) do
    item_id =
      UUID.uuid4()
      |> String.to_atom()

    Agent.start_link(
      fn -> %{next: next, prev: prev, value: value} end,
      name: item_id
    )

    item_id
  end

  def update_prev(item_id, prev) do
    Agent.update(
      item_id,
      fn state -> %{state | prev: prev} end
    )
  end

  def update_next(item_id, next) do
    Agent.update(
      item_id,
      fn state -> %{state | next: next} end
    )
  end

  def get_value(item_id) do
    get_from_state(item_id, :value)
  end

  def get_next(item_id) do
    get_from_state(item_id, :next)
  end

  def get_prev(item_id) do
    get_from_state(item_id, :prev)
  end

  def head?(item_id) do
    get_next(item_id) == nil
  end

  def tail?(item_id) do
    get_prev(item_id) == nil
  end

  defp get_from_state(item_id, key) do
    Agent.get(item_id, fn state -> state[key] end)
  end
end

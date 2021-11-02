defmodule SinglyLinkedList do
  alias SinglyLinkedList.Item

  def init(list_id) do
    Agent.start_link(
      fn -> %{head_id: nil, tail_id: nil, map: %{}} end,
      name: list_id
    )

    list_id
  end

  def append_tail(list_id, value) do
    Agent.update(
      list_id,
      fn
        %{head_id: nil} ->
          {new_item_id, new_item} = Item.build(value)
          %{head_id: new_item_id, tail_id: new_item_id, map: %{new_item_id => new_item}}

        %{head_id: head_id, tail_id: old_tail_id, map: old_map} ->
          {new_item_id, new_item} = Item.build(value)

          new_map =
            old_map
            |> put_in([old_tail_id, :next], new_item_id)
            |> put_in([new_item_id], new_item)

          %{head_id: head_id, tail_id: new_item_id, map: new_map}
      end
    )
  end

  def get_item(list_id, item_id) do
    Agent.get(list_id, fn %{map: map} -> map[item_id] end)
  end

  def get_head_id(list_id) do
    Agent.get(list_id, fn state -> state.head_id end)
  end

  def get_tail_id(list_id) do
    Agent.get(list_id, fn state -> state.tail_id end)
  end
end

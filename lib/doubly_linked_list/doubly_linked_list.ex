defmodule DoublyLinkedList do
  alias DoublyLinkedList.AgentItem

  def create(list_id) do
    Agent.start_link(
      fn -> %{head: nil, tail: nil} end,
      name: list_id
    )
  end

  def add_head(list_id, value) do
    Agent.update(
      list_id,
      fn
        %{head: nil} ->
          new_item = AgentItem.create(value)
          %{head: new_item, tail: new_item}

        %{head: old_head, tail: tail} ->
          new_head = AgentItem.create(value, nil, old_head)
          AgentItem.update_next(old_head, new_head)
          %{head: new_head, tail: tail}
      end
    )
  end

  def add_tail(list_id, value) do
    Agent.update(
      list_id,
      fn
        %{tail: nil} ->
          new_item = AgentItem.create(value)
          %{head: new_item, tail: new_item}

        %{tail: old_tail, head: head} ->
          new_tail = AgentItem.create(value, nil, old_tail)
          AgentItem.update_prev(old_tail, new_tail)
          %{tail: new_tail, head: head}
      end
    )
  end

  def get_head(list_id) do
    Agent.get(list_id, fn state -> state.head end)
  end

  def get_tail(list_id) do
    Agent.get(list_id, fn state -> state.tail end)
  end
end

defmodule Maurer.MessagesLog do
  alias Maurer.MessagesLog.Item

  def init_topic(topic) do
    Agent.start_link(
      fn -> %{head_id: nil, tail_id: nil, map: %{}} end,
      name: agent_name(topic)
    )

    topic
  end

  def append_tail(value, topic) do
    Agent.update(
      agent_name(topic),
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

  def get_item(item_id, topic) do
    Agent.get(agent_name(topic), fn %{map: map} -> map[item_id] end)
  end

  def get_state(topic) do
    Agent.get(agent_name(topic), fn state -> state end)
  end

  def get_head_id(topic) do
    Agent.get(agent_name(topic), fn state -> state.head_id end)
  end

  def get_tail_id(topic) do
    Agent.get(agent_name(topic), fn state -> state.tail_id end)
  end

  defp agent_name(topic), do: String.to_atom("#{__MODULE__}.#{topic}")
end

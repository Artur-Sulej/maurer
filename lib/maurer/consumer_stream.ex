defmodule Maurer.Consumer.Stream do
  alias Maurer.MessagesLog

  def stream(topics) do
    topics
    |> Enum.map(fn topic -> {:next, nil, topic} end)
    |> Stream.unfold(fn prev_states -> next_step(prev_states) end)
    |> Stream.flat_map(& &1)
    |> Stream.reject(&is_nil/1)
  end

  defp next_step(prev_states) do
    results =
      prev_states
      |> Enum.map(fn {status, item_id, topic} ->
        Task.async(fn -> next_item(status, item_id, topic) end)
      end)
      |> Enum.map(&Task.await/1)

    values = Enum.map(results, fn {value, _} -> value end)
    states = Enum.map(results, fn {_, state} -> state end)
    {values, states}
  end

  defp next_item(status, item_id, topic) do
    item_id = item_id || MessagesLog.get_head_id(topic)

    with item_id when not is_nil(item_id) <- item_id,
         %{next: next_item_id, value: value} <- MessagesLog.get_item(item_id, topic) do
      new_state(status, item_id, next_item_id, value, topic)
    else
      nil -> {nil, {:next, nil, topic}}
    end
  end

  defp new_state(status, item_id, next_item_id, value, topic) do
    case {status, next_item_id} do
      {:next, nil} ->
        {value, {:tail, item_id, topic}}

      {:next, next_item_id} ->
        {value, {:next, next_item_id, topic}}

      {:tail, nil} ->
        {nil, {:tail, item_id, topic}}

      {:tail, next_item_id} ->
        next_item(:next, next_item_id, topic)
    end
  end
end

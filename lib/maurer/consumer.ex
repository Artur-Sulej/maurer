defmodule Maurer.Consumer do
  alias Maurer.MessagesLog

  def stream(topic) do
    Stream.unfold(
      {:next, nil},
      fn
        {status, item_id} ->
          item_id = item_id || MessagesLog.get_head_id(topic)

          with item_id when not is_nil(item_id) <- item_id,
               %{next: next_item_id, value: value} <- MessagesLog.get_item(item_id, topic) do
            next_fun(status, item_id, next_item_id, value)
          else
            nil -> {nil, {:next, nil}}
          end
      end
    )
    |> Stream.reject(&is_nil/1)
  end

  defp next_fun(status, item_id, next_item_id, value) do
    case {status, next_item_id} do
      {:next, nil} ->
        {value, {:tail, item_id}}

      {:next, next_item_id} ->
        {value, {:next, next_item_id}}

      {:tail, nil} ->
        {nil, {:tail, item_id}}

      {:tail, next_item_id} ->
        {nil, {:next, next_item_id}}
    end
  end
end

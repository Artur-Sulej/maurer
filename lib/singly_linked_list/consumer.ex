defmodule Consumer do
  def stream(list_id, consume_fun \\ nil) do
    Stream.unfold(
      {:next, nil},
      fn
        {status, item_id} ->
          item_id = item_id || SinglyLinkedList.get_head_id(list_id)

          with item_id when not is_nil(item_id) <- item_id,
               %{next: next_item_id, value: value} <- SinglyLinkedList.get_item(item_id, list_id) do
            next_fun(status, item_id, next_item_id, value, consume_fun)
          else
            nil -> {nil, {:next, nil}}
          end
      end
    )
    |> Stream.reject(&is_nil/1)
  end

  defp next_fun(status, item_id, next_item_id, value, consume_fun) do
    case {status, next_item_id} do
      {:next, nil} ->
        if consume_fun, do: consume_fun.(value)
        {value, {:tail, item_id}}

      {:next, next_item_id} ->
        if consume_fun, do: consume_fun.(value)
        {value, {:next, next_item_id}}

      {:tail, nil} ->
        {nil, {:tail, item_id}}

      {:tail, next_item_id} ->
        {nil, {:next, next_item_id}}
    end
  end
end

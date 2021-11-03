defmodule Consumer do
  @list_id :kalafior

  def stream do
    Stream.unfold(
      {:next, nil},
      fn
        {status, item_id} ->
          item_id = item_id || SinglyLinkedList.get_head_id(@list_id)

          with item_id when not is_nil(item_id) <- item_id,
               %{next: next_item_id, value: value} <- SinglyLinkedList.get_item(item_id, @list_id) do
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
        consume(value)
        {value, {:tail, item_id}}

      {:next, next_item_id} ->
        consume(value)
        {value, {:next, next_item_id}}

      {:tail, nil} ->
        {nil, {:tail, item_id}}

      {:tail, next_item_id} ->
        {nil, {:next, next_item_id}}
    end
  end

  defp consume(value) do
    IO.puts("--- #{inspect(value)} ---")
  end
end

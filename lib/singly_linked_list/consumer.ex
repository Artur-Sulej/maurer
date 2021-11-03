defmodule Consumer do
  @list_id :kalafior

  def stream do
    Stream.unfold(
      {:next, SinglyLinkedList.get_head_id(@list_id)},
      fn
        {:next, nil} ->
          {nil, {:next, SinglyLinkedList.get_head_id(@list_id)}}

        {status, item_id} ->
          %{next: next_item_id, value: value} = SinglyLinkedList.get_item(item_id, @list_id)

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
    )
    |> Stream.reject(&is_nil/1)
  end

  def listen do
    stream() |> Stream.run()
  end

  defp consume(value) do
    IO.puts("--- #{inspect(value)} ---")
  end
end

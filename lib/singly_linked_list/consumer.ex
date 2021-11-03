defmodule Consumer do
  @list_id :kalafior

  def stream do
    Stream.unfold(
      {:next, SinglyLinkedList.get_head_id(@list_id)},
      fn
        {status, item_id} ->
          item_id = item_id || SinglyLinkedList.get_head_id(@list_id)
          next_fun(status, item_id)
      end
    )
    |> Stream.reject(&is_nil/1)
  end

  defp next_fun(:next, nil) do
    {nil, {:next, nil}}
  end

  defp next_fun(status, item_id) do
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

  def listen do
    stream() |> Stream.run()
  end

  defp consume(value) do
    IO.puts("--- #{inspect(value)} ---")
  end
end

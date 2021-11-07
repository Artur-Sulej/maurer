defmodule Maurer.Consumer.GenServer do
  defmacro __using__(_opts) do
    quote do
      alias Maurer.MessagesLog
      use GenServer

      import Maurer.Consumer.GenServer

      # Client

      def start_link(topic) do
        {:ok, _} =
          GenServer.start_link(__MODULE__, %{status: :next, item_id: nil, topic: topic},
            name: topic
          )
      end

      # Server (callbacks)

      @impl true
      def init(state) do
        schedule_next_message()
        {:ok, state}
      end

      defp schedule_next_message do
        Process.send(self(), :next_message, [])
      end

      @impl true
      def handle_info(:next_message, %{status: status, item_id: item_id, topic: topic}) do
        {value, {new_status, next_item_id, topic}} = next_item(status, item_id, topic)
        unless is_nil(value), do: consume(value)
        schedule_next_message()
        {:noreply, %{status: new_status, item_id: next_item_id, topic: topic}}
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
  end
end

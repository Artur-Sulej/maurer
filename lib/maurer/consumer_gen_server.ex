defmodule Maurer.Consumer.GenServer do
  defmacro __using__(_opts) do
    quote do
      alias Maurer.MessagesLog
      use GenServer

      import Maurer.Consumer.GenServer

      # Client

      def start_link(topics) when is_list(topics) do
        state =
          topics
          |> Enum.map(fn topic ->
            {topic, %{status: :next, item_id: nil}}
          end)
          |> Enum.into(%{})

        {:ok, _} = GenServer.start_link(__MODULE__, state, name: String.to_atom(inspect(topics)))
      end

      # Server (callbacks)

      @impl true
      def init(state) do
        state
        |> Map.keys()
        |> Enum.each(&schedule_next_message/1)

        {:ok, state}
      end

      defp schedule_next_message(topic) do
        Process.send(self(), {:next_message, topic}, [])
      end

      @impl true
      def handle_info({:next_message, topic}, state) do
        topic_state = state[topic]

        {value, {new_status, next_item_id, topic}} =
          next_item(topic_state.status, topic_state.item_id, topic)

        unless is_nil(value), do: consume(value)
        new_state = put_in(state, [topic], %{status: new_status, item_id: next_item_id})
        schedule_next_message(topic)
        {:noreply, new_state}
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

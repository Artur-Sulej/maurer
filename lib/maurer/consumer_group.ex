defmodule Maurer.Consumer.ConsumerGroup do
  defmacro __using__(opts) do
    topic = Keyword.fetch!(opts, :topic)
    consumers_count = Keyword.get(opts, :consumers_count, 1)

    quote do
      use Maurer.Consumer.GenServer

      def consume(value) do
        value
      end

      defoverridable consume: 1

      def children_spec do
        0..(unquote(consumers_count) - 1)
        |> Enum.map(fn i ->
          process_name = String.to_atom("#{__MODULE__}.#{i}")

          %{
            id: {__MODULE__, i},
            start: {__MODULE__, :start_link, [:"#{unquote(topic)}_#{i}"]},
            name: process_name
          }
        end)
      end
    end
  end
end

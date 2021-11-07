defmodule Maurer.Consumer.ConsumerGroup do
  defmacro __using__(opts) do
    topic = Keyword.fetch!(opts, :topic)
    partitions_count = Keyword.fetch!(opts, :partitions_count)
    consumers_count = Keyword.get(opts, :consumers_count, 1)

    if consumers_count > partitions_count do
      raise("Consumers cannot exceed number of partitions")
    end

    quote do
      use Maurer.Consumer.GenServer

      def consume(value) do
        value
      end

      defoverridable consume: 1

      def children_spec do
        consumers_distributions
        |> consumers_names
        |> Enum.map(fn {process_name, topics} ->
          %{
            id: {__MODULE__, process_name},
            start: {__MODULE__, :start_link, [topics]},
            name: process_name
          }
        end)
      end

      defp consumers_distributions do
        unquoted_consumers_count = unquote(consumers_count)
        unquoted_partitions_count = unquote(partitions_count)

        init_acc =
          0..(unquoted_consumers_count - 1)
          |> Enum.map(&{&1, []})
          |> Enum.into(%{})

        0..(unquoted_partitions_count - 1)
        |> Enum.reduce(
          init_acc,
          fn partition_num, acc ->
            consumer_num = rem(partition_num, unquoted_consumers_count)
            update_in(acc, [consumer_num], &[partition_num | &1])
          end
        )
        |> Map.values()
      end

      defp consumers_names(distributions) do
        unquoted_topic = unquote(topic)

        Enum.map(distributions, fn partition_nums ->
          partition_nums_joined = Enum.join(partition_nums, "_")
          process_name = String.to_atom("#{__MODULE__}.#{partition_nums_joined}")

          topics =
            Enum.map(partition_nums, fn partition_num -> :"#{unquoted_topic}_#{partition_num}" end)

          {process_name, topics}
        end)
      end
    end
  end
end

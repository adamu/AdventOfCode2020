defmodule Day16Part2 do
  def run do
    {rules, my_ticket, tickets} = File.read!("input") |> parse_input()

    tickets
    |> Enum.filter(&valid?(&1, rules))
    |> transpose_tickets()
    |> valid_fields_for_columns(rules)
    |> reduce_to_column_by_field_name()
    |> Stream.filter(&match?({"departure" <> _, _idx}, &1))
    |> Stream.map(fn {_name, idx} -> my_ticket[idx] end)
    |> Enum.reduce(&Kernel.*/2)
    |> IO.puts()
  end

  def valid?(ticket, rules) do
    Enum.all?(ticket, fn field ->
      Enum.any?(rules, fn {_name, {range1, range2}} -> field in range1 || field in range2 end)
    end)
  end

  def transpose_tickets(tickets), do: tickets |> Enum.zip() |> Enum.map(&Tuple.to_list/1)

  # Compare each column against the rules to determine the list of fields each column satisfies
  def valid_fields_for_columns(transposed_tickets, rules) do
    for {column, idx} <- Enum.with_index(transposed_tickets) do
      {valid_fields_for(column, rules), idx}
    end
  end

  # Reduce the list of valid fields by elimination.
  # The number of valid fields for each column is unique, which doesn't seem like a coincidence.
  # Start with the column that only has one possible valid field, mark the field as seen.
  # Continue to the column with two valid fields, subtract the seen field, mark remaining field as seen.
  # Repeat for all columns.
  def reduce_to_column_by_field_name(valid_fields_by_column) do
    valid_fields_by_column
    |> Enum.sort_by(fn {fields, _idx} -> length(fields) end)
    |> Enum.map_reduce([], fn {fields, idx}, seen ->
      [field] = fields -- seen
      {{field, idx}, [field | seen]}
    end)
    |> elem(0)
  end

  def valid_fields_for(column, rules) do
    Enum.filter(rules, fn {_field, {range1, range2}} ->
      Enum.all?(column, fn val -> val in range1 || val in range2 end)
    end)
    |> Enum.map(&elem(&1, 0))
  end

  def parse_input(input) do
    [rules, [_, my_ticket | _], [_ | nearby_tickets]] =
      input
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))

    rules = Enum.map(rules, &parse_rule/1)

    [my_ticket | nearby_tickets] =
      [my_ticket | nearby_tickets]
      |> Enum.map(fn ticket -> String.split(ticket, ",") |> Enum.map(&String.to_integer/1) end)

    my_ticket = my_ticket |> Enum.with_index() |> Map.new(fn {val, idx} -> {idx, val} end)

    {rules, my_ticket, nearby_tickets}
  end

  def parse_rule(rule) do
    [name | ranges] =
      Regex.run(~r/\A(.*): (\d+)-(\d+) or (\d+)-(\d+)\z/, rule, capture: :all_but_first)

    [a, b, c, d] = Enum.map(ranges, &String.to_integer/1)
    {name, {a..b, c..d}}
  end
end

Day16Part2.run()

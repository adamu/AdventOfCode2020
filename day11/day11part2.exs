defmodule Day11Part2 do
  def run do
    File.read!("input")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
    |> parse_seat_plan()
    |> run_until_stable()
    |> count_occupied()
    |> IO.inspect()
  end

  def run_until_stable(seats) do
    new_seats = tick(seats)

    if new_seats == seats do
      seats
    else
      run_until_stable(new_seats)
    end
  end

  def tick(seats) do
    Map.new(seats, fn {{x, y}, old_seat} -> toggle(old_seat, x, y, seats) end)
  end

  def toggle(:empty, x, y, seats) do
    new_value =
      if occupied_visible(x, y, seats) == 0 do
        :occupied
      else
        :empty
      end

    {{x, y}, new_value}
  end

  def toggle(:occupied, x, y, seats) do
    new_value =
      if occupied_visible(x, y, seats) >= 5 do
        :empty
      else
        :occupied
      end

    {{x, y}, new_value}
  end

  def toggle(:floor, x, y, _), do: {{x, y}, :floor}

  def occupied_visible(x, y, seats) do
    directions = [
      {-1, -1},
      {-1, 0},
      {-1, +1},
      {0, -1},
      {0, +1},
      {+1, -1},
      {+1, 0},
      {+1, +1}
    ]

    Enum.count(directions, fn {vx, vy} -> check_visible_in_direction(x, y, vx, vy, 1, seats) end)
  end

  def count_occupied(seats) do
    Enum.count(seats, &match?({_, :occupied}, &1))
  end

  def check_visible_in_direction(x, y, vx, vy, distance, seats) do
    next = seats[{x + vx * distance, y + vy * distance}]

    case next do
      nil -> false
      :empty -> false
      :occupied -> true
      :floor -> check_visible_in_direction(x, y, vx, vy, distance + 1, seats)
    end
  end

  def parse_seat_plan(input) do
    {_, seats} =
      Enum.reduce(input, {0, %{}}, fn row, {y, seats} ->
        {_, seats} =
          Enum.reduce(row, {0, seats}, fn seat, {x, seats} ->
            seat =
              case seat do
                ?L -> :empty
                ?. -> :floor
                ?# -> :occupied
              end

            {x + 1, Map.put(seats, {x, y}, seat)}
          end)

        {y + 1, seats}
      end)

    seats
  end
end

Day11Part2.run()

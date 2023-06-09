defmodule Airports do
  alias NimbleCSV.RFC4180, as: CSV

  def airports_csv() do
    Application.app_dir(:airports, "/priv/airports.csv")
  end

  def open_airports_1() do
    # tc: 1_218_463
    airports_csv()
    |> File.read!()
    |> CSV.parse_string()
    |> Enum.map(fn row -> %{
      id: Enum.at(row, 0),
      type: Enum.at(row, 2),
      name: Enum.at(row, 3),
      country: Enum.at(row, 8)
    } end)
    |> Enum.reject(&(&1.type == "closed"))
    |> Enum.filter(&(&1.country == "BR"))
  end

  def open_airports_2() do
    # tc: 987_995
    airports_csv()
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(fn row -> %{
      id: :binary.copy(Enum.at(row, 0)),
      type: :binary.copy(Enum.at(row, 2)),
      name: :binary.copy(Enum.at(row, 3)),
      country: :binary.copy(Enum.at(row, 8))
    } end)
    |> Stream.reject(&(&1.type == "closed"))
    |> Stream.filter(&(&1.country == "BR"))
    |> Enum.to_list()
  end

  def open_airports_3() do
    # tc: 692_616
    airports_csv()
    |> File.stream!()
    |> CSV.parse_stream()
    |> Flow.from_enumerable()
    |> Flow.map(fn row -> %{
      id: :binary.copy(Enum.at(row, 0)),
      type: :binary.copy(Enum.at(row, 2)),
      name: :binary.copy(Enum.at(row, 3)),
      country: :binary.copy(Enum.at(row, 8))
    } end)
    |> Flow.reject(&(&1.type == "closed"))
    |> Flow.filter(&(&1.country == "BR"))
    |> Enum.to_list()
  end

  def open_airports_4() do
    # tc: 91_521
    airports_csv()
    |> File.stream!()
    |> Flow.from_enumerable()
    |> Flow.map(fn row ->
      [row] = CSV.parse_string(row, skip_headers: false)

      %{
        id: Enum.at(row, 0),
        type: Enum.at(row, 2),
        name: Enum.at(row, 3),
        country: Enum.at(row, 8)
      }
     end)
    |> Flow.reject(&(&1.type == "closed"))
    |> Flow.filter(&(&1.country == "BR"))
    |> Enum.to_list()
  end
end

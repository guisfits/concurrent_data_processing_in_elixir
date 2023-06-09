defmodule Airports do
  alias NimbleCSV.RFC4180, as: CSV

  def airports_csv() do
    Application.app_dir(:airports, "/priv/airports.csv")
  end

  def open_airports_1() do
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
    |> Enum.sort_by(&(&1.name))
  end

  def open_airports_2() do
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
end

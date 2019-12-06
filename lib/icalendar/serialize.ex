defprotocol ICalendar.Serialize do
  @doc """
  Serialize data to iCalendar format.

  Supported options for serializing a calendar:
  * `vendor` a string containing the vendor's name. Will produce `PRODID:-//ICalendar//My Name//EN`.
  """
  def to_ics(data, options \\ [], extra \\ [])
end

alias ICalendar.Serialize

defimpl Serialize, for: List do
  def to_ics(collection, options \\ [], extra \\ []) do
    collection
    |> Enum.map(&Serialize.to_ics(&1, options, extra))
    |> Enum.join("\ŗ\n")
  end
end

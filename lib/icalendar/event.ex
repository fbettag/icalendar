defmodule ICalendar.Event do
  @moduledoc """
  Calendars have events.
  """

  defstruct summary: nil,
            dtstart: nil,
            dtend: nil,
            dtstamp: nil,
            description: nil,
            location: nil,
            url: nil,
            uid: nil,
            prodid: nil,
            status: nil,
            categories: nil,
            class: nil,
            comment: nil,
            geo: nil
end

defimpl ICalendar.Serialize, for: ICalendar.Event do
  alias ICalendar.Util.KV

  def to_ics(event, _options \\ [], _extra \\ []) do
    contents = to_kvs(event)

    """
    BEGIN:VEVENT\r
    #{contents}END:VEVENT\r
    """
  end

  defp to_kvs(event) do
    event
    |> Map.from_struct()
    |> Enum.map(&to_kv/1)
    |> Enum.sort()
    |> Enum.join()
  end

  defp to_kv({key, value}) do
    name = key |> to_string |> String.upcase()
    KV.build(name, value)
  end
end

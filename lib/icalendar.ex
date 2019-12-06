defmodule ICalendar do
  @moduledoc """
  Generating ICalendars
  """

  defstruct events: []
  defdelegate to_ics(events, options \\ [], extra \\ []), to: ICalendar.Serialize
  defdelegate from_ics(events), to: ICalendar.Deserialize

  @doc """
  To create a Phoenix/Plug controller and view that output ics format:
  Add to your config.exs:
  ```
  config :phoenix, :format_encoders,
    ics: ICalendar
  ```
  In your controller use:
  `
    calendar = %ICalendar{ events: events }
    render(conn, "index.ics", calendar: calendar)
  `
  The important part here is `.ics`. This triggers the `format_encoder`.

  In your view can put:
  ```
  def render("index.ics", %{calendar: calendar}) do
    calendar
  end
  ```
  """
  def encode_to_iodata(calendar, options \\ [], _extra \\ []) do
    {:ok, encode_to_iodata!(calendar, options)}
  end

  def encode_to_iodata!(calendar, _options \\ []) do
    to_ics(calendar)
  end
end

defimpl ICalendar.Serialize, for: ICalendar do
  @doc """
  This function serializes the calendar into the iCalendar format.
  It also provides functionality to add extra parameters to the ical file.
  """
  def to_ics(calendar, options \\ [], extra \\ []) do
    events = Enum.map(calendar.events, &ICalendar.Serialize.to_ics/1)
    vendor = Keyword.get(options, :vendor, "ICalendar")
    extra = Enum.reduce(extra, "", fn {ek, ev}, acc ->
      ek = ek
           |> Atom.to_string()
           |> String.upcase()
      acc <> "#{ek};VALUE=#{ev}\n"
    end)

    """
    BEGIN:VCALENDAR
    CALSCALE:GREGORIAN
    VERSION:2.0
    PRODID:-//ICalendar//#{vendor}//EN
    #{extra}#{events}END:VCALENDAR
    """
  end
end

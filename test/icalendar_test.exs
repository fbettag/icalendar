defmodule ICalendarTest do
  use ExUnit.Case

  @vendor "ICalendar Test"

  test "ICalendar.to_ics/1 of empty calendar" do
    ics = %ICalendar{} |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VCALENDAR\r
           CALSCALE:GREGORIAN\r
           VERSION:2.0\r
           PRODID:-//ICalendar//ICalendar//EN\r
           END:VCALENDAR\r
           """
  end

  test "ICalendar.to_ics/1 of empty calendar with custom vendor" do
    ics = %ICalendar{} |> ICalendar.to_ics(vendor: @vendor)

    assert ics == """
           BEGIN:VCALENDAR\r
           CALSCALE:GREGORIAN\r
           VERSION:2.0\r
           PRODID:-//ICalendar//#{@vendor}//EN\r
           END:VCALENDAR\r
           """
  end

  test "ICalendar.to_ics/1 of empty calendar with extra parameters" do
    ics = %ICalendar{} |> ICalendar.to_ics([], "refresh-interval": "DURATION:P1W", source: "URI:http://some.where/foo.ics")

    assert ics == """
           BEGIN:VCALENDAR\r
           CALSCALE:GREGORIAN\r
           VERSION:2.0\r
           PRODID:-//ICalendar//ICalendar//EN\r
           REFRESH-INTERVAL;DURATION:P1W\r
           SOURCE;URI:http://some.where/foo.ics\r
           END:VCALENDAR\r
           """
  end

  test "ICalendar.to_ics/1 of a calendar with an event, as in README" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
        description: "Let's go see Star Wars."
      },
      %ICalendar.Event{
        summary: "Morning meeting",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {19, 00, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {22, 30, 00}}),
        description: "A big long meeting with lots of details."
      }
    ]

    ics = %ICalendar{events: events} |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VCALENDAR\r
           CALSCALE:GREGORIAN\r
           VERSION:2.0\r
           PRODID:-//ICalendar//ICalendar//EN\r
           BEGIN:VEVENT\r
           DESCRIPTION:Let's go see Star Wars.\r
           DTEND:20151224T084500\r
           DTSTART:20151224T083000\r
           SUMMARY:Film with Amy and Adam\r
           END:VEVENT\r
           BEGIN:VEVENT\r
           DESCRIPTION:A big long meeting with lots of details.\r
           DTEND:20151224T223000\r
           DTSTART:20151224T190000\r
           SUMMARY:Morning meeting\r
           END:VEVENT\r
           END:VCALENDAR\r
           """
  end

  test "Icalender.to_ics/1 with location and sanitization" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
        description: "Let's go see Star Wars, and have fun.",
        location: "123 Fun Street, Toronto ON, Canada"
      }
    ]

    ics = %ICalendar{events: events} |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VCALENDAR\r
           CALSCALE:GREGORIAN\r
           VERSION:2.0\r
           PRODID:-//ICalendar//ICalendar//EN\r
           BEGIN:VEVENT\r
           DESCRIPTION:Let's go see Star Wars\\, and have fun.\r
           DTEND:20151224T084500\r
           DTSTART:20151224T083000\r
           LOCATION:123 Fun Street\\, Toronto ON\\, Canada\r
           SUMMARY:Film with Amy and Adam\r
           END:VEVENT\r
           END:VCALENDAR\r
           """
  end

  test "ICalender.to_ics/1 -> ICalendar.from_ics/1 and back again" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
        dtstamp: Timex.to_datetime({{2015, 12, 24}, {8, 00, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
        description: "Let's go see Star Wars, and have fun.",
        location: "123 Fun Street, Toronto ON, Canada"
      }
    ]

    new_event =
      %ICalendar{events: events}
      |> ICalendar.to_ics(vendor: @vendor)
      |> ICalendar.from_ics()

    assert events |> List.first() == new_event
  end

  test "encode_to_iodata/2" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
        dtstamp: Timex.to_datetime({{2015, 12, 24}, {8, 00, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
        description: "Let's go see Star Wars."
      },
      %ICalendar.Event{
        summary: "Morning meeting",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {19, 00, 00}}),
        dtstamp: Timex.to_datetime({{2015, 12, 24}, {18, 00, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {22, 30, 00}}),
        description: "A big long meeting with lots of details."
      }
    ]

    cal = %ICalendar{events: events}

    assert {:ok, ical} = ICalendar.encode_to_iodata(cal, [])

    assert ical == """
           BEGIN:VCALENDAR\r
           CALSCALE:GREGORIAN\r
           VERSION:2.0\r
           PRODID:-//ICalendar//ICalendar//EN\r
           BEGIN:VEVENT\r
           DESCRIPTION:Let's go see Star Wars.\r
           DTEND:20151224T084500\r
           DTSTAMP:20151224T080000\r
           DTSTART:20151224T083000\r
           SUMMARY:Film with Amy and Adam\r
           END:VEVENT\r
           BEGIN:VEVENT\r
           DESCRIPTION:A big long meeting with lots of details.\r
           DTEND:20151224T223000\r
           DTSTAMP:20151224T180000\r
           DTSTART:20151224T190000\r
           SUMMARY:Morning meeting\r
           END:VEVENT\r
           END:VCALENDAR\r
           """
  end

  test "encode_to_iodata/1" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
        dtstamp: Timex.to_datetime({{2015, 12, 24}, {8, 00, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}}),
        description: "Let's go see Star Wars."
      },
      %ICalendar.Event{
        summary: "Morning meeting",
        dtstart: Timex.to_datetime({{2015, 12, 24}, {19, 00, 00}}),
        dtstamp: Timex.to_datetime({{2015, 12, 24}, {18, 00, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {22, 30, 00}}),
        description: "A big long meeting with lots of details."
      }
    ]

    cal = %ICalendar{events: events}

    assert {:ok, ical} = ICalendar.encode_to_iodata(cal)

    assert ical == """
           BEGIN:VCALENDAR\r
           CALSCALE:GREGORIAN\r
           VERSION:2.0\r
           PRODID:-//ICalendar//ICalendar//EN\r
           BEGIN:VEVENT\r
           DESCRIPTION:Let's go see Star Wars.\r
           DTEND:20151224T084500\r
           DTSTAMP:20151224T080000\r
           DTSTART:20151224T083000\r
           SUMMARY:Film with Amy and Adam\r
           END:VEVENT\r
           BEGIN:VEVENT\r
           DESCRIPTION:A big long meeting with lots of details.\r
           DTEND:20151224T223000\r
           DTSTAMP:20151224T180000\r
           DTSTART:20151224T190000\r
           SUMMARY:Morning meeting\r
           END:VEVENT\r
           END:VCALENDAR\r
           """
  end
end

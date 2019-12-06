defmodule ICalendar.EventTest do
  use ExUnit.Case

  alias ICalendar.Event

  test "ICalendar.to_ics/1 of event" do
    ics = %Event{} |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VEVENT\r
           END:VEVENT\r
           """
  end

  test "ICalendar.to_ics/1 with some attributes" do
    ics =
      %Event{
        summary: "Going fishing",
        description: "Escape from the world. Stare at some water.",
        comment: "Don't forget to take something to eat !"
      }
      |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VEVENT\r
           COMMENT:Don't forget to take something to eat !\r
           DESCRIPTION:Escape from the world. Stare at some water.\r
           SUMMARY:Going fishing\r
           END:VEVENT\r
           """
  end

  test "ICalendar.to_ics/1 with date start and end" do
    ics =
      %Event{
        dtstart: Timex.to_date({2015, 12, 24}),
        dtend: Timex.to_date({2015, 12, 24})
      }
      |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VEVENT\r
           DTEND:20151224\r
           DTSTART:20151224\r
           END:VEVENT\r
           """
  end

  test "ICalendar.to_ics/1 with datetime start and end" do
    ics =
      %Event{
        dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 00}}),
        dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 00}})
      }
      |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VEVENT\r
           DTEND:20151224T084500\r
           DTSTART:20151224T083000\r
           END:VEVENT\r
           """
  end

  test "ICalendar.to_ics/1 with datetime with timezone" do
    dtstart =
      {{2015, 12, 24}, {8, 30, 00}}
      |> Timex.to_datetime("America/Chicago")

    dtend =
      {{2015, 12, 24}, {8, 45, 00}}
      |> Timex.to_datetime("America/Chicago")

    ics =
      %Event{dtstart: dtstart, dtend: dtend}
      |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VEVENT\r
           DTEND;TZID=America/Chicago:20151224T084500\r
           DTSTART;TZID=America/Chicago:20151224T083000\r
           END:VEVENT\r
           """
  end

  test "ICalendar.to_ics/1 does not damage url in description" do
    ics =
      %Event{
        summary: "Going fishing",
        description:
          "See this link http://example.com/pub" <>
            "/calendars/jsmith/mytime.ics"
      }
      |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VEVENT\r
           DESCRIPTION:See this link http://example.com/pub/calendars/jsmith/mytime.ics\r
           SUMMARY:Going fishing\r
           END:VEVENT\r
           """
  end

  test "ICalendar.to_ics/1 with url" do
    ics =
      %Event{
        url: "http://example.com/pub/calendars/jsmith/mytime.ics"
      }
      |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VEVENT\r
           URL:http://example.com/pub/calendars/jsmith/mytime.ics\r
           END:VEVENT\r
           """
  end

  test "ICalendar.to_ics/1 with integer UID" do
    ics =
      %Event{
        uid: 815
      }
      |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VEVENT\r
           UID:815\r
           END:VEVENT\r
           """
  end

  test "ICalendar.to_ics/1 with string UID" do
    ics =
      %Event{
        uid: "0815"
      }
      |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VEVENT\r
           UID:0815\r
           END:VEVENT\r
           """
  end

  test "ICalendar.to_ics/1 with geo" do
    ics =
      %Event{
        geo: {43.6978819, -79.3810277}
      }
      |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VEVENT\r
           GEO:43.6978819;-79.3810277\r
           END:VEVENT\r
           """
  end

  test "ICalendar.to_ics/1 with categories" do
    ics =
      %Event{
        categories: ["Fishing", "Nature", "Sport"]
      }
      |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VEVENT\r
           CATEGORIES:Fishing,Nature,Sport\r
           END:VEVENT\r
           """
  end

  test "ICalendar.to_ics/1 with status" do
    ics =
      %Event{
        status: :tentative
      }
      |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VEVENT\r
           STATUS:TENTATIVE\r
           END:VEVENT\r
           """
  end

  test "ICalendar.to_ics/1 with class" do
    ics =
      %Event{
        class: :private
      }
      |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VEVENT\r
           CLASS:PRIVATE\r
           END:VEVENT\r
           """
  end
end

defmodule ICalendar.DeserializeTest do
  use ExUnit.Case

  alias ICalendar.Event

  describe "ICalendar.from_ics/1" do
    test "Single Event" do
      ics = """
      BEGIN:VEVENT\r
      DESCRIPTION:Escape from the world. Stare at some water.\r
      COMMENT:Don't forget to take something to eat !\r
      SUMMARY:Going fishing\r
      DTEND:20151224T084500Z\r
      DTSTAMP:20151224T080000Z\r
      DTSTART:20151224T083000Z\r
      LOCATION:123 Fun Street\\, Toronto ON\\, Canada\r
      STATUS:TENTATIVE\r
      CATEGORIES:Fishing,Nature\r
      CLASS:PRIVATE\r
      GEO:43.6978819;-79.3810277\r
      END:VEVENT\r
      """

      event = ICalendar.from_ics(ics)

      assert event == %Event{
               dtstart: Timex.to_datetime({{2015, 12, 24}, {8, 30, 0}}),
               dtend: Timex.to_datetime({{2015, 12, 24}, {8, 45, 0}}),
               dtstamp: Timex.to_datetime({{2015, 12, 24}, {8, 00, 0}}),
               summary: "Going fishing",
               description: "Escape from the world. Stare at some water.",
               location: "123 Fun Street, Toronto ON, Canada",
               status: "tentative",
               categories: ["Fishing", "Nature"],
               comment: "Don't forget to take something to eat !",
               class: "private",
               geo: {43.6978819, -79.3810277}
             }
    end

    test "with Timezone" do
      ics = """
      BEGIN:VEVENT\r
      DTEND;TZID=America/Chicago:22221224T084500\r
      DTSTART;TZID=America/Chicago:22221224T083000\r
      END:VEVENT\r
      """

      event = ICalendar.from_ics(ics)
      assert event.dtstart.time_zone == "America/Chicago"
      assert event.dtend.time_zone == "America/Chicago"
    end
  end
end

defmodule SlotSync.MessageTest do
  use ExUnit.Case, async: true

  alias SlotSync.Message, as: Subject

  describe "format/1" do
    test "it returns a ok tuple with the result from kafak produce" do
      event = %{
        "account_id" => 77967,
        "acknowledged" => 1,
        "acknowledged_at" => "Mon, 01 Oct 2018 15:27:30 +0100",
        "actionable" => false,
        "alerted" => false,
        "block_id" => 0,
        "break_time" => 0,
        "color" => "74a611",
        "created_at" => "Wed, 26 Sep 2018 12:24:58 +0100",
        "creator_id" => 5_526_232,
        "end_time" => "Mon, 08 Oct 2018 00:15:00 +0100",
        "id" => 2_076_303_948,
        "instances" => 0,
        "is_open" => false,
        "linked_users" => nil,
        "location_id" => 3_999_871,
        "notes" => "",
        "notified_at" => nil,
        "position_id" => 709_909,
        "published" => true,
        "published_date" => "Wed, 26 Sep 2018 16:59:05 +0100",
        "shiftchain_key" => "",
        "site_id" => 3_530_221,
        "start_time" => "Sun, 07 Oct 2018 21:00:00 +0100",
        "updated_at" => "Mon, 01 Oct 2018 15:27:30 +0100",
        "user_id" => 29_205_212
      }

      result = [
        {"account_id", 77967},
        {"acknowledged", 1},
        {"acknowledged_at", {"string", "2018-10-01T15:27:30+01:00"}},
        {"actionable", false},
        {"alerted", false},
        {"block_id", 0},
        {"break_time", 0},
        {"color", "74a611"},
        {"created_at", "2018-09-26T12:24:58+01:00"},
        {"creator_id", 5_526_232},
        {"end_time", "2018-10-08T00:15:00+01:00"},
        {"id", 2_076_303_948},
        {"instances", 0},
        {"is_open", false},
        {"linked_users", :null},
        {"location_id", 3_999_871},
        {"notes", ""},
        {"notified_at", {"null", :null}},
        {"position_id", 709_909},
        {"published", true},
        {"published_date", "2018-09-26T16:59:05+01:00"},
        {"shiftchain_key", ""},
        {"site_id", 3_530_221},
        {"start_time", "2018-10-07T21:00:00+01:00"},
        {"updated_at", "2018-10-01T15:27:30+01:00"},
        {"user_id", 29_205_212}
      ]

      # assert {:ok, result} == Subject.format(event)
      assert result == Subject.format(event)
    end
  end
end

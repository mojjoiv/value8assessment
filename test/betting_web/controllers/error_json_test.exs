defmodule BettingWeb.ErrorJSONTest do
  use BettingWeb.ConnCase, async: true

  test "renders 404" do
    assert BettingWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert BettingWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end

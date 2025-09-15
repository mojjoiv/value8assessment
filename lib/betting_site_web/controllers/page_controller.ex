defmodule BettingSiteWeb.PageController do
  use BettingSiteWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

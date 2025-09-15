defmodule BettingWeb.PageController do
  use BettingWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

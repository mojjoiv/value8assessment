defmodule BettingWeb.Plugs.Authorize do
  import Plug.Conn
  import Phoenix.Controller

  alias BettingWeb.Router

  use BettingWeb, :verified_routes

  def init(opts), do: opts

  def call(conn, :require_admin) do
    case conn.assigns[:current_scope] do
      %{user: %{role: "admin"}} -> conn
      %{user: %{is_superuser: true}} -> conn
      _ -> redirect_to_login(conn)
    end
  end

  def call(conn, :require_superuser) do
    case conn.assigns[:current_scope] do
      %{user: %{is_superuser: true}} -> conn
      _ -> redirect_to_login(conn)
    end
  end

  def call(conn, :require_frontend) do
    case conn.assigns[:current_scope] do
      %{user: %{role: "frontend"}} -> conn
      _ -> redirect_to_login(conn)
    end
  end

  defp redirect_to_login(conn) do
    conn
    |> redirect(to: ~p"/users/log-in")
    |> halt()
  end
end

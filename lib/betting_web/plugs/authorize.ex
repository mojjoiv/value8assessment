defmodule BettingWeb.Plugs.Authorize do
  import Plug.Conn
  import Phoenix.Controller

  alias BettingWeb.Router.Helpers, as: Routes

  def init(role), do: role

  def call(conn, required_role) do
    current_user = conn.assigns[:current_user]

    cond do
      current_user == nil ->
        conn
        |> put_flash(:error, "You must log in first.")
        |> redirect(to: Routes.user_login_path(conn, :new))
        |> halt()

      has_role?(current_user, required_role) ->
        conn

      true ->
        conn
        |> put_flash(:error, "You do not have permission to access this page.")
        |> redirect(to: "/")
        |> halt()
    end
  end

  # Roles
  defp has_role?(%{role: "superuser"}, _), do: true
  defp has_role?(%{role: "admin"}, :require_admin), do: true
  defp has_role?(%{role: "frontend"}, :require_frontend), do: true
  defp has_role?(_, _), do: false
end

defmodule BettingWeb.AdminController do
  use BettingWeb, :controller

  alias Betting.Accounts

  def grant_admin(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    case Accounts.update_user_role(user, "admin") do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Granted admin")
        |> redirect(to: Routes.admin_path(conn, :index))
      {:error, _} ->
        conn
        |> put_flash(:error, "Failed to grant admin")
        |> redirect(to: Routes.admin_path(conn, :index))
    end
  end

  def revoke_admin(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    case Accounts.update_user_role(user, "frontend") do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Revoked admin")
        |> redirect(to: Routes.admin_path(conn, :index))
      {:error, _} ->
        conn
        |> put_flash(:error, "Failed to revoke admin")
        |> redirect(to: Routes.admin_path(conn, :index))
    end
  end
end

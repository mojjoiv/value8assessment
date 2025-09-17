defmodule BettingWeb.AdminLive.Index do
  use BettingWeb, :live_view

  alias Betting.Accounts
  alias Betting.Bets

  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:users, Accounts.list_users())
      |> assign(:bets, %{})
      |> assign(:summaries, %{})
      |> assign(:expanded_users, MapSet.new())}
  end

  def handle_event("toggle_bets", %{"id" => id}, socket) do
    user_id = String.to_integer(id)

    expanded =
      if MapSet.member?(socket.assigns.expanded_users, user_id) do
        MapSet.delete(socket.assigns.expanded_users, user_id)
      else
        MapSet.put(socket.assigns.expanded_users, user_id)
      end

    {bets, summaries} =
      case {socket.assigns.bets[user_id], socket.assigns.summaries[user_id]} do
        {nil, nil} ->
          bets = Bets.list_user_bets(user_id)
          summary = Bets.user_summary(user_id)
          {
            Map.put(socket.assigns.bets, user_id, bets),
            Map.put(socket.assigns.summaries, user_id, summary)
          }

        _ ->
          {socket.assigns.bets, socket.assigns.summaries}
      end

    {:noreply,
      socket
      |> assign(:expanded_users, expanded)
      |> assign(:bets, bets)
      |> assign(:summaries, summaries)}
  end

  def handle_event("mark_won", %{"id" => id}, socket) do
    bet = Bets.get_bet!(id)
    {:ok, _} = Bets.update_bet_status(bet, "won")

    refresh_admin(socket, bet.user_id)
  end

  def handle_event("mark_lost", %{"id" => id}, socket) do
    bet = Bets.get_bet!(id)
    {:ok, _} = Bets.update_bet_status(bet, "lost")

    refresh_admin(socket, bet.user_id)
  end

  def handle_event("soft_delete_user", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    case Accounts.soft_delete_user(user) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User #{user.email} has been soft deleted.")
         |> assign(:users, Accounts.list_users())}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete user.")}
    end
  end

  def handle_event("grant_admin", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    case Accounts.update_user_role(user, "admin") do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "#{user.email} is now an admin.")
         |> assign(:users, Accounts.list_users())}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to update role.")}
    end
  end

  def handle_event("revoke_admin", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    case Accounts.update_user_role(user, "frontend") do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "#{user.email} is no longer an admin.")
         |> assign(:users, Accounts.list_users())}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to update role.")}
    end
  end

  defp refresh_admin(socket, user_id) do
    bets = Bets.list_user_bets(user_id)
    summary = Bets.user_summary(user_id)

    {:noreply,
      socket
      |> assign(:bets, Map.put(socket.assigns.bets, user_id, bets))
      |> assign(:summaries, Map.put(socket.assigns.summaries, user_id, summary))}
  end
end

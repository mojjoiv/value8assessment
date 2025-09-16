defmodule BettingWeb.BetLive.Index do
  use BettingWeb, :live_view

  alias Betting.Bets
  alias BettingWeb.LiveHelpers

  def mount(_params, session, socket) do
    socket =
      socket
      |> LiveHelpers.assign_current_user(session)
      |> assign_bets()
      |> assign_summary()

    {:ok, socket}
  end

  def handle_event("cancel", %{"id" => id}, socket) do
    bet = Bets.get_bet!(id)

    if socket.assigns.current_user.id == bet.user_id do
      {:ok, _} = Bets.cancel_bet(bet)

      {:noreply,
       socket
       |> put_flash(:info, "Bet cancelled!")
       |> assign_bets()
       |> assign_summary()}
    else
      {:noreply, put_flash(socket, :error, "Not allowed")}
    end
  end

  defp assign_bets(socket) do
    user = socket.assigns.current_user
    bets = Bets.list_user_bets(user.id)
    assign(socket, :bets, bets)
  end

  defp assign_summary(socket) do
    user = socket.assigns.current_user
    summary = Bets.user_summary(user.id)
    assign(socket, :summary, summary)
  end
end

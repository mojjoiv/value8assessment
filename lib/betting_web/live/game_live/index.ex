defmodule BettingWeb.GameLive.Index do
  use BettingWeb, :live_view

  alias Betting.Sports
  alias Betting.Bets
  alias Betting.Accounts

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:games, Sports.list_upcoming_games())
     |> assign(:current_user, nil)
     |> assign(:bet_changeset, nil)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("bet", %{"game_id" => game_id, "bet_type" => bet_type, "stake" => stake}, socket) do
    user = socket.assigns.current_user
    game = Sports.get_game!(game_id)

    case Bets.place_bet(user, game, %{"bet_type" => bet_type, "stake" => Decimal.new(stake)}) do
  {:ok, _bet} ->
    {:noreply,
     socket
     |> put_flash(:info, "Bet placed!")
     |> assign(:games, Sports.list_upcoming_games())
     |> assign(:bet_changeset, nil)}

  {:error, changeset} ->
    {:noreply,
     socket
     |> put_flash(:error, "Bet could not be placed")
     |> assign(:bet_changeset, changeset)}
end
  end
end

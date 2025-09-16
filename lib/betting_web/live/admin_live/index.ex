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
          {Map.put(socket.assigns.bets, user_id, bets),
           Map.put(socket.assigns.summaries, user_id, summary)}

        _ ->
          {socket.assigns.bets, socket.assigns.summaries}
      end

    {:noreply,
      socket
      |> assign(:expanded_users, expanded)
      |> assign(:bets, bets)
      |> assign(:summaries, summaries)}
  end
end

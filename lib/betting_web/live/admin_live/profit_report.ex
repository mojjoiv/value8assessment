defmodule BettingWeb.AdminLive.ProfitReport do
  use BettingWeb, :live_view
  alias Betting.Bets

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :report, Bets.profit_report())}
  end

  def render(assigns) do
    ~H"""
    <.flash kind={:info} />
    <.flash kind={:error} />

    <h1 class="text-xl font-bold mb-4">Profit Report per Game</h1>

    <table class="table-auto border-collapse border border-gray-400 w-full">
      <thead>
        <tr>
          <th class="border px-4 py-2">Game</th>
          <th class="border px-4 py-2">Total Wagered</th>
          <th class="border px-4 py-2">Total Payout</th>
          <th class="border px-4 py-2">Profit</th>
        </tr>
      </thead>
      <tbody>
        <%= for row <- @report do %>
          <tr>
            <td class="border px-4 py-2"><%= row.home_team %> vs <%= row.away_team %></td>
            <td class="border px-4 py-2"><%= row.total_wagered %></td>
            <td class="border px-4 py-2"><%= row.total_payout %></td>
            <td class="border px-4 py-2 font-semibold"><%= row.profit %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end
end

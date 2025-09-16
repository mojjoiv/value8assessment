defmodule Betting.Sports do
  import Ecto.Query, warn: false
  alias Betting.Repo
  alias Betting.Sports.Game

  def list_upcoming_games do
    now = DateTime.utc_now()

    Game
    |> where([g], g.starts_at > ^now)
    |> order_by([g], asc: g.starts_at)
    |> Repo.all()
  end

  def list_games do
    Repo.all(Game)
  end

  def get_game!(id), do: Repo.get!(Game, id)

  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  def change_game(%Game{} = game, attrs \\ %{}) do
    Game.changeset(game, attrs)
  end

  def settle_game(%Game{} = game, result) when is_binary(result) do
  alias Betting.Bets
  alias Betting.Bets.BetNotifier
  alias Betting.Repo

  Repo.transaction(fn ->
    # 1) update game result and status
    {:ok, game} =
      game
      |> Game.changeset(%{result: result, status: "finished"})
      |> Repo.update()

    # 2) fetch bets for the game (with users preloaded)
    bets = Bets.list_bets_for_game(game.id)

    # 3) process each bet
    Enum.each(bets, fn bet ->
      outcome =
        if bet.bet_type == result do
          :won
        else
          :lost
        end

      # update the bet (sets status and payout if schema supports it)
      {:ok, updated_bet} = Bets.settle_bet(bet, outcome)

      # compute payout (if present) — try to read updated_bet.payout
      payout =
        case Map.fetch(updated_bet, :payout) do
          {:ok, val} -> val
          :error -> if outcome == :won, do: Decimal.mult(bet.stake, bet.odds), else: Decimal.new(0)
        end

      # 4) notify user (synchronously)
      if Map.get(bet, :user) do
        BetNotifier.deliver_bet_result(bet.user, game, updated_bet, Atom.to_string(outcome), payout)
      else
        # if user not preloaded, load it and send
        bet = Repo.preload(bet, :user)
        BetNotifier.deliver_bet_result(bet.user, game, updated_bet, Atom.to_string(outcome), payout)
      end
    end)

    {:ok, game}
  end)
end

end

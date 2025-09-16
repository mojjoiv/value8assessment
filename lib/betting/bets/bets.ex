defmodule Betting.Bets do
  import Ecto.Query, warn: false
  alias Betting.Repo
  alias Betting.Bets.Bet
  alias Betting.Sports.Game
  alias Betting.Accounts.User
  alias Decimal

  def list_user_bets(user_id) do
    Bet
    |> where([b], b.user_id == ^user_id)
    |> where([b], is_nil(b.deleted_at))
    |> preload([:game])
    |> Repo.all()
  end

  def get_bet!(id), do: Repo.get!(Bet, id) |> Repo.preload(:game)

  def place_bet(%User{} = user, %Game{} = game, attrs) do
    odds =
      case attrs["bet_type"] do
        "home" -> game.odds_home
        "draw" -> game.odds_draw
        "away" -> game.odds_away
      end

    %Bet{}
    |> Bet.changeset(Map.merge(attrs, %{
      "user_id" => user.id,
      "game_id" => game.id,
      "odds" => odds
    }))
    |> Repo.insert()
  end

  def cancel_bet(%Bet{} = bet) do
    bet
    |> Ecto.Changeset.change(status: "cancelled")
    |> Repo.update()
  end

  def user_summary(user_id) do
    bets = list_user_bets(user_id)

    total_wagered =
      Enum.reduce(bets, Decimal.new(0), fn b, acc -> Decimal.add(acc, b.stake) end)

    total_won =
      Enum.reduce(bets, Decimal.new(0), fn b, acc ->
        if b.status == "won" do
          Decimal.add(acc, b.payout || Decimal.new(0))
        else
          acc
        end
      end)

    %{
      total_wagered: total_wagered,
      total_won: total_won,
      net: Decimal.sub(total_won, total_wagered)
    }
  end

   def profit_report do
    from(g in Betting.Sports.Game,
      left_join: b in Betting.Bets.Bet,
      on: b.game_id == g.id,
      group_by: [g.id],
      select: %{
        game_id: g.id,
        home_team: g.home_team,
        away_team: g.away_team,
        total_wagered: coalesce(sum(b.stake), 0),
        total_payout:
          coalesce(
            sum(
              fragment(
                "CASE WHEN ? = 'won' THEN ? * ? ELSE 0 END",
                b.status,
                b.stake,
                b.odds
              )
            ),
            0
          ),
        profit:
          coalesce(sum(b.stake), 0) -
            coalesce(
              sum(
                fragment(
                  "CASE WHEN ? = 'won' THEN ? * ? ELSE 0 END",
                  b.status,
                  b.stake,
                  b.odds
                )
              ),
              0
            )
      }
    )
    |> Repo.all()
  end

  @doc """
  Update bet status (e.g. "won", "lost", "cancelled").
  If status is "won", automatically calculates payout = stake * odds.
  """
   def update_bet_status(%Bet{} = bet, status) when status in ["won", "lost", "cancelled"] do
    changes =
      case status do
        "won" -> %{status: "won", payout: Decimal.mult(bet.stake, bet.odds)}
        _ -> %{status: status, payout: nil}
      end

    bet
    |> Ecto.Changeset.change(changes)
    |> Repo.update()
  end

  # List bets for a given game id (preload user + game)
  def list_bets_for_game(game_id) do
    Bet
    |> where([b], b.game_id == ^game_id)
    |> preload([:user, :game])
    |> Repo.all()
  end

  @doc """
  Settle a single bet. outcome is :won or :lost (atom).
  This will update the bet.status and optionally payout if schema has :payout.
  """
  def settle_bet(%Bet{} = bet, :won) do
    payout = Decimal.mult(bet.stake, bet.odds)

    changes =
      if Map.has_key?(bet, :payout) do
        %{status: "won", payout: payout}
      else
        %{status: "won"}
      end

    bet
    |> Ecto.Changeset.change(changes)
    |> Repo.update()
  end

  def settle_bet(%Bet{} = bet, :lost) do
    changes =
      if Map.has_key?(bet, :payout) do
        %{status: "lost", payout: Decimal.new(0)}
      else
        %{status: "lost"}
      end

    bet
    |> Ecto.Changeset.change(changes)
    |> Repo.update()
  end
end

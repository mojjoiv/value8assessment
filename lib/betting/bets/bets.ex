defmodule Betting.Bets do
  import Ecto.Query, warn: false
  alias Betting.Repo
  alias Betting.Bets.Bet
  alias Betting.Sports.Game
  alias Betting.Accounts.User

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
end

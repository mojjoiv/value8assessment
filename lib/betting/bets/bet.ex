defmodule Betting.Bets.Bet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bets" do
    field :bet_type, :string
    field :stake, :decimal
    field :odds, :decimal
    field :status, :string, default: "pending"
    field :deleted_at, :utc_datetime

    field :payout, :decimal 

    belongs_to :user, Betting.Accounts.User
    belongs_to :game, Betting.Sports.Game

    timestamps()
  end

  def changeset(bet, attrs) do
    bet
    |> cast(attrs, [:bet_type, :stake, :odds, :status, :user_id, :game_id])
    |> validate_required([:bet_type, :stake, :odds, :user_id, :game_id])
    |> validate_inclusion(:bet_type, ["home", "draw", "away"])
    |> validate_inclusion(:status, ["pending", "won", "lost", "cancelled"])
  end
end

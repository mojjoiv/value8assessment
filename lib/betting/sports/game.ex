defmodule Betting.Sports.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :sport, :string, default: "football"
    field :home_team, :string
    field :away_team, :string
    field :starts_at, :utc_datetime
    field :status, :string, default: "scheduled"
    field :result, :string
    field :odds_home, :decimal
    field :odds_draw, :decimal
    field :odds_away, :decimal

    has_many :bets, Betting.Bets.Bet

    timestamps()
  end

  def changeset(game, attrs) do
    game
    |> cast(attrs, [:sport, :home_team, :away_team, :starts_at, :status, :result, :odds_home, :odds_draw, :odds_away])
    |> validate_required([:home_team, :away_team, :starts_at])
  end
end

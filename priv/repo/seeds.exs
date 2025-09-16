alias Betting.Repo
alias Betting.Sports.Game

Repo.delete_all(Game)

games = [
  %{
    sport: "football",
    home_team: "Arsenal",
    away_team: "Chelsea",
    starts_at: DateTime.utc_now() |> DateTime.add(3600, :second), # 1 hr later
    odds_home: Decimal.new("1.9"),
    odds_draw: Decimal.new("3.1"),
    odds_away: Decimal.new("2.7"),
    status: "scheduled"
  },
  %{
    sport: "football",
    home_team: "Man United",
    away_team: "Liverpool",
    starts_at: DateTime.utc_now() |> DateTime.add(7200, :second),
    odds_home: Decimal.new("2.0"),
    odds_draw: Decimal.new("3.0"),
    odds_away: Decimal.new("2.5"),
    status: "scheduled"
  },
  %{
    sport: "football",
    home_team: "Real Madrid",
    away_team: "Barcelona",
    starts_at: DateTime.utc_now() |> DateTime.add(10_800, :second),
    odds_home: Decimal.new("2.2"),
    odds_draw: Decimal.new("3.4"),
    odds_away: Decimal.new("2.1"),
    status: "scheduled"
  }
]

for game <- games do
  %Game{}
  |> Game.changeset(game)
  |> Repo.insert!()
end

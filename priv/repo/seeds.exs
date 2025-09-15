alias Betting.Repo
alias Betting.Sports

Sports.create_game(%{
  sport: "football",
  home_team: "Arsenal",
  away_team: "Chelsea",
  starts_at: DateTime.add(DateTime.utc_now(), 3600),
  odds_home: Decimal.new("1.8"),
  odds_draw: Decimal.new("3.2"),
  odds_away: Decimal.new("2.5")
})

Sports.create_game(%{
  sport: "football",
  home_team: "Man City",
  away_team: "Liverpool",
  starts_at: DateTime.add(DateTime.utc_now(), 7200),
  odds_home: Decimal.new("1.9"),
  odds_draw: Decimal.new("3.0"),
  odds_away: Decimal.new("2.8")
})

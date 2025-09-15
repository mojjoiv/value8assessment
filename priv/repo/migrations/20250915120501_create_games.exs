defmodule Betting.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :sport, :string, default: "football"
      add :home_team, :string, null: false
      add :away_team, :string, null: false
       add :starts_at, :utc_datetime, null: false
      add :status, :string, default: "scheduled", null: false
      add :result, :string
      add :odds_home, :decimal
      add :odds_draw, :decimal
      add :odds_away, :decimal

      timestamps()
    end

    create index(:games, [:starts_at])
    create index(:games, [:sport])
  end
end

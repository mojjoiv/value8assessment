defmodule Betting.Repo.Migrations.CreateBets do
  use Ecto.Migration

  def change do
    create table(:bets) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :game_id, references(:games, on_delete: :delete_all), null: false

      add :bet_type, :string, null: false
      add :stake, :decimal, null: false
      add :odds, :decimal, null: false
      add :status, :string, default: "pending", null: false

      timestamps()
    end

    create index(:bets, [:user_id])
    create index(:bets, [:game_id])
    create index(:bets, [:status])
  end
end

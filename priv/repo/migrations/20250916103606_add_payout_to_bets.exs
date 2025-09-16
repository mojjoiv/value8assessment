defmodule Betting.Repo.Migrations.AddPayoutToBets do
  use Ecto.Migration

  def change do
    alter table(:bets) do
      add :payout, :decimal
    end
  end
end

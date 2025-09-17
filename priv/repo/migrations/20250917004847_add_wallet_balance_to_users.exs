defmodule Betting.Repo.Migrations.AddWalletBalanceToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :wallet_balance, :decimal, default: 0, null: false
    end
  end
end

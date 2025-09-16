defmodule Betting.Repo.Migrations.AddDeletedAtToBets do
  use Ecto.Migration

  def change do
    alter table(:bets) do
      add :deleted_at, :utc_datetime
    end
  end
end

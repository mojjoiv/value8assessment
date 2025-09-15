defmodule Betting.Repo.Migrations.AddProfileFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :msisdn, :string
      add :role, :string, default: "frontend", null: false
      add :is_superuser, :boolean, default: false, null: false
      add :deleted_at, :utc_datetime
    end

    create index(:users, [:msisdn])
    create index(:users, [:role])
  end
end

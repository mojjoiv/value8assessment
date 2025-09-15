defmodule Betting.Repo do
  use Ecto.Repo,
    otp_app: :betting,
    adapter: Ecto.Adapters.Postgres
end

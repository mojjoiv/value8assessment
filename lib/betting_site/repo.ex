defmodule BettingSite.Repo do
  use Ecto.Repo,
    otp_app: :betting_site,
    adapter: Ecto.Adapters.Postgres
end

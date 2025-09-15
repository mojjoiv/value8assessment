defmodule Betting.Sports do
  import Ecto.Query, warn: false
  alias Betting.Repo
  alias Betting.Sports.Game

  def list_upcoming_games do
    now = DateTime.utc_now()
    Game
    |> where([g], g.starts_at > ^now)
    |> order_by([g], asc: g.starts_at)
    |> Repo.all()
  end

  def get_game!(id), do: Repo.get!(Game, id)

  def create_game(attrs) do
  %Game{}
  |> Game.changeset(attrs)
  |> Repo.insert()
end

def update_game(%Game{} = game, attrs) do
  game
  |> Game.changeset(attrs)
  |> Repo.update()
end

end

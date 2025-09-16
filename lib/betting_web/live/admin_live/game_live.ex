defmodule BettingWeb.AdminLive.GameLive do
  use BettingWeb, :live_view
  import Phoenix.HTML.Form

  alias Betting.Sports
  alias Betting.Sports.Game

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:games, Sports.list_games())
     |> assign(:form, to_form(Sports.change_game(%Game{})))
     |> assign(:editing, nil)}
  end

  @impl true
  def handle_event("save_game", %{"game" => game_params}, %{assigns: %{editing: nil}} = socket) do
    case Sports.create_game(game_params) do
      {:ok, _game} ->
        games = Sports.list_games()
        IO.inspect(games, label: "Updated games list after create")

        {:noreply,
         socket
         |> put_flash(:info, "Game created successfully")
         |> assign(:games, games)
         |> assign(:form, to_form(Sports.change_game(%Game{})))}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("save_game", %{"game" => game_params}, %{assigns: %{editing: game}} = socket) do
    case Sports.update_game(game, game_params) do
      {:ok, _game} ->
        games = Sports.list_games()
        IO.inspect(games, label: "Updated games list after update")

        {:noreply,
         socket
         |> put_flash(:info, "Game updated successfully")
         |> assign(:games, games)
         |> assign(:form, to_form(Sports.change_game(%Game{})))
         |> assign(:editing, nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("edit_game", %{"id" => id}, socket) do
    game = Sports.get_game!(id)

    {:noreply,
     socket
     |> assign(:editing, game)
     |> assign(:form, to_form(Sports.change_game(game)))}
  end

  def handle_event("cancel_edit", _params, socket) do
    {:noreply,
     socket
     |> assign(:editing, nil)
     |> assign(:form, to_form(Sports.change_game(%Game{})))}
  end

  def handle_event("delete_game", %{"id" => id}, socket) do
    game = Sports.get_game!(id)
    {:ok, _} = Sports.delete_game(game)

    games = Sports.list_games()
    IO.inspect(games, label: "Updated games list after delete")

    {:noreply,
     socket
     |> put_flash(:info, "Game deleted successfully")
     |> assign(:games, games)}
  end

  @impl true
  def mount(_params, session, socket) do
    # if you have LiveHelpers.assign_current_user(session) you can call it here
    socket =
      socket
      |> assign(:games, Sports.list_games())
      |> assign(:form, to_form(Sports.change_game(%Betting.Sports.Game{})))
      |> assign(:editing, nil)

    {:ok, socket}
  end

  # existing create/save/edit/delete handlers... (keep your existing code)

  # handle settling the game result
  @impl true
  def handle_event("settle_game", %{"id" => id, "result" => result}, socket) do
    game = Sports.get_game!(id)

    case Sports.settle_game(game, result) do
      {:ok, _game} ->
        {:noreply,
         socket
         |> put_flash(:info, "Game settled — users notified.")
         |> assign(:games, Sports.list_games())}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to settle game.")
         |> assign(:games, Sports.list_games())}
    end
  end
end

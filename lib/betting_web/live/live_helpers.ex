defmodule BettingWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.Component

  alias Betting.Accounts

  @doc """
  Assign the current user to the socket using the session's `user_token`.
  """
  def assign_current_user(socket, session) do
    user =
      case Map.get(session, "user_token") do
        nil -> nil
        token ->
          case Accounts.get_user_by_session_token(token) do
            {user, _authenticated_at} -> user
            user -> user
          end
      end

    if user do
      assign(socket, :current_user, user)
    else
      socket
      |> put_flash(:error, "You must log in to continue.")
      |> redirect(to: "/users/log-in")
    end
  end
end

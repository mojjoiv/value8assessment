defmodule Betting.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Betting.Repo
  alias Betting.Accounts.{User, UserToken, UserNotifier}
  alias Betting.Bets.Bet

  ## Database getters

  # Fetch a user by id (raises if not found)
  def get_user!(id), do: Repo.get!(User, id)

  # Fetch a user by id (returns nil if not found)
  def get_user(id), do: Repo.get(User, id)

  # List all users (default excludes soft-deleted ones)
  def list_users(include_deleted \\ false) do
    q = from(u in User, order_by: [asc: u.inserted_at])
    q = if include_deleted, do: q, else: from(u in q, where: is_nil(u.deleted_at))
    Repo.all(q)
  end

  def get_user_by_email(email) when is_binary(email), do: Repo.get_by(User, email: email)

  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if user && User.valid_password?(user, password), do: user
  end

  ## Registration

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def change_user_registration(user, attrs \\ %{}) do
    User.registration_changeset(user, attrs)
  end

  ## Role management

  def make_admin(%User{} = user) do
    user
    |> Ecto.Changeset.change(%{role: "admin", is_superuser: false})
    |> Repo.update()
  end

  def revoke_admin(%User{} = user) do
    user
    |> Ecto.Changeset.change(%{role: "frontend", is_superuser: false})
    |> Repo.update()
  end

  def promote_to_superuser(%User{} = user) do
    user
    |> Ecto.Changeset.change(%{role: "superuser", is_superuser: true})
    |> Repo.update()
  end

  def revoke_superuser(%User{} = user) do
    user
    |> Ecto.Changeset.change(%{role: "frontend", is_superuser: false})
    |> Repo.update()
  end

  def update_user_role(%User{} = user, role) when role in ["frontend", "admin", "superuser"] do
    user
    |> Ecto.Changeset.change(%{role: role, is_superuser: role == "superuser"})
    |> Repo.update()
  end

  ## Soft delete

  def soft_delete_user(%User{} = user) do
    Repo.transaction(fn ->
      now = DateTime.utc_now()

      {:ok, user} =
        user
        |> Ecto.Changeset.change(deleted_at: now)
        |> Repo.update()

      from(b in Bet, where: b.user_id == ^user.id)
      |> Repo.update_all(set: [deleted_at: now])

      user
    end)
  end

  ## Wallet functions (skeleton – expand later)

  def get_wallet_balance(%User{} = user), do: user.wallet_balance || 0

  def credit_wallet(%User{} = user, amount) when amount > 0 do
    new_balance = (user.wallet_balance || 0) + amount
    user |> Ecto.Changeset.change(%{wallet_balance: new_balance}) |> Repo.update()
  end

  def debit_wallet(%User{} = user, amount) when amount > 0 do
    balance = user.wallet_balance || 0

    if balance >= amount do
      user
      |> Ecto.Changeset.change(%{wallet_balance: balance - amount})
      |> Repo.update()
    else
      {:error, :insufficient_funds}
    end
  end

  ## Session & tokens

  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  def delete_user_session_token(token) do
    Repo.delete_all(from(UserToken, where: [token: ^token, context: "session"]))
    :ok
  end
end

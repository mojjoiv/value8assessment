defmodule Betting.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @roles ~w(frontend admin)

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :utc_datetime
    field :authenticated_at, :utc_datetime, virtual: true

    # Added profile & admin fields
    field :first_name, :string
    field :last_name, :string
    field :msisdn, :string
    field :role, :string, default: "frontend"
    field :is_superuser, :boolean, default: false
    field :deleted_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc """
  Registration changeset: use when a user signs up.

  Allows optional profile fields (first_name, last_name, msisdn).
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:first_name, :last_name, :msisdn, :email, :password])
    |> validate_required([:email, :password])
    |> validate_length(:first_name, max: 80)
    |> validate_length(:last_name, max: 80)
    |> validate_length(:msisdn, max: 32)
    |> validate_email(opts)
    |> validate_password(opts)
  end

  @doc """
  A profile changeset for updating name/msisdn (not for password/email).
  """
  def profile_changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :msisdn])
    |> validate_required([:first_name])
    |> validate_length(:first_name, max: 80)
    |> validate_length(:last_name, max: 80)
  end

  @doc """
  Admin changeset: used by admins to set role and superuser flag.
  """
  def admin_changeset(user, attrs) do
  user
  |> cast(attrs, [:role, :is_superuser])
  |> validate_inclusion(:role, @roles)
end

  @doc """
  Soft-delete changeset: sets `deleted_at`.
  """
  def soft_delete_changeset(user) do
    change(user, deleted_at: DateTime.utc_now())
  end

  #
  # Existing generator functions (kept mostly as-is) — email/password helpers
  #

  @doc """
  A user changeset for registering or changing the email.

  It requires the email to change otherwise an error is added.

  ## Options

    * `:validate_unique` - Set to false if you don't want to validate the
      uniqueness of the email, useful when displaying live validations.
      Defaults to `true`.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
  end

  defp validate_email(changeset, opts) do
    changeset =
      changeset
      |> validate_required([:email])
      |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/,
        message: "must have the @ sign and no spaces"
      )
      |> validate_length(:email, max: 160)

    if Keyword.get(opts, :validate_unique, true) do
      changeset
      |> unsafe_validate_unique(:email, Betting.Repo)
      |> unique_constraint(:email)
      |> validate_email_changed()
    else
      changeset
    end
  end

  defp validate_email_changed(changeset) do
    if get_field(changeset, :email) && get_change(changeset, :email) == nil do
      add_error(changeset, :email, "did not change")
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the password.

  Options:
    * `:hash_password` - whether to hash the password (default true).
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    # Additional validations can be added (format etc.)
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # Ensure hashing length safety (bcrypt)
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = DateTime.utc_now()
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Betting.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Quick helper: is this user an admin / superuser?
  """
  def admin?(%__MODULE__{is_superuser: true}), do: true
  def admin?(%__MODULE__{role: role}) when is_binary(role), do: role in ["admin", "superuser"]
  def admin?(_), do: false
end

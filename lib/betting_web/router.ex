defmodule BettingWeb.Router do
  use BettingWeb, :router

  import BettingWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BettingWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :require_frontend do
    plug BettingWeb.Plugs.Authorize, :require_frontend
  end

  pipeline :require_admin do
    plug BettingWeb.Plugs.Authorize, :require_admin
  end

  pipeline :require_superuser do
    plug BettingWeb.Plugs.Authorize, :require_superuser
  end

  ## ---------- Public ----------
  scope "/", BettingWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  ## ---------- Frontend user routes ----------
  scope "/", BettingWeb do
    pipe_through [:browser, :require_authenticated_user, :require_frontend]

    live "/games", GameLive.Index, :index
    live "/my-bets", BetLive.Index, :index
  end

  ## ---------- Admin routes ----------
  scope "/admin", BettingWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    live "/games", AdminLive.GameLive, :index
    live "/users", AdminLive.Index, :index
    live "/profit-report", AdminLive.ProfitReport, :index
  end

  ## ---------- Superuser routes ----------
  scope "/superadmin", BettingWeb do
    pipe_through [:browser, :require_authenticated_user, :require_superuser]

    live "/users", SuperAdminLive.Index, :index
    live "/roles", SuperAdminLive.Roles, :index
  end

  ## ---------- Dev only ----------
  if Application.compile_env(:betting, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BettingWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## ---------- Authentication ----------
  scope "/", BettingWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{BettingWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", BettingWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{BettingWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end

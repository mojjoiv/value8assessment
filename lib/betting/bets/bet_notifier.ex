defmodule Betting.Bets.BetNotifier do
  import Swoosh.Email
  alias Betting.Mailer
  alias Decimal, as: D

  @from_name "Betting Team"
  @from_email "noreply@betting.local"

  defp user_name(%{first_name: fnm, last_name: lnm}) when not is_nil(fnm) or not is_nil(lnm) do
    [fnm, lnm] |> Enum.filter(&(&1 && &1 != "")) |> Enum.join(" ")
  end
  defp user_name(%{email: email}), do: email
  defp user_name(_), do: "Player"

  @doc """
  Build and deliver a bet result email.

  ## Parameters
  - user: User struct with email and optional name fields
  - game: Game struct with home_team and away_team
  - bet: Bet struct with bet_type, stake, and odds
  - result: "won" or "lost" (string)
  - payout: Decimal amount or nil
  """
  def deliver_bet_result(user, game, bet, result, payout \\ nil) do
    name = user_name(user)
    subject = build_subject(game, result)

    email =
      new()
      |> to({name, user.email})
      |> from({@from_name, @from_email})
      |> subject(subject)
      |> html_body(build_html_body(name, game, bet, result, payout))
      |> text_body(build_text_body(name, game, bet, result, payout))

    case Mailer.deliver(email) do
      {:ok, _} -> {:ok, email}
      {:error, reason} -> {:error, reason}
    end
  end

  defp build_subject(game, result) do
    "Your bet on #{game.home_team} vs #{game.away_team} — #{String.upcase(result)}"
  end

  defp build_html_body(name, game, bet, result, payout) do
    """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background-color: #f8f9fa; padding: 20px; text-align: center; }
        .content { padding: 20px; }
        .result { font-weight: bold; color: #{result_color(result)}; }
        .footer { margin-top: 20px; padding-top: 20px; border-top: 1px solid #eee;
                 color: #666; font-size: 14px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h2>Betting Results</h2>
        </div>
        <div class="content">
          <p>Hello #{name},</p>
          <p>Your bet on <strong>#{game.home_team} vs #{game.away_team}</strong> has been settled.</p>

          <p><strong>Outcome:</strong> <span class="result">#{String.upcase(result)}</span></p>

          <p><strong>Bet Details:</strong></p>
          <ul>
            <li><strong>Type:</strong> #{bet.bet_type}</li>
            <li><strong>Stake:</strong> #{format_amount(bet.stake)}</li>
            <li><strong>Odds:</strong> #{format_odds(bet.odds)}</li>
          </ul>
          #{payout_section_html(payout)}
        </div>
        <div class="footer">
          <p>Thanks for playing — the Betting team.</p>
        </div>
      </div>
    </body>
    </html>
    """
  end

  defp build_text_body(name, game, bet, result, payout) do
    """
    Hello #{name},

    Your bet on #{game.home_team} vs #{game.away_team} has been settled.

    Outcome: #{String.upcase(result)}

    Bet Details:
    - Type: #{bet.bet_type}
    - Stake: #{format_amount(bet.stake)}
    - Odds: #{format_odds(bet.odds)}
    #{payout_section_text(payout)}

    Thanks for playing — the Betting team.
    """
  end

  defp payout_section_html(payout) when not is_nil(payout) do
    "<p><strong>Payout:</strong> #{format_amount(payout)}</p>"
  end
  defp payout_section_html(_), do: ""

  defp payout_section_text(payout) when not is_nil(payout) do
    "- Payout: #{format_amount(payout)}"
  end
  defp payout_section_text(_), do: ""

  defp result_color("won"), do: "#28a745"
  defp result_color("lost"), do: "#dc3545"
  defp result_color(_), do: "#6c757d"

  defp format_amount(amount) do
    case D.cast(amount) do
      {:ok, decimal} -> "$#{D.to_string(decimal, decimals: 2)}"
      _ -> "$#{amount}"
    end
  end

  defp format_odds(odds) do
    case D.cast(odds) do
      {:ok, decimal} -> D.to_string(decimal, decimals: 2)
      _ -> "#{odds}"
    end
  end
end

defmodule Betting.Bets.BetNotifier do

  import Swoosh.Email
  alias Betting.Mailer

  defp user_name(%{first_name: fnm, last_name: lnm}) when not is_nil(fnm) or not is_nil(lnm) do
    [fnm, lnm] |> Enum.filter(&(&1 && &1 != "")) |> Enum.join(" ")
  end
  defp user_name(%{email: email}), do: email
  defp user_name(_), do: "Player"

  @doc """
  Build and deliver a bet result email.

  result is "won" or "lost" (string). payout may be nil or a Decimal.
  """
  def deliver_bet_result(user, game, bet, result, payout \\ nil) do
    name = user_name(user)
    subject = "Your bet on #{game.home_team} vs #{game.away_team} — #{String.upcase(result)}"

    html =
      """
      <p>Hello #{name},</p>
      <p>Your bet on <strong>#{game.home_team} vs #{game.away_team}</strong> has been settled.</p>
      <p><strong>Outcome:</strong> #{String.upcase(result)}</p>
      <p><strong>Bet type:</strong> #{bet.bet_type} — <strong>Stake:</strong> #{bet.stake} — <strong>Odds:</strong> #{bet.odds}</p>
      """ <>
      (if payout != nil do
         "<p><strong>Payout:</strong> #{payout}</p>"
       else
         ""
       end) <>
      "<p>Thanks for playing — the Betting team.</p>"

    new()
    |> to({name, user.first_name})
    |> from({ "noreply@betting.local"})
    |> subject(subject)
    |> html_body(html)
    |> text_body("""
    Hello #{name},

    Your bet on #{game.home_team} vs #{game.away_team} has been settled.
    Outcome: #{String.upcase(result)}
    Bet type: #{bet.bet_type}
    Stake: #{bet.stake}
    Odds: #{bet.odds}
    #{if payout, do: "Payout: #{payout}", else: ""}
    """)
    |> Mailer.deliver()
  end
end

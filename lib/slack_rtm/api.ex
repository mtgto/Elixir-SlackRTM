defmodule SlackRtm.API do
  use HTTPoison.Base

  def process_url(token) do
    "https://slack.com/api/rtm.start?token=#{URI.encode token}"
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
  end
end

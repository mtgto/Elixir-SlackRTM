defmodule SlackRtm do
  require Logger

  @doc """
  Connect to Slack with API token, raising if an error occurs.

  ## Options

  `:token` is the Slack API token.
  """
  @spec open!(String.t) :: SlackRtm.State.t | no_return
  def open!(token) do
    case SlackRtm.API.get(token) do
      {:ok, _response = %HTTPoison.Response{status_code: status_code, body: %{"ok" => false, "error" => error}}} ->
        Logger.debug "error: #{error}, code: #{status_code}"
        raise RuntimeError, message: error
      {:ok, _response = %HTTPoison.Response{status_code: status_code, body: %{"ok" => true, "url" => url, "self" => _self, "team" => _team, "channels" => _channels, "groups" => _groups, "ims" => _ims, "bots" => _bots}}} ->
        Logger.debug "url: #{url}, code: #{status_code}, channels: #{inspect _channels}"
        socket = Socket.connect! url
        %SlackRtm.State{socket: socket}
      {:ok, _response = %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.debug "response: #{inspect body}, code: #{status_code}"
        raise RuntimeError, message: "unknown"
    end
  end

  @doc """
  Close the connection to Slack.
  """
  @spec close(SlackRtm.State.t) :: :ok | {:error, String.t}
  def close(_state = %SlackRtm.State{socket: socket}) do
    case Socket.Web.close(socket) do
      :ok -> :ok
      {:error, error} ->
        Logger.warn "Failed to close the connection. error: #{error}"
        {:error, error}
    end
  end

  @doc """
  Send a message to Slack, raising if an error occurs.

  It can not send a message longer than 4,000 chars by Slack RTM API limit.
  """
  @spec send!(SlackRtm.State.t, String.t, String.t) :: {:ok, SlackRtm.State.t} | no_return
  def send!(state = %SlackRtm.State{socket: socket, message_id: message_id}, message, channel) do
    json = Poison.Encoder.encode(%{id: message_id, type: "message", text: message, channel: channel}, []) |> IO.iodata_to_binary
    :ok = socket |> Socket.Web.send! {:text, json}
    {:ok, %SlackRtm.State{state | message_id: message_id + 1}}
  end

  @doc """
  Receive a message from Slack, raising if an error occurs.

  Raise an RuntimeError, when the connection is closed.
  """
  @spec recv!(SlackRtm.State.t) :: Map.t | no_return
  def recv!(state = %SlackRtm.State{socket: socket}) do
    case socket |> Socket.Web.recv! do
      {:text, text} ->
        Logger.debug "Receive text: #{inspect text}"
        Poison.decode!(text)
      {:binary, binary} ->
        Logger.debug "Receive ignorant binary: #{inspect binary}"
      {:ping, ping} ->
        Logger.debug "Receive ping, send the response automatically."
        socket |> Socket.Web.pong!(ping)
        recv!(state)
      {:pong, pong} ->
        Logger.debug "Receive pong: #{inspect pong}"
      {type, _, _} ->
        Logger.warn "Receive unknown type message: #{inspect type}"
    end
  end
end

defmodule Events do
  def start_link(socket) do
    Task.start_link(fn -> loop(socket) end)
  end

  defp loop(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        handle(socket, data)
        loop(socket)

      {:error, issue} ->
        IO.inspect(issue)
    end
  end

  defp handle(socket, data) do
    case data do
      <<_::16, _::32, 431::16, data::binary>> ->
        IO.inspect("auth data")

        <<
          key_len::16,
          key::bytes-size(key_len),
          login_len::16,
          login::bytes-size(login_len),
          password_len::16,
          password::bytes-size(password_len),
          mac_len::16,
          mac::bytes-size(mac_len),
          is_cheat::16,
          client_version::16
        >> = data

        res =
          Handlers.Auth.handle(%{
            login: login,
            password: password,
            mac: mac,
            is_cheat: is_cheat,
            client_version: client_version
          })

        :gen_tcp.send(
          socket,
          res
          |> Packets.pack()
        )

        nil

      <<0::8, 2::8>> ->
        :gen_tcp.send(socket, data)

      <<_::16, _::32, 432::16>> ->
        :gen_tcp.close(socket)

      _ ->
        IO.inspect(data)
    end
  end
end

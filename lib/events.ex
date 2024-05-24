defmodule Events do
  def start_link(socket) do
    Task.start_link(fn -> loop(socket, %{}) end)
  end

  defp loop(socket, storage) do
    IO.inspect("pid 2: #{inspect(self())}")

    receive do
      {:receive, data} ->
        handle(socket, data, storage)
        loop(socket, storage)

      {:new_login, login} ->
        loop(socket, Map.put(storage, :login, login))
    end
  end

  defp handle(socket, data, storage) do
    case data do
      # auth
      <<_::16, _::32, 431::16, data::binary>> ->
        IO.inspect("auth data")

        decode_data = Packets.Auth.decode(data)

        send(self(), {:new_login, decode_data.login})

        res =
          Handlers.Auth.handle(decode_data)

        :gen_tcp.send(
          socket,
          res
          |> Packets.pack()
        )

      # create character
      <<_::16, _::32, 435::16, data::binary>> ->
        IO.inspect("create character data")

        res =
          Handlers.CreateCharacter.handle(storage, Packets.CreateCharacter.decode(data))

        :gen_tcp.send(
          socket,
          res
          |> Packets.pack()
        )

      # enter game
      <<_::16, _::32, 433::16, data::binary>> ->
        IO.inspect("enter game data")

        res =
          Handlers.EnterGame.handle(storage, Packets.World.decode(data))

        :gen_tcp.send(
          socket,
          res
          |> Packets.pack()
        )

      # create pincode
      <<_::16, _::32, 346::16, data::binary>> ->
        IO.inspect("create pincode data")

        res =
          Handlers.CreatePincode.handle(storage, Packets.CreatePincode.decode(data))

        :gen_tcp.send(
          socket,
          res
          |> Packets.pack()
        )

      # update pincode
      <<_::16, _::32, 347::16, data::binary>> ->
        IO.inspect("update pincode data")

        res =
          Handlers.UpdatePincode.handle(storage, Packets.UpdatePincode.decode(data))

        :gen_tcp.send(
          socket,
          res
          |> Packets.pack()
        )

      # ping
      <<0::8, 2::8>> ->
        :gen_tcp.send(socket, data)

      # exit account
      <<_::16, _::32, 432::16>> ->
        :gen_tcp.close(socket)

        Cachex.dump(:accounts, "./database_accounts.dump")

      _ ->
        IO.inspect(data)
    end
  end
end

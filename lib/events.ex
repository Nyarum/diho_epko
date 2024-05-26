defmodule Events.AcceptData do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(state) do
    {:ok, %{socket: state.socket, storage: %{}}}
  end

  @impl true
  def handle_info({:tcp, socket, data}, state) do
    <<len::16, _::binary>> = data

    IO.inspect("data from client: #{inspect(data)}")

    IO.inspect("len from packet header: #{len}")
    IO.inspect("len of data from client: #{byte_size(data)}")

    data =
      if len != byte_size(data) do
        more_data = get_more_data(socket, len - byte_size(data))
        data <> more_data
      else
        data
      end

    Events.Handle.handle(socket, data, state.storage)

    :inet.setopts(socket, active: :once)
    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp_closed, socket}, state) do
    Logger.info("Client disconnected: #{inspect(socket)}")
    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp_error, socket, reason}, state) do
    Logger.error("Error on socket #{inspect(socket)}: #{reason}")
    {:noreply, state}
  end

  @impl true
  def handle_info({:new_login, login}, state) do
    Logger.info("Save new login to storage #{inspect(state)}")

    {:noreply, %{socket: state.socket, storage: Map.put(state.storage, :login, login)}}
  end

  def get_more_data(socket, len) do
    {:ok, data} = :gen_tcp.recv(socket, len)
    data
  end
end

defmodule Events.Handle do
  def handle(socket, data, storage) do
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

      # choice character
      <<_::16, _::32, 434::16>> ->
        IO.inspect("choice character data")

        res =
          Handlers.ChoiceCharacter.handle(storage)

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

      # remove character
      <<_::16, _::32, 436::16, data::binary>> ->
        IO.inspect("remove character data")

        res =
          Handlers.RemoveCharacter.handle(
            storage,
            Packets.CharacterScreen.decode_remove_character(data)
          )

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

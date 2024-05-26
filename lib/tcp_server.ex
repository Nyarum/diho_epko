defmodule TcpServer.NonBlocking do
  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    port = 1973

    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: 0, active: false, reuseaddr: true])

    Logger.info("Server started on port #{port}")
    {:ok, %{socket: socket}, {:continue, :accept}}
  end

  @impl true
  def handle_continue(:accept, state) do
    Logger.info("Waiting for connections...")
    accept_connections(state)
    {:noreply, state}
  end

  defp accept_connections(%{socket: socket} = state) do
    {:ok, client_socket} = :gen_tcp.accept(socket)

    :gen_tcp.send(
      client_socket,
      Packets.FirstDate.encode()
      |> Packets.pack()
    )

    {:ok, pid} = GenServer.start(Events.AcceptData, %{socket: client_socket})
    :gen_tcp.controlling_process(client_socket, pid)

    :inet.setopts(client_socket, active: :once)
    Logger.info("Client connected: #{inspect(client_socket)}")

    accept_connections(state)
  end
end

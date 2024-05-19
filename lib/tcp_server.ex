defmodule TcpServer do
  require Logger

  def accept(port) do
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
    #
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: 0, active: false, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    :gen_tcp.send(
      client,
      Packets.FirstDate.encode()
      |> Packets.pack()
    )

    {:ok, pid} = Events.start_link(client)

    serve(pid, client, <<>>, 0)
    loop_acceptor(socket)
  end

  defp serve(pid, socket, data, len) do
    case data do
      <<>> ->
        case :gen_tcp.recv(socket, 0) do
          {:ok, data} ->
            <<len::16, _::binary>> = data

            if byte_size(data) == len do
              send(pid, {:receive, data})
              serve(pid, socket, <<>>, 0)
            else
              serve(pid, socket, data, len)
            end

          {:error, issue} ->
            IO.inspect(issue)
        end

      _ ->
        case :gen_tcp.recv(socket, 0) do
          {:ok, new_data} ->
            plus_data =
              data <> new_data

            if byte_size(plus_data) == len do
              send(pid, {:receive, plus_data})
              serve(pid, socket, <<>>, 0)
            else
              serve(pid, socket, data, len)
            end

          {:error, issue} ->
            IO.inspect(issue)
        end
    end
  end
end

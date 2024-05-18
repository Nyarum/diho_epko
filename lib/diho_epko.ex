Application.ensure_all_started(:timex)

case System.argv() do
  ["run"] -> TcpServer.accept(1973)
  _ -> IO.puts("no args")
end

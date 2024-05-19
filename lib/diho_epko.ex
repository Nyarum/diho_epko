Application.ensure_all_started(:timex)

Cachex.Services.Overseer.start_link()

Supervisor.start_link(
  [
    {Cachex, name: :storage}
  ],
  strategy: :one_for_one
)

Cachex.load(:storage, "./database.dump")

Cachex.set!(:storage, "hello", "world")

Cachex.get!(:storage, "hello")
|> IO.inspect()

case System.argv() do
  ["run"] -> TcpServer.accept(1973)
  _ -> IO.puts("no args")
end

Cachex.dump(:storage, "./database.dump")

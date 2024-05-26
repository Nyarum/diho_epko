Application.ensure_all_started(:timex)

Cachex.Services.Overseer.start_link()

Supervisor.start_link(
  [
    {Cachex, name: :accounts}
  ],
  strategy: :one_for_one
)

children = [
  {TcpServer.NonBlocking, []}
]

opts = [strategy: :one_for_one, name: TcpServer.Supervisor]

Cachex.load(:accounts, "./database_accounts.dump")

case System.argv() do
  ["run"] ->
    Supervisor.start_link(children, opts)

    receive do
      _ -> IO.puts("no way")
    end

  _ ->
    IO.puts("no args")
end

Cachex.dump(:accounts, "./database_accounts.dump")

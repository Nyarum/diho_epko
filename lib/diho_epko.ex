Application.ensure_all_started(:timex)

Cachex.Services.Overseer.start_link()

Supervisor.start_link(
  [
    {Cachex, name: :accounts}
  ],
  strategy: :one_for_one
)

Cachex.load(:accounts, "./database_accounts.dump")

case System.argv() do
  ["run"] -> TcpServer.accept(1973)
  _ -> IO.puts("no args")
end

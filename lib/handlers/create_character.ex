defmodule Handlers.CreateCharacter do
  def handle(storage, create_character) do
    IO.inspect("login: #{Map.get(storage, :login)}")

    {:ok, account} = Cachex.get(:accounts, storage.login)

    account_append = Map.put(account, :characters, [create_character | account.characters])

    Cachex.set!(:accounts, storage.login, account_append)

    IO.inspect("account: #{inspect(Cachex.get(:accounts, storage.login))}")

    <<935::16, 0::16>>
  end
end

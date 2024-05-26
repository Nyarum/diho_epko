defmodule Handlers.CreateCharacter do
  def handle(storage, create_character) do
    {:ok, account} = Cachex.get(:accounts, storage.login)

    create_character = Map.put(create_character, :level, 1)
    create_character = Map.put(create_character, :job, "Newbie")

    IO.inspect("create character #{inspect(create_character)}")

    account_append = Map.put(account, :characters, [create_character | account.characters])

    Cachex.set!(:accounts, storage.login, account_append)

    <<935::16, 0::16>>
  end
end

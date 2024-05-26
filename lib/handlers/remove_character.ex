defmodule Handlers.RemoveCharacter do
  def handle(storage, remove_character) do
    {:ok, account} = Cachex.get(:accounts, storage.login)

    new_characters =
      Enum.filter(account.characters, fn character -> character.name != remove_character.name end)

    new_account = Map.update!(account, :characters, fn _ -> new_characters end)

    Cachex.set!(:accounts, storage.login, new_account)

    <<936::16, 0::16>>
  end
end

defmodule Storage.Character do
  def get_character(login, name) do
    {:ok, account} = Cachex.get(:accounts, login)

    Enum.find(account.characters, fn character -> character.name == name end)
  end
end

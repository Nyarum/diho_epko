defmodule Storage.Character do
  def get_character(login, name) do
    {:ok, account} = Cachex.get(:accounts, login)

    IO.inspect("account #{inspect(account)}")
    IO.inspect("name #{inspect(name)}")

    Enum.find(account.characters, fn character -> character.name == name end)
  end
end

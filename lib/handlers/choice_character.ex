defmodule Handlers.ChoiceCharacter do
  def handle(storage) do
    IO.inspect("choice character handler")

    res =
      case auth_info = Cachex.get!(:accounts, storage.login) do
        _ ->
          auth_info
      end

    Packets.CharacterScreen.encode(res.characters)
  end
end

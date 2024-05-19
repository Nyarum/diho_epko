defmodule Handlers.Auth do
  def handle(auth) do
    IO.inspect("auth handler")

    res =
      case auth_info = Cachex.get!(:accounts, auth.login) do
        nil ->
          new_auth = %{auth_info: auth, characters: []}
          Cachex.set!(:accounts, auth.login, new_auth)
          new_auth

        _ ->
          auth_info
      end

    Packets.CharacterScreen.encode(res.characters)
  end
end

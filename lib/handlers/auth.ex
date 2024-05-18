defmodule Handlers.Auth do
  def handle(auth) do
    Packets.CharacterScreen.encode()
  end
end

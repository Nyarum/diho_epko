defmodule Handlers.Chat do
  def handle(storage, data) do
    character = Storage.Character.get_character(storage.login, storage.active_char)

    IO.inspect("character id: #{inspect(character.id)}")

    <<501::16, storage.active_world::32, Packets.encode_string_with_null(data.msg)::binary>>
  end
end

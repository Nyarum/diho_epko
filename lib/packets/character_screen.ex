defmodule Packets.CharacterScreen do
  def encode() do
    data = <<0x7C, 0x35, 0x09, 0x19, 0xB2, 0x50, 0xD3, 0x49>>

    <<
      0::16,
      byte_size(data)::16,
      data::bits,
      0::8,
      1::8,
      0::32,
      12_820::32
    >>
  end
end

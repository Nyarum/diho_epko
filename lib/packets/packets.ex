defmodule Packets do
  def pack(opcode, data) do
    len = byte_size(data) + 8
    <<len::16, 128::little-32, opcode::16, data::binary>>
  end
end

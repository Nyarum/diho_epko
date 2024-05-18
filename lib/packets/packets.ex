defmodule Packets do
  def pack(data) do
    len = byte_size(data) + 8
    <<len::16, 128::little-32, data::binary>>
  end
end

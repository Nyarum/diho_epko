defmodule Packets do
  def pack(data) do
    len = byte_size(data) + 8
    <<len::16, 128::little-32, data::binary>>
  end

  def encode_string_with_null(str) do
    <<byte_size(str) + 1::16, str::utf8, 0::8>>
  end
end

defmodule Packets do
  def pack(data) do
    IO.inspect("len of data: #{byte_size(data)}")

    len = byte_size(data) + 6
    <<len::16, 128::little-32, data::binary>>
  end

  def encode_string_with_null(str) do
    <<byte_size(str) + 1::16, str::binary, 0::8>>
  end
end

defmodule Packets.CreatePincode do
  def decode(data) do
    <<hash_len::16, hash::bytes-size(hash_len)>> = data

    %{
      hash: hash
    }
  end

  def encode() do
  end
end

defmodule Packets.UpdatePincode do
  def decode(data) do
    <<old_hash_len::16, old_hash::bytes-size(old_hash_len), hash_len::16,
      hash::bytes-size(hash_len)>> = data

    %{
      old_hash: old_hash,
      hash: hash
    }
  end
end

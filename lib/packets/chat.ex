defmodule Packets.Chat do
  def decode(data) do
    <<msg_len::16, msg::bytes-size(msg_len)>> = data

    msg_string = :binary.part(msg, 0, msg_len - 1)

    %{
      msg: msg_string
    }
  end
end

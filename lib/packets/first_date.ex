defmodule Packets.FirstDate do
  def encode() do
    now = Timex.local()

    %{microsecond: {us, _}} = now

    first_date =
      now
      |> DateTime.truncate(:millisecond)
      |> Timex.format!("[{0M}-{0D} {0h24}-{0m}-{0s}-" <> "#{Integer.floor_div(us, 1000)}]")

    <<byte_size(first_date)::16, first_date::binary>>
  end
end

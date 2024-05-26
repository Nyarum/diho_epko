defmodule Packets.Action do
  @mstate_on 0x00
  @mstate_arrive 0x01
  @mstate_block 0x02
  @mstate_cancel 0x04
  @mstate_inrange 0x08
  @mstate_notarget 0x10
  @mstate_cantmove 0x20

  def decode(data) do
    <<world_id::32, move_count::32, action_type::8, point_size::16, from_x::32, from_y::32,
      to_x::32, to_y::32>> = data

    %{
      world_id: world_id,
      move_count: move_count,
      action_type: action_type,
      point_size: point_size,
      from_x: from_x,
      from_y: from_y,
      to_x: to_x,
      to_y: to_y
    }
  end

  def encode(data) do
    mediate = <<data.world_id::32, data.move_count::32, data.action_type::8, data.state::16>>

    mediate2 =
      if data.state != @mstate_on do
        mediate <> <<data.stop_state::16>>
      else
        mediate
      end

    <<508::16, mediate2::binary, data.point_size::16, data.from_x::32, data.from_y::32,
      data.to_x::32, data.to_y::32>>
  end
end

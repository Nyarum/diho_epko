defmodule Handlers.Action do
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

  def handle(storage, action) do
    Packets.Action.encode(%{
      world_id: action.world_id,
      move_count: action.move_count,
      action_type: action.action_type,
      state: 1,
      stop_state: 1,
      point_size: action.point_size,
      from_x: action.from_x,
      from_y: action.from_y,
      to_x: action.to_x,
      to_y: action.to_y
    })
  end
end

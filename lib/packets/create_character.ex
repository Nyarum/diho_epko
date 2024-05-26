defmodule Packets.CreateCharacter do
  defp item_attr(data) do
    <<id::little-16, is_valid::8>> = data

    %{id: id, is_valid: is_valid}
  end

  defp inst_attr(data) do
    <<id::little-16, value::little-16>> = data

    %{id: id, value: value}
  end

  defp item_grid(data) do
    <<
      id::little-16,
      num::little-16,
      endure_list_0::little-16,
      endure_list_1::little-16,
      energy_list_0::little-16,
      energy_list_1::little-16,
      forge_lv::little-8,
      db_params_0::little-32,
      db_params_1::little-32,
      inst_attrs_list::bits-size(160),
      item_attrs_list::bits-size(960),
      is_change::8
    >> = data

    inst_attrs =
      Enum.to_list(0..4)
      |> Enum.map(fn i -> inst_attr(:binary.part(inst_attrs_list, i * 4, 4)) end)

    item_attrs =
      Enum.to_list(0..39)
      |> Enum.map(fn i -> item_attr(:binary.part(item_attrs_list, i * 3, 3)) end)

    %{
      id: id,
      num: num,
      endures: [endure_list_0, endure_list_1],
      energies: [energy_list_0, energy_list_1],
      forge_lv: forge_lv,
      db_params: [db_params_0, db_params_1],
      inst_attrs: inst_attrs,
      item_attrs: item_attrs,
      is_change: is_change
    }
  end

  defp look(data) do
    <<ver::little-16, type_id::little-16, next::bytes-size(1620), hair::little-16>> = data

    item_grids =
      Enum.to_list(0..9) |> Enum.map(fn i -> item_grid(:binary.part(next, i * 162, 162)) end)

    %{ver: ver, type_id: type_id, item_grids: item_grids, hair: hair}
  end

  @spec decode(<<_::16, _::_*8>>) :: %{
          look: %{hair: char(), item_grids: list(), type_id: char(), ver: char()},
          map: binary(),
          name: binary()
        }
  def decode(data) do
    <<
      name_len::16,
      name::bytes-size(name_len),
      map_len::16,
      map::bytes-size(map_len),
      look_len::16,
      next::binary
    >> = data

    name_string = :binary.part(name, 0, name_len - 1)
    map_string = :binary.part(map, 0, map_len - 1)

    %{
      name: name_string,
      map: map_string,
      look: look(next)
    }
  end
end

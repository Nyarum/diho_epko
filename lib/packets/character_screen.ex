defmodule Packets.CharacterScreen do
  @spec item_grid(
          atom()
          | %{
              :db_params => list(),
              :endures => list(),
              :energies => list(),
              :forge_lv => integer(),
              :id => integer(),
              :inst_attrs => list(),
              :is_change => integer(),
              :item_attrs => list(),
              :num => integer(),
              optional(any()) => any()
            }
        ) :: <<_::8, _::_*1>>
  def item_grid(item_grid) do
    endures_bytes =
      List.foldr(item_grid.endures, <<>>, fn item, acc -> acc <> <<item::little-16>> end)

    energies_bytes =
      List.foldr(item_grid.energies, <<>>, fn item, acc -> acc <> <<item::little-16>> end)

    db_params_bytes =
      List.foldr(item_grid.db_params, <<>>, fn item, acc -> acc <> <<item::little-32>> end)

    inst_attrs_bytes =
      List.foldr(item_grid.inst_attrs, <<>>, fn item, acc ->
        acc <> <<item.id::little-16, item.value::little-16>>
      end)

    item_attrs_bytes =
      List.foldr(item_grid.item_attrs, <<>>, fn item, acc ->
        acc <> <<item.id::little-16, item.is_valid::8>>
      end)

    <<
      item_grid.id::little-16,
      item_grid.num::little-16,
      endures_bytes::bits,
      energies_bytes::bits,
      item_grid.forge_lv::8,
      db_params_bytes::bits,
      inst_attrs_bytes::bits,
      item_attrs_bytes::bits,
      item_grid.is_change::8
    >>
  end

  @spec look(
          atom()
          | %{
              :hair => integer(),
              :item_grids => list(),
              :type_id => integer(),
              :ver => integer(),
              optional(any()) => any()
            }
        ) :: <<_::8, _::_*1>>
  def look(look) do
    item_grids_bytes =
      List.foldr(look.item_grids, <<>>, fn item, acc -> acc <> item_grid(item) end)

    <<
      look.ver::little-16,
      look.type_id::little-16,
      item_grids_bytes::bits,
      look.hair::little-16
    >>
  end

  def encode_character(character) do
    is_active = 1
    look_bytes = look(character.look)
    job = "Newbie" <> <<0::8>>
    level = 1

    <<
      is_active::8,
      byte_size(character.name)::16,
      character.name::bits,
      byte_size(job)::16,
      job::bits,
      level::16,
      byte_size(look_bytes)::16,
      look_bytes::bits
    >>
  end

  @spec encode(list()) :: <<_::8, _::_*1>>
  def encode(characters) do
    data = <<0x7C, 0x35, 0x09, 0x19, 0xB2, 0x50, 0xD3, 0x49>>

    characters_bytes =
      List.foldr(characters, <<>>, fn item, acc -> acc <> encode_character(item) end)

    <<
      931::16,
      0::16,
      byte_size(data)::16,
      data::bits,
      length(characters)::8,
      characters_bytes::bits,
      1::8,
      0::32,
      12_820::32
    >>
  end
end

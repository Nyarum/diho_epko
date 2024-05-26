defmodule Packets.World do
  @syn_look_switch =: 0
  @syn_look_change =: 1

  def look_item_sync(li) do
    <<li.endure::16, li.energy::16, li.is_valid::8>>
  end

  def look_item_show(li) do
    endure_bytes =
      List.foldl(li.endure, <<>>, fn item, acc -> acc <> <<item::16>> end)

    energy_bytes =
      List.foldl(li.energy, <<>>, fn item, acc -> acc <> <<item::16>> end)

    <<
      li.num::16,
      endure_bytes::binary,
      energy_bytes::binary,
      li.forge_lv::8,
      li.is_valid::8
    >>
  end

  def look_item(li, syn_type) do
    id_bytes = <<li.id::16>>

    if li.id == 0 do
      <<id_bytes::binary>>
    else
      if syn_type == @syn_look_change do
        id_bytes <> look_item_show(li.item_show)
      else
        mediate_bytes = id_bytes <> look_item_sync(li.item_sync) <> <<li.is_db_params::8>>

        if li.is_db_params == 1 do
          db_params_bytes =
            List.foldl(li.db_params, <<>>, fn item, acc -> acc <> <<item::32>> end)

          mediate_bytes2 = mediate_bytes <> db_params_bytes <> <<li.is_inst_attrs::8>>

          if li.is_inst_attrs == 1 do
            inst_attrs_bytes =
              List.foldl(li.inst_attrs, <<>>, fn item, acc ->
                acc <> <<item.id::16, item.value::16>>
              end)

            mediate_bytes2 <> inst_attrs_bytes
          else
            mediate_bytes2
          end
        else
          mediate_bytes
        end
      end
    end
  end

  def look_human(human, syn_type) do
    item_grids_bytes =
      List.foldl(human.item_grids, <<>>, fn item, acc -> acc <> look_item(item, syn_type) end)

    <<human.hair_id::16, item_grids_bytes::binary>>
  end

  def look_boat(boat) do
    <<
      boat.pos_id::16,
      boat.boat_id::16,
      boat.header::16,
      boat.body::16,
      boat.engine::16,
      boat.cannon::16,
      boat.equipment::16
    >>
  end

  def look(look) do
    boat_or_human_bytes =
      case look.is_boat do
        1 ->
          look_boat(look.boat)

        0 ->
          look_human(look.human, look.syn_type)
      end

    <<look.syn_type::8, look.type_id::16, look.is_boat::8, boat_or_human_bytes::binary>>
  end

  def entity_event(ee) do
    <<
      ee.id::32,
      ee.value::8,
      ee.event_id::16,
      Packets.encode_string_with_null(ee.event_name)::binary
    >>
  end

  def side(side) do
    <<side.id::8>>
  end

  @spec position(
          atom()
          | %{:radius => integer(), :x => integer(), :y => integer(), optional(any()) => any()}
        ) :: <<_::96>>
  def position(pos) do
    <<pos.x::32, pos.y::32, pos.radius::32>>
  end

  def look_append(look_append) do
    <<look_append.look_id::16>> <>
      if look_append.look_id != 0 do
        <<look_append.is_valid::8>>
      else
        <<>>
      end
  end

  def base(base) do
    look_append_bytes =
      List.foldl(base.look_append, <<>>, fn item, acc ->
        acc <> look_append(item)
      end)

    <<
      base.cha_id::32,
      base.world_id::32,
      base.comm_id::32,
      Packets.encode_string_with_null(base.comm_name)::binary,
      base.gm_lvl::8,
      base.handle::32,
      base.ctrl_type::8,
      Packets.encode_string_with_null(base.name)::binary,
      Packets.encode_string_with_null(base.motto_name)::binary,
      base.icon::16,
      base.guild_id::32,
      Packets.encode_string_with_null(base.guild_name)::binary,
      Packets.encode_string_with_null(base.guild_motto)::binary,
      Packets.encode_string_with_null(base.stall_name)::binary,
      base.state::16,
      position(base.position)::binary,
      base.angle::16,
      base.team_leader_id::32,
      side(base.side)::binary,
      entity_event(base.entity_event)::binary,
      look(base.look)::binary,
      base.pk_ctrl::8,
      look_append_bytes::binary
    >>
  end

  def skill(skill) do
    params_bytes =
      List.foldl(skill.params, <<>>, fn item, acc -> acc <> <<item::16>> end)

    <<
      skill.id::16,
      skill.state::8,
      skill.level::8,
      skill.use_sp::16,
      skill.use_endure::16,
      skill.use_energy::16,
      skill.resume_time::32,
      skill.range_type::16,
      params_bytes::binary
    >>
  end

  def skill_bag(skill_bag) do
    skills_bytes =
      List.foldl(skill_bag.skills, <<>>, fn item, acc -> acc <> skill(item) end)

    <<
      skill_bag.skill_id::16,
      skill_bag.value_type::8,
      skill_bag.skill_num::16,
      skills_bytes::binary
    >>
  end

  def skill_state(skill_state) do
    <<skill_state.id::8, skill_state.level::8>>
  end

  def skill_states(skill_states) do
    states_bytes =
      List.foldl(skill_states.states, <<>>, fn item, acc -> acc <> skill_state(item) end)

    <<skill_states.len::8, states_bytes::binary>>
  end

  def attribute(attr) do
    <<attr.id::16, attr.value::16>>
  end

  def attributes(attributes) do
    attrs_bytes =
      List.foldl(attributes.attrs, <<>>, fn item, acc -> acc <> attribute(item) end)

    <<attributes.value_type::8, attributes.num::16, attrs_bytes::binary>>
  end

  @boat_id =: 3988

  def kitbag_item(kitbag_item) do
    grid_id = <<kitbag_item.grid_id::16>>

    if kitbag_item.grid_id != 65_535 do
      mediate_bytes = grid_id <> <<kitbag_item.id::16>>

      if kitbag_item.id > 0 do
        mediate_bytes2 = mediate_bytes <> <<kitbag_item.num::16>>

        endure_bytes =
          List.foldl(kitbag_item.endure, <<>>, fn item, acc -> acc <> <<item::16>> end)

        energy_bytes =
          List.foldl(kitbag_item.energy, <<>>, fn item, acc -> acc <> <<item::16>> end)

        mediate_bytes3 =
          mediate_bytes2 <>
            endure_bytes <>
            energy_bytes <>
            <<
              kitbag_item.forge_lv::8,
              kitbag_item.is_valid::8
            >>

        res =
          if kitbag_item.id == @boat_id do
            mediate_bytes3 <> <<kitbag_item.item_db_inst_id::32>>
          else
            mediate_bytes3
          end <>
            <<kitbag_item.item_db_id::32>> <>
            if kitbag_item.id == @boat_id do
              <<0::32>>
            else
              <<kitbag_item.item_db_inst_id::32>>
            end <>
            <<kitbag_item.is_params::8>> <>
            if kitbag_item.is_params == 1 do
              List.foldl(kitbag_item.inst_attrs, <<>>, fn item, acc ->
                acc <> <<item.id::16, item.value::16>>
              end)
            else
              <<>>
            end

        res
      else
        mediate_bytes
      end
    else
      grid_id
    end
  end

  def kitbag(kitbag) do
    IO.inspect("kitbag: #{inspect(kitbag)}")

    items_bytes =
      List.foldl(kitbag.items, <<>>, fn item, acc ->
        acc <> kitbag_item(item)
      end)

    <<kitbag.value_type::8, kitbag.num::16, items_bytes::binary>>
  end

  def shortcut(shortcut) do
    <<shortcut.value_type::8, shortcut.grid_id::16>>
  end

  def shortcuts(shortcuts) do
    List.foldl(shortcuts.items, <<>>, fn item, acc -> acc <> shortcut(item) end)
  end

  def boat(boat) do
    <<
      base(boat.base)::binary,
      attributes(boat.attribute)::binary,
      kitbag(boat.kitbag)::binary,
      skill_states(boat.skill_state)::binary
    >>
  end

  def encode(world) do
    character_boat_bytes =
      List.foldl(world.character_boat, <<>>, fn item, acc -> acc <> boat(item) end)

    <<
      516::16,
      world.enter_ret::16,
      world.auto_lock::8,
      world.kitbag_lock::8,
      world.enter_type::8,
      world.is_new_char::8,
      Packets.encode_string_with_null(world.map_name)::binary,
      world.can_team::8,
      base(world.character_base)::binary,
      skill_bag(world.character_skill_bag)::binary,
      skill_states(world.character_skill_state)::binary,
      attributes(world.character_attribute)::binary,
      kitbag(world.character_kitbag)::binary,
      shortcuts(world.character_shortcut)::binary,
      length(world.character_boat)::8,
      character_boat_bytes::binary,
      world.cha_main_id::32
    >>
  end

  def decode(data) do
    <<name_len::16, name::bytes-size(name_len)>> = data

    name_string = :binary.part(name, 0, name_len - 1)

    %{
      name: name_string
    }
  end

  def decode_choice_character(data) do
    <<name_len::16, name::bytes-size(name_len)>> = data

    name_string = :binary.part(name, 0, name_len - 1)

    %{
      name: name_string
    }
  end
end

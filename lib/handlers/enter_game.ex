defmodule Handlers.EnterGame do
  def handle(storage, enter_game) do
    item_grids =
      Enum.to_list(0..9)
      |> Enum.map(fn i ->
        %{
          id: 0
        }
      end)

    look_append =
      Enum.to_list(0..3)
      |> Enum.map(fn i ->
        %{
          look_id: 0
        }
      end)

    kitbag_items_len = 24

    kitbag_items =
      Enum.to_list(0..(kitbag_items_len - 1))
      |> Enum.map(fn i ->
        %{
          grid_id: i,
          id: 0
        }
      end)
      |> Kernel.++([%{id: 0, grid_id: 65_535}])

    shortcuts =
      Enum.to_list(0..35)
      |> Enum.map(fn i ->
        %{value_type: 0, grid_id: 0}
      end)

    Packets.World.encode(%{
      enter_ret: 0,
      auto_lock: 0,
      kitbag_lock: 0,
      enter_type: 1,
      is_new_char: 1,
      map_name: "garner",
      can_team: 1,
      character_base: %{
        cha_id: 4,
        world_id: 10_271,
        comm_id: 10_271,
        comm_name: "comm name",
        gm_lvl: 0,
        handle: 33_565_845,
        ctrl_type: 0,
        name: "name",
        motto_name: "motto name",
        icon: 0,
        guild_id: 0,
        guild_name: "guild name",
        guild_motto: "guild motto",
        stall_name: "stall name",
        state: 0,
        position: %{
          x: 217_475,
          y: 278_175,
          radius: 40
        },
        angle: 0,
        team_leader_id: 0,
        side: %{
          id: 0
        },
        entity_event: %{
          id: 10_271,
          value: 1,
          event_id: 0,
          event_name: "test event"
        },
        look: %{
          syn_type: 0,
          type_id: 4,
          is_boat: 0,
          human: %{
            hair_id: 2291,
            item_grids: item_grids
          }
        },
        pk_ctrl: 0,
        look_append: look_append
      },
      character_skill_bag: %{
        skill_id: 36,
        value_type: 0,
        skill_num: 0,
        skills: []
      },
      character_skill_state: %{
        len: 0,
        states: []
      },
      character_attribute: %{
        value_type: 0,
        num: 0,
        attrs: []
      },
      character_kitbag: %{
        value_type: 0,
        num: kitbag_items_len,
        items: kitbag_items
      },
      character_shortcut: %{
        items: shortcuts
      },
      character_boat: [],
      cha_main_id: 10_271
    })
  end
end

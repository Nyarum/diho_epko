defmodule Handlers.EnterGame do
  def handle(storage, enter_game) do
    {:ok, account} = Cachex.get(:accounts, storage.login)

    {is_new_char, updated_account} =
      Map.get_and_update(account, :is_new_char, fn current_value -> {current_value, 0} end)

    is_new_char_updated =
      if is_new_char == nil do
        1
      else
        is_new_char
      end

    Cachex.set!(
      :accounts,
      storage.login,
      updated_account
    )

    character = Storage.Character.get_character(storage.login, enter_game.name)

    IO.inspect(character.look, pretty: true, limit: 30000)

    item_grids =
      Enum.map(character.look.item_grids, fn item_grid ->
        if item_grid.id == 0 do
          %{id: item_grid.id}
        else
          %{
            id: item_grid.id,
            item_show: %{
              num: 1,
              endure: item_grid.endures,
              energy: item_grid.energies,
              forge_lv: 1,
              is_valid: 1
            },
            is_db_params: 1,
            db_params: item_grid.db_params,
            is_inst_attrs: 1,
            inst_attrs: item_grid.inst_attrs
          }
        end
      end)

    IO.inspect(item_grids, pretty: true, limit: 30000)

    IO.inspect("item len #{length(item_grids)}")

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
      is_new_char: is_new_char_updated,
      map_name: "garner",
      can_team: 1,
      character_base: %{
        cha_id: 4,
        world_id: 10_271,
        comm_id: 10_271,
        comm_name: "",
        gm_lvl: 0,
        handle: 33_565_845,
        ctrl_type: 0,
        name: character.name,
        motto_name: "",
        icon: 0,
        guild_id: 0,
        guild_name: "",
        guild_motto: "",
        stall_name: "",
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
          type_id: character.look.type_id,
          is_boat: 0,
          human: %{
            hair_id: character.look.hair,
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

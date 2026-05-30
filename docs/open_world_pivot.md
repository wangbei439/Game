# Open World Pivot Plan

## Direction

`代号：传说` is now a zone-based open world 2.5D action RPG.

The game should keep the existing combat, class, equipment, loot, boss, and dark neon visual foundations, but the outer structure changes from linear chapter stages into explorable regions with points of interest, NPCs, quests, resources, dynamic enemy zones, and regional bosses.

This is not a seamless MMO-scale world. The first production target is a compact, shippable open-world vertical slice that proves exploration, combat, progression, and reward loops work together.

## What Stays

- 2.5D action combat in 3D scenes with Sprite3D characters.
- Eight-class long-term design: warrior, ranger, assassin, mage, monk, knight, summoner, engineer.
- Equipment-driven stat growth, loot drops, item pickup, and inventory.
- Multi-phase boss design.
- Dark neon visual style.
- Existing six-region world concept:
  - Sky City
  - Dark Forest
  - Blacksmith Valley
  - Dragon Ridge
  - Abyss Rift
  - Trial Tower

## What Changes

- Chapters become open regions.
- Main quests become exploration-led quest chains.
- Bosses become regional events, hidden encounters, or dungeon anchors.
- Enemy placement shifts from hand-placed arena targets to spawn zones.
- Materials, harvesting, NPC services, and teleport points become core progression systems.
- The player should be able to wander, discover, fight, gather, return, upgrade, and push deeper.

## First Vertical Slice

The first playable slice should cover one safe hub and one wilderness region.

### Hub

Working name: `Sky City Outpost`

Purpose:
- Safe spawn point.
- Quest handoff.
- Inventory/equipment access.
- Basic healing or rest point.
- Teleport anchor.

Minimum content:
- 1 quest NPC.
- 1 equipment or blacksmith NPC placeholder.
- 1 teleport point.
- Exit path to the wilderness region.

### Wilderness Region

Recommended first region: `Dark Forest Outskirts`

Why:
- Matches current dark forest assets.
- Supports beginner enemies.
- Works with existing Dummy/Boss prototypes.
- Lets the game teach attack, dodge, pickups, and equipment.

Minimum content:
- 1 open exploration space.
- 3 points of interest.
- 2 enemy spawn zones.
- 1 harvesting zone.
- 1 elite enemy or mini-boss.
- 1 regional boss encounter.
- 1 unlockable teleport point.

## Points of Interest

The first region should contain:

- `Abandoned Camp`: tutorial pickup, first NPC hint, basic supplies.
- `Spore Grove`: harvesting point, low-risk enemy patrols.
- `Corrupted Shrine`: elite enemy and boss unlock trigger.

Each POI needs a clear player reason:
- See something.
- Walk toward it.
- Interact or fight.
- Get a reward.
- Unlock a new choice.

## Core Loop

The open-world loop should be:

1. Leave safe hub.
2. Explore a visible landmark.
3. Fight enemies or avoid them.
4. Collect loot/materials.
5. Complete a local objective.
6. Unlock a shortcut, teleport point, or boss access.
7. Return to hub.
8. Upgrade equipment.
9. Push deeper.

Combat remains the moment-to-moment core. Exploration exists to create context, pacing, and reward goals for combat.

## Systems To Build First

### WorldManager

Owns current region state.

Responsibilities:
- Track discovered POIs.
- Track unlocked teleport points.
- Track defeated regional bosses.
- Provide a central place for region-level state.

### RegionData

Resource data for a region.

Fields:
- region_id
- display_name
- recommended_level
- biome
- accent_color
- enemy_table
- harvest_table
- boss_scene
- teleport_points

### POI

A scene/node marking an explorable location.

Responsibilities:
- Discovery trigger.
- Optional objective state.
- Optional reward.
- Optional quest hook.

### SpawnZone

A placed scene node that spawns enemies within a bounded area.

Responsibilities:
- Spawn common enemies.
- Limit active enemies.
- Respawn after delay.
- Optionally stop spawning when a POI objective is complete.

### HarvestNode

Interactable material source.

Responsibilities:
- Give material item.
- Play feedback.
- Enter cooldown.
- Optionally require region discovery.

### TeleportPoint

Unlockable fast travel anchor.

Responsibilities:
- Activate on interaction.
- Register with WorldManager.
- Later open teleport UI.

### QuestManager

Small first version only.

Responsibilities:
- Track active quest id.
- Track objective counters.
- Advance one open-world tutorial quest chain.

Avoid building a huge quest editor at the start.

## First Quest Chain

Working title: `Whispers at the Forest Edge`

Steps:

1. Talk to outpost NPC.
2. Reach Abandoned Camp.
3. Defeat 3 forest creatures.
4. Harvest 2 spore clusters.
5. Activate forest teleport point.
6. Investigate Corrupted Shrine.
7. Defeat regional boss.
8. Return to outpost and receive equipment reward.

This quest chain proves:
- Navigation
- POI discovery
- Enemy spawning
- Combat
- Loot/material pickup
- Interaction
- Teleport unlock
- Boss gating
- Hub return
- Reward delivery

## Scene Strategy

Static world content should live in `.tscn` scenes, not be generated from scripts at runtime.

Recommended structure:

```text
scenes/
  world/
    hub/
      sky_city_outpost.tscn
    regions/
      dark_forest_outskirts.tscn
    poi/
      abandoned_camp.tscn
      spore_grove.tscn
      corrupted_shrine.tscn
    interactables/
      teleport_point.tscn
      harvest_node.tscn
    spawners/
      spawn_zone.tscn

scripts/
  world/
    world_manager.gd
    region_data.gd
    poi.gd
    spawn_zone.gd
    harvest_node.gd
    teleport_point.gd
  quest/
    quest_manager.gd
```

For the first implementation, `test_arena.tscn` can be converted into a prototype open-world test region instead of discarded.

## Current Project Reuse

Use existing assets/systems:

- `res://scenes/word/test_arena.tscn` as the initial prototype region.
- `res://dummy.tscn` as the first common enemy.
- `res://boss.tscn` as the first regional boss prototype.
- `res://loot_item.tscn` and `res://loot_item.gd` for rewards.
- `res://inventory_ui.tscn` and `res://scripts/inventory_ui.gd` for inventory.
- `res://scripts/player/player_move.gd` and `PlayerStats` for core player behavior.
- Dark forest background images for the first region.

## Implementation Order

1. Create world folder structure and data scripts.
2. Add `WorldManager` autoload or root node.
3. Build `SpawnZone` and use it to spawn existing Dummy enemies.
4. Build `POI` discovery triggers.
5. Build `HarvestNode` with one material reward.
6. Build `TeleportPoint` unlock state.
7. Build minimal `QuestManager` for the first quest chain.
8. Convert `test_arena.tscn` into `dark_forest_outskirts` prototype.
9. Add hub placeholder.
10. Connect hub -> region -> boss -> return loop.

## Quality Gate

The first open-world slice is acceptable when:

- Player can start in a safe hub.
- Player can enter a wilderness area.
- Player can discover at least 3 POIs.
- Spawn zones create enemies without script errors.
- Player can fight, loot, and gather.
- One teleport point can be unlocked.
- One boss encounter can be reached and completed.
- Quest state advances without manual intervention.
- Returning to hub grants a reward.
- Debug console has 0 runtime errors.

## Design Constraint

Open world should add meaningful choices, not empty walking time.

Every region must have:
- A visible landmark.
- A combat reason.
- A material reason.
- A progression reason.
- A return-to-hub reason.

If a zone does not serve at least two of these, it should not be built yet.

# ThatGameJam（Godot 4.5）

这是一个 Godot 4.5 项目（见 `project.godot`）。当前主场景是 `scenes/bar/dialogue/dialogue_box.tscn`（`project.godot` 的 `run/main_scene` 指向该场景的 UID）。

## 项目结构（目录约定）

> 说明：`.godot/` 是 Godot 编辑器生成的缓存/导入产物，通常不需要手动维护。

```text
.
├─ project.godot                # Godot 项目配置（含主场景、输入映射、autoload）
├─ scenes/                      # 主要场景（.tscn）与其脚本
│  ├─ bar/
│  │  ├─ bar.tscn               # 酒吧场景（含 DialogueDirector + Player）
│  │  ├─ bar_player/            # 酒馆玩家（走路）角色场景与脚本
│  │  ├─ bar_npc/               # 酒馆 NPC（含 Interactable 子节点）
│  │  └─ dialogue/              # 对话系统（DialogueBox/Runner/Director 与 Resource 脚本）
│  └─ ski/
│     ├─ ski.tscn               # 滑雪场景（地图/Parallax + Player 实例）
│     └─ ski_player.tscn        # 滑雪角色（测试/占位）
├─ scripts/                     # 可复用的通用脚本
│  └─ interactable.gd           # Interactable（Area2D）：鼠标 hover 提示 + 左键点击触发 interacted
├─ acts/                        # 对话/剧情资源（.tres）
│  └─ NPC/
│     ├─ Day1.tres
│     ├─ Day1_branch_left.tres
│     └─ Day1_branch_right.tres
├─ globals/                     # 全局单例（autoload）与全局资源
│  ├─ event_bus.gd              # 事件总线：场景切换、阶段变化、音频/对话事件等信号
│  ├─ game_state.gd             # 全局状态：day/flags/phase
│  ├─ scene_manager.gd          # 场景管理：监听 EventBus 并切换场景
│  └─ sound_manager/
│     ├─ sound_manager.tscn     # SoundManager 单例（节点树里挂 SFX/BGM 播放器）
│     └─ sound_manager.gd       # 播放 SFX/BGM 的 API
├─ assets/                      # 美术/字体等静态资源
│  ├─ fonts/
│  ├─ player/
│  ├─ ski/
│  ├─ bar/
│  └─ cursor/                   # 鼠标样式（arrow/link）
└─ music/                       # 音频资源
   ├─ bgm/
   └─ sfx/
	  └─ random_select/         # 随机音效选择用的 .tres
```

## Autoload（全局单例）

在 `project.godot` 的 `[autoload]` 中注册了以下单例（可全局访问）：

- `GameState` → `res://globals/game_state.gd`
- `EventBus` → `res://globals/event_bus.gd`
- `SceneManager` → `res://globals/scene_manager.gd`
- `SoundManager` → `res://globals/sound_manager/sound_manager.tscn`

## 打开与运行

使用 Godot 4.5 打开本目录下的 `project.godot`，直接运行即可（默认主场景：`scenes/bar/dialogue/dialogue_box.tscn`）。需要验证场景内容时，可以在编辑器里直接运行 `scenes/bar/bar.tscn` / `scenes/ski/ski.tscn`。

## 当前进度（概要）

- 对话框：`DialogueRunner` 默认隐藏，需要对话时 `start_act()` 自动显示；对话结束自动隐藏（见 `scenes/bar/dialogue/dialogue_runner.gd`）。
- 酒馆：`scenes/bar/bar.tscn` 里实例了 `bar_player`，并挂了 `DialogueDirector`（通过 `$DialogueBox` 驱动对话）。
- 互动：`scripts/interactable.gd` 负责 hover 时切换鼠标样式，左键点击时触发 `interacted`；离开时用 `Input.set_custom_mouse_cursor(null)` 还原默认鼠标。

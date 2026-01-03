# ThatGameJam（Godot 4.5）

这是一个 Godot 4.5 项目（见 `project.godot`）。当前主场景是 `scenes/menu/Menu.tscn`（`project.godot` 的 `run/main_scene` 指向该场景的 UID）。

## 项目结构（目录约定）

> 说明：`.godot/` 是 Godot 编辑器生成的缓存/导入产物，通常不需要手动维护。

```text
.
├─ project.godot                # Godot 项目配置（含主场景、输入映射、autoload）
├─ scenes/                      # 主要场景（.tscn）与其脚本
│  ├─ menu/                     # 菜单/过渡等入口场景
│  │  └─ Menu.tscn              # 当前主场景
│  ├─ bar/
│  │  ├─ bar.tscn               # 酒吧场景（含 DialogueDirector + Player）
│  │  ├─ bar_player/            # 酒馆玩家（走路）角色场景与脚本
│  │  ├─ bar_npc/               # 酒馆 NPC（含 Interactable 子节点）
│  │  └─ dialogue/              # 对话系统（一套“场景内版本”的 DialogueBox/Runner/Director）
│  └─ ski/
│     ├─ ski.tscn               # 滑雪场景（地图/Parallax + Player 实例）
│     ├─ ski.gd                 # 滑雪场景脚本（含计时结束切回 bar）
│     ├─ ski_controller.gd      # 实验：驱动雪道贴图沿 -dir 滚动（Shader UV）
│     ├─ snow_track.gdshader    # 实验：雪道滚动用的 canvas_item Shader（UV repeat）
│     ├─ snow_track.gd          # 雪道 WIP：双贴图交接/回收（TrackA/TrackB）
│     ├─ ski_player.tscn        # 滑雪角色（测试/占位）
│     └─ ski_player.gd          # 滑雪角色移动逻辑（测试）
│  ├─ dialogue_box.tscn          # 对话框 UI（当前 Bar 场景引用这一份）
│  └─ npc.tscn                   # NPC（带 Interactable 子节点）
├─ scripts/                     # 可复用的通用脚本（另一套“全局 class_name 版本”的对话脚本在这里）
│  ├─ interactable.gd           # Interactable（Area2D）：鼠标 hover 提示 + 左键点击触发 interacted
│  ├─ dialogue_act.gd            # DialogueAct（Resource）
│  ├─ dialogue_line.gd           # DialogueLine（Resource）
│  ├─ dialogue_runner.gd         # DialogueRunner（Control）
│  └─ dialogue_director.gd       # DialogueDirector（Node）
├─ acts/                        # 对话/剧情资源（.tres）
│  └─ NPC/
│     ├─ Day1.tres                  # DialogueDay：当天段落列表
│     ├─ Day1_01.tres               # DialogueAct：第 1 段
│     ├─ Day1_branch_left.tres
│     └─ Day1_branch_right.tres
├─ globals/                     # 全局单例（autoload）与全局资源
│  ├─ event_bus.gd              # 事件总线：场景切换、阶段变化、音频/对话事件等信号
│  ├─ game_state.gd             # 全局状态：day/flags/phase
│  ├─ scene_manager.gd          # 场景管理：监听 EventBus 并切换场景
│  ├─ cursor_manager.gd         # 全局鼠标样式（default / interactable）
│  ├─ dialogue_manager/         # 另一套“字符串数组式”的对话系统（基于 EventBus.request_dialogue）
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

- `CursorManager` → `res://globals/cursor_manager.gd`
- `GameState` → `res://globals/game_state.gd`
- `SubjectProgress` → `res://globals/subject_progress.gd`
- `EventBus` → `res://globals/event_bus.gd`
- `SceneManager` → `res://globals/scene_manager.gd`
- `SoundManager` → `res://globals/sound_manager/sound_manager.tscn`
- `Transition` → `res://globals/transition/transition.tscn`

## 打开与运行

使用 Godot 4.5 打开本目录下的 `project.godot`，直接运行即可（默认主场景：`scenes/menu/Menu.tscn`）。需要验证场景内容时，可以在编辑器里直接运行 `scenes/bar.tscn` / `scenes/ski/ski.tscn`。

## 当前进度（概要）

- 对话框（Resource 版）：`DialogueDirector` 根据 day/subject 加载 `acts/**/Day*.tres`（`DialogueDay` → `acts: Array[DialogueAct]`），再用 `SubjectProgress` 取下一段 `DialogueAct` 交给 `DialogueRunner` 播放；Runner 默认隐藏，`start_act()` 自动显示，结束自动隐藏。
- 酒馆：`scenes/bar.tscn` 里实例了 `bar_player`，并挂了 `DialogueDirector`（通过 `$DialogueBox` 驱动对话）。
- 互动：`scripts/interactable.gd` 在 hover 时通过 `CursorManager` 切换鼠标样式，并支持左键点击触发 `interacted`。
- 切场景：通过 `EventBus.go(scene_key)` 发起，`globals/scene_manager.gd` 监听后执行切场景，并在切换前后调用 `Transition.fade_out()/fade_in()`（含强制 `CursorManager.set_default()`）。
- 滑雪：`scenes/ski/ski.tscn` 目前以 `Parallax2D.autoscroll` 做远景/雪道滚动；`scenes/ski/ski.gd` 播放 BGM，并在 `SkiTimer` 到时让玩家按 `-dir` 滑出屏幕后再 `EventBus.go("bar")`。

## 常见警告

- `class xxx hides a global script class`：通常表示项目里有两份脚本写了同一个 `class_name xxx`（全局脚本类名冲突）。如果你后续再新增另一套同名对话脚本（例如在 `scripts/` 下再放一套 `DialogueAct/DialogueLine/DialogueRunner/DialogueDirector`），就会出现该提示。

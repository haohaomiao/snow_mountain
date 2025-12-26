# ThatGameJam（Godot 4.5）

这是一个 Godot 4.5 项目（见 `project.godot`）。当前主场景是 `scenes/dialogue_box.tscn`（`project.godot` 的 `run/main_scene` 指向该场景的 UID）。

## 项目结构（目录约定）

> 说明：`.godot/` 是 Godot 编辑器生成的缓存/导入产物，通常不需要手动维护。

```text
.
├─ project.godot                # Godot 项目配置（含主场景、输入映射、autoload）
├─ scenes/                      # 主要场景（.tscn）与其脚本
│  ├─ dialogue_box.tscn         # 当前主场景：对话 UI + 点击推进
│  ├─ player.tscn               # 玩家角色场景
│  ├─ player.gd                 # 玩家移动逻辑（CharacterBody2D）
│  ├─ bar/
│  │  └─ bar.tscn               # 酒吧场景（含 DialogueDirector + Player）
│  └─ ski/
│     └─ ski.tscn               # 滑雪相关场景（AnimatedSprite2D 动画资源）
├─ scripts/                     # 可复用的游戏逻辑脚本（非 autoload）
│  ├─ dialogue_act.gd           # DialogueAct（Resource）：对话 Act 数据容器
│  ├─ dialogue_line.gd          # DialogueLine（Resource）：单行对话/选项分支
│  ├─ dialogue_runner.gd        # DialogueRunner（Control）：驱动对话播放/选择
│  └─ dialogue_director.gd      # DialogueDirector（Node）：按 day/subject 取 Act 并启动 Runner
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
│  └─ bar/
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

使用 Godot 4.5 打开本目录下的 `project.godot`，直接运行即可（默认主场景：`scenes/dialogue_box.tscn`）。


# AGENTS.md

## 这是什么

WezTerm 配置目录，位于 `~/.config/wezterm/`。包含模块化 Lua 配置文件。非源代码仓库，无构建/测试系统。

## 配置结构

- `wezterm.lua` — 主入口，通过 `wezterm.config_builder()` 创建配置，循环加载 `config/` 下的子模块
- `config/*.lua` — 每个模块导出 `apply(config)` 函数，由主入口调用
- `config/constants.lua` — 共享常量（配色主题列表等）
- `config/utils.lua` — 工具函数（检测命令是否存在、判断系统平台）
- `fonts/` — 自定义字体目录，由 `config.fonts.lua` 中的 `font_dirs` 引用
- `images/` — 背景图片目录，由 `config.background.lua` 引用
- `config/events.lua` — 特殊模块：在 `apply()` 内通过 `wezterm.on()` 注册事件回调，不修改 config 参数

模块加载顺序即 `wezterm.lua` 中 `modules` 表的顺序，后加载的模块会覆盖先前的同名字段。

## 添加/修改配置

1. 找到对应的 `config/<name>.lua` 模块
2. 在 `apply(config)` 函数中修改 `config.*` 字段
3. 如需新增配置模块：创建 `config/<name>.lua`，实现 `apply(config)`，并在 `wezterm.lua` 的 `modules` 表末尾注册
4. 共享工具放入 `config/utils.lua`，常量放入 `config/constants.lua`

## 官方文档（联网查阅）

修改配置前若不确定字段含义或 API 用法，优先查阅官方文档：

- 配置文件机制与加载顺序：https://wezterm.org/config/files.html
- 完整 Lua 配置参考（含所有 `config.*` 字段、`wezterm` 模块、事件、对象方法）：https://wezterm.org/config/lua/general.html
- 内置配色方案名称列表（用于 `config.color_scheme` 或 `constants.COLOR_SCHEMES`）：https://wezterm.org/colorschemes/index.html

## 验证配置

WezTerm 启动时会解析配置，语法错误会弹窗提示。也可以命令行测试：

```powershell
# 检查 Lua 语法（不启动 GUI）
wezterm start --no-auto-connect --always-new-process -- exit 0

# 列出可用字体
wezterm ls-fonts

# 列出当前按键绑定
wezterm show-keys
```

## 重载配置

- WezTerm 自动监视配置文件变化并热重载，无需手动操作
- 或关闭并重新启动 WezTerm（会触发会话自动恢复）

## 注意

- `config.keybindings.lua` 中 `disable_default_key_bindings = true`，默认快捷键全部禁用，新增绑定需自行定义完整动作
- 多模块可能写同一嵌套表（如 `config.colors`），设置子字段前先用 `config.colors = config.colors or {}` 保护，避免覆盖先前模块的字段
- `wezterm.target_triple` 在 Windows 上包含 `"windows"` 子串，`utils.is_windows()` 以此判断平台
- `config/telnet.lua` 中的 Telnet 条目依赖 **PuTTY** 的 `plink.exe`，需安装 PuTTY 到 `C:\Program Files\PuTTY\` 或修改对应路径；快捷键 `Ctrl+Shift+E` 弹出 Telnet 目标选择器
- `config/telnet.lua` 通过 `table.insert(config.keys, ...)` 自行注入按键，加载顺序必须排在 `keybindings.lua` 之后
- SSH 域 `multiplexing = "None"`，每次连接建立全新 SSH 会话

## 会话保存与恢复（resurrect）

- `config/resurrect.lua` 基于第三方插件 [resurrect.wezterm](https://github.com/MLFlexer/resurrect.wezterm)（原仓库已归档，仍可用）实现标签页布局的保存与恢复
- 插件通过 `wezterm.plugin.require()` 自动下载到 `%APPDATA%\wezterm\plugins\`（还依赖 chrisgve/dev.wezterm）；首次下载需网络代理
- 状态文件保存在 `~/.local/share/wezterm/resurrect/`（json 格式，含窗口/标签/窗格布局与终端输出，注意可能含敏感内容）
- 行为：纯手动。`Ctrl+Shift+S` 输入名称保存当前工作区布局；`Ctrl+Shift+R` 选择工作区恢复到当前窗口（关闭已有标签）；`Ctrl+Shift+D` 选择工作区删除状态文件。无自动保存、无启动自动恢复
- SSH 域标签页（`config/ssh_domains.lua` 定义的域）恢复时会自动重新连接；Telnet（plink）标签页只恢复布局和输出文本，需手动重连（`Ctrl+Shift+E`）
- 插件的 `change_state_save_dir()` 在 Windows 上有 mkdir 引号 bug，模块中改为手动建目录后直接赋值 `state_manager.save_state_dir`，勿改回官方 API
- 插件加载时会执行 3 条残缺 mkdir 命令（`os.execute`），每次闪一个 cmd 黑框；模块在 `require` 插件期间临时屏蔽了 `os.execute`，勿删除该屏蔽代码
- 插件的 fuzzy 选择器在 Windows 上用 wscript(VBS) 扫描状态目录（慢且闪黑框），已弃用；`Ctrl+Shift+R` 改为模块内用 `wezterm.read_dir` 即时扫描 + 原生 `InputSelector` 实现
- `config/resurrect.lua` 通过 `table.insert(config.keys, ...)` 自行注入按键，加载顺序必须排在 `keybindings.lua` 之后

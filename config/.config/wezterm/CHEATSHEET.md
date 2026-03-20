# WezTerm Cheatsheet

Custom cheatsheet for this repo's WezTerm config.

## Legend

- `Leader` = `Ctrl+a` (timeout: 1200ms)
- Mode tables (`nav`, `tab`, `workspace`, `pane`, `session`, `resize`) exit with `Esc` or `Enter`.

## Global Essentials

| Action | Key |
| --- | --- |
| Send literal `Ctrl+a` | `Leader` then `Ctrl+a` |
| Command palette | `Leader` then `Space` or `/` |
| Copy mode | `Leader` then `c` |
| Fullscreen toggle | `Leader` then `f` |
| Fuzzy launcher (tabs + workspaces) | `Leader` then `l` |
| Previous/next tab | `Leader` then `[` / `]` |
| Jump to tab by number | `Leader` then `1..0` |
| Prompt tab number jump | `Leader` then `g` |
| Focus pane (macOS) | `Cmd+Alt+Arrow` |
| Shell word jump | `Option+Left` / `Option+Right` |

## Workspace Management

### Fast workspace actions

- `Leader` then `w` enters `workspace_mode`:
  - `l`: fuzzy workspace switcher
  - `n`: prompt to switch/create workspace
  - `m`: switch to `main`
  - `b`: bootstrap a workspace template

- `Leader` then `s` enters `session_mode`:
  - `b`: bootstrap template
  - `w`: fuzzy workspace switcher
  - `t`: fuzzy tabs + workspaces
  - `n`: prompt switch/create workspace

### Built-in workspace templates

- `Project Stack` -> workspace `project`
  - tabs: `editor`, `git`, `server`, `tests`, `logs`
- `10 Shells` -> workspace `multishell`
  - tabs: `shell-01` ... `shell-10`
- `Triage` -> workspace `triage`
  - tabs: `inbox`, `prod`, `staging`, `db`, `observe`, `scratch`

Templates open tabs in the current pane's directory (`$CURRENT_CWD` fallback behavior in config).

## Tab Management

- `Leader` then `t` enters `tab_mode`:
  - `c`: new tab
  - `x`: close current tab (with confirm)
  - `r`: rename tab
  - `n`: tab navigator
  - `p`: previous active tab
  - `h` / `l`: previous/next tab
  - `H` / `L`: move tab left/right
  - `g`: prompt tab-number jump
  - `1..0`: direct tab jump

## Pane Management

- `Leader` then `p` enters `pane_mode`:
  - `v`: split vertical
  - `s`: split horizontal
  - `h/j/k/l` or arrows: move pane focus
  - `z`: zoom/unzoom pane
  - `x`: close pane (with confirm)
  - `o`: rotate panes clockwise
  - `r`: enter resize mode

- In `resize_mode`:
  - `h/j/k/l` or arrows resize active pane by 2 cells

## Navigation Mode

- `Leader` then `n` enters `nav_mode`:
  - `h/l` or left/right: previous/next tab
  - `j/k`: down/up pane focus
  - `t`: tab navigator
  - `w`: fuzzy workspaces
  - `s`: fuzzy tabs
  - `p`: last active tab
  - `g`: prompt tab-number jump
  - `1..0`: direct tab jump

## Useful Tricks

- Use `Leader` -> `w` -> `b` at the start of a task to bootstrap a full workspace layout in one shot.
- Use `Leader` -> `t` -> `r` to keep tab titles meaningful; status bar and tab formatting make this easy to scan.
- Use `Leader` -> `p` -> `z` to temporarily focus one pane during debugging, then unzoom to restore layout.
- Use `Leader` -> `l` as your "jump anywhere" command (tabs + workspaces with fuzzy search).
- Watch left status for context:
  - Shows active workspace by default
  - Shows active key table (mode) while in modal bindings
  - Shows `LDR` when leader is active


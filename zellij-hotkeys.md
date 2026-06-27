# Zellij Hotkeys

Zellij is modal. Enter a mode with the listed shortcut; press `Esc` to return to Normal.

## Global
| Key      | Action                                      |
|----------|---------------------------------------------|
| `Ctrl+g` | Toggle Locked mode (disable/enable all shortcuts) |
| `Ctrl+q` | Quit                                        |

## Modes (from Normal)
| Key      | Mode     |
|----------|----------|
| `Ctrl+p` | Pane     |
| `Ctrl+t` | Tab      |
| `Ctrl+n` | Resize   |
| `Ctrl+h` | Move pane |
| `Ctrl+s` | Scroll   |
| `Ctrl+o` | Session  |

## Pane mode (`Ctrl+p`)
| Key                  | Action                    |
|----------------------|---------------------------|
| `h/j/k/l` / arrows  | Focus pane                |
| `n`                  | New pane (default direction) |
| `d`                  | Split down                |
| `r`                  | Split right               |
| `x`                  | Close pane                |
| `f`                  | Toggle fullscreen         |
| `w`                  | Toggle floating pane      |
| `z`                  | Toggle pane frames        |
| `c`                  | Rename pane               |
| `s`                  | New stacked pane          |

## Tab mode (`Ctrl+t`)
| Key                 | Action                                     |
|---------------------|--------------------------------------------|
| `h/l` / arrows      | Switch tab                                 |
| `n`                 | New tab                                    |
| `x`                 | Close tab                                  |
| `r`                 | Rename tab                                 |
| `b`                 | Break pane into new tab                    |
| `s`                 | Toggle sync (broadcast input to all panes) |

## Resize mode (`Ctrl+n`)
| Key                 | Action             |
|---------------------|--------------------|
| `h/j/k/l` / arrows | Resize active pane |

## Scroll mode (`Ctrl+s`)
| Key                 | Action                      |
|---------------------|-----------------------------|
| `j/k` / arrows      | Scroll line                 |
| `Ctrl+f / Ctrl+b`   | Page down / up              |
| `u / d`             | Half-page up / down         |
| `e`                 | Open scrollback in `$EDITOR` |
| `/`                 | Search in scrollback        |

## Session mode (`Ctrl+o`)
| Key | Action                              |
|-----|-------------------------------------|
| `d` | Detach (session keeps running)      |
| `w` | Session manager (switch/create sessions) |

## Reattach
```
zellij attach        # attach to most recent session
zellij attach <name> # attach by name
zellij ls            # list sessions
```

# OPEN - Config VM with CLAUDE.md, AGENTS.md, MCPs (sort of), skills

I want to make this debian sandbox as similar as an another computer I have. Some minimum things to take into account:
- AGENTS.md
- CLAUDE.md (based on AGENTS.md but with some custom CLAUDE entries)
- Skills
- MCPs

## This is my global CLAUDE.md:

```md
# CLAUDE.md

- Create a MANUAL.md file while you add features. Every time you add/update/remove a feature, update this file.
- At the end of each plan, show a summary of what changed.


## Plan Mode

- Make the plan extremely concise. Sacrifice grammar for the sake of concision.
- At the end of each plan, give me a list of unresolved questions to answer, if any.
```


## This is My settings.json
```json
{
  "enabledPlugins": {
    "frontend-design@claude-plugins-official": true,
    "context7@claude-plugins-official": true,
    "typescript-lsp@claude-plugins-official": true,
    "gopls-lsp@claude-plugins-official": true,
    "pyright-lsp@claude-plugins-official": true
  },
  "effortLevel": "xhigh",
  "skipWorkflowUsageWarning": true,
  "theme": "dark-ansi",
  "editorMode": "vim",
  "agentPushNotifEnabled": true,
  "voiceEnabled": false
}

```

## For the skills/

```
- 2026-06-09 15:03  roborev-design-review
- 2026-06-09 15:03  roborev-design-review-branch
- 2026-06-09 15:03  roborev-fix
- 2026-06-09 15:03  roborev-refine
- 2026-06-09 15:03  roborev-respond
- 2026-06-09 15:03  roborev-review
- 2026-06-09 15:03  roborev-review-branch
```

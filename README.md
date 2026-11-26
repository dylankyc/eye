# eye

**See what your Claude Code sessions actually did.** `eye` reads the session logs Claude Code
keeps in `~/.claude` and shows them as a fast terminal viewer for the folder you're in, or as a
local web app for every project on your machine.

- **Transcripts.** Turn by turn: prompts, replies, thinking, every tool call with its result.
  Edits show as diffs, and failed calls are flagged.
- **The exact LLM requests.** Each model call is reconstructed from Claude Code's request log:
  system prompt, tools, every message, what was new in that call, and where the cache
  breakpoints sat.
- **Subagents and background tasks.** Each subagent opens as its own thread, and you can see
  background tasks start and finish.
- **Context and cost.** Context-window size over time (compactions included), tokens, cache
  hits, cost, time spent per tool.
- **Memory.** Project memory, `MEMORY.md`, and the CLAUDE.md files each session loaded.
- **Live.** Follow a running session as it is written: `eye tail`, the TUI, or the web UI.

`eye` only **reads** `~/.claude`. Nothing is uploaded, and the web UI listens on `127.0.0.1` only.

## Install

**macOS (Apple Silicon) and Linux (x86_64, arm64)**

```sh
curl -fsSL https://raw.githubusercontent.com/dylankyc/eye/main/install.sh | sh
```

The script installs to `~/.local/bin` by default; set `EYE_INSTALL_DIR` to choose another
directory, or `EYE_VERSION=v0.1.0` to pin a version. It verifies the SHA-256 checksum before
installing.

**Windows (x86_64)**: in PowerShell:

```powershell
irm https://raw.githubusercontent.com/dylankyc/eye/main/install.ps1 | iex
```

**Manual download.** Every release has one archive per platform plus `SHA256SUMS`:

| Platform | Archive |
|---|---|
| macOS, Apple Silicon | `eye-aarch64-apple-darwin.tar.gz` |
| Linux x86_64 (static, any distro) | `eye-x86_64-unknown-linux-musl.tar.gz` |
| Linux arm64 (static, any distro) | `eye-aarch64-unknown-linux-musl.tar.gz` |
| Windows x86_64 | `eye-x86_64-pc-windows-gnu.zip` |

Unpack it and put `eye` (`eye.exe`) on your `PATH`. On macOS, a file downloaded with a browser
is quarantined; clear that with `xattr -d com.apple.quarantine ./eye`.

## Terminal: the folder you're in

```sh
cd ~/code/my-app
eye check        # is this folder a Claude Code project?
eye              # interactive viewer for this folder's sessions
```

`eye check` exits with **0** when sessions were recorded for this folder, **2** when the folder
is set up for Claude Code (`CLAUDE.md`, `.claude/`, `.mcp.json`) but has no sessions yet, and
**1** otherwise. It also points you to a parent folder or sub-folders that do have sessions.

| Command | What it shows |
|---|---|
| `eye` | Interactive viewer: session list plus Transcript, Agents, Tasks, Requests, Metrics and Memory tabs |
| `eye list` | Sessions for this folder, newest first |
| `eye show [SESSION] [-e]` | A transcript; `-e` expands tool inputs, results and diffs |
| `eye tail [SESSION]` | Follows a session live as Claude Code writes it |
| `eye stats [SESSION]` | Tokens, cache, cost, tool usage and a context-window sparkline (whole folder without SESSION) |
| `eye agents [SESSION]` | Subagent tree with status, model, duration and result |
| `eye tasks [SESSION]` | Background tasks (background shells, async agents) |
| `eye requests [SESSION] [N]` | The model requests; with `N`, the full reconstructed request |
| `eye memory` | Project memory and instruction files |
| `eye export [SESSION] -o file.md` | Markdown (or `--format json`) export |
| `eye resume [SESSION] [--fork]` | Back into Claude Code (`claude --resume`) |

`SESSION` can be `latest` (the default), a number from `eye list`, or the start of a session id
(`6d1f`). Most commands take `--json`. `-C <path>` looks at another folder.

**Viewer keys:**

| Keys | Action |
|---|---|
| `↑ ↓` | move / scroll |
| `⏎` | open |
| `esc` | back |
| `⇥` or `1`–`6` | switch tab |
| `[ ]` | main agent ↔ subagents |
| `n p` | step through requests |
| `e` | expand |
| `t` | show thinking |
| `/` | filter |
| `G` | follow the end |
| `R` | resume in Claude Code |
| `?` | help |
| `q` | quit |

## Web: every project

```sh
eye serve        # http://127.0.0.1:18088, opens your browser at the current folder
```

The web UI covers every project and session on the machine. It has:

- search across all sessions (`⌘K`);
- the request inspector, a subagent tree, and context-window and token charts;
- stars, tags and notes;
- live updates while sessions run.

Running `eye serve` again reuses a server that is already running.

| Option | Effect |
|---|---|
| `--port 18088` | Change the port |
| `--no-open` | Don't open a browser |
| `--enable-control` | Let the UI send prompts to sessions; it runs `claude -p --resume` / `--fork-session` on your machine. Off by default |

Stars, tags and notes are stored in `~/.local/share/eye` (`%APPDATA%\eye` on Windows), never in
`~/.claude`.

## Requirements

- Claude Code session data in `~/.claude`, or the folder set in `CLAUDE_CONFIG_DIR`.
- A recent Claude Code version for request reconstruction. Older sessions still show
  transcripts, agents and metrics.

## License

Free to download and use, in binary form. All rights reserved; see [LICENSE](LICENSE).

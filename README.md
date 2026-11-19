# admin-scripts

Bash scripts for everyday Linux system administration tasks, plus the method I use to build them.

I'm an IT Support Tier 2 analyst working toward systems administration. This repo documents how I learn scripting: plan the task in plain words, look up the commands by hand, then translate each sentence into code.

## Scripts

| Script | What it does | What I learned |
|---|---|---|
| [`services.sh`](services.sh) | Checks that important services are running and writes an OK / WARNING report | `for` loops, `if`/`else`, `systemctl is-active`, writing to a file with `>` and `>>` |
| [`healthcheck.sh`](healthcheck.sh) | Read-only health report: uptime, disk usage per mount (warns above a threshold) and available memory | Reading command output in a `while` loop, comparing numbers, pipes (`\|`), `awk` |

All scripts are read-only: they report on the system and change nothing.

### How to run

```bash
chmod +x services.sh healthcheck.sh
./services.sh
./healthcheck.sh
```

Reports are saved in `~/scripts/`.

---

## My method: how I build a script

Every admin script is built the same way: **say it in plain words first, then turn each sentence into one building block.**

Use the terminal's built-in manual pages: `man command` shows how any command works (press `q` to quit). `command --help` gives a short summary.

### The 5 building blocks

| Plain words | Bash building block |
|---|---|
| "remember this value" | `NAME=value`, used later as `$NAME` |
| "the result of a command" | `$(command)` |
| "for each item in a list" | `for x in $LIST; do … done` |
| "if this is true… otherwise…" | `if command; then … else … fi` |
| "write it to a file" | `>` starts a new file, `>>` adds to the end |

### The frame (Bash's "DOCTYPE")

Just like HTML starts with `<!DOCTYPE html>`, every script starts with this frame:

```bash
#!/usr/bin/env bash
# PURPOSE: what this script does, in one sentence

# --- 1. SETTINGS: names, lists, limits, file paths you might change ---

# --- 2. START: create the report file ---

# --- 3. WORK: for each thing... if... else... ---

# --- 4. FINISH: show the result ---
```

- `#!/usr/bin/env bash` tells Linux to run the file with Bash.
- Lines starting with `#` are notes to yourself, like HTML comments.

### Finding the names

Names usually don't come from memory. Explore by hand in the terminal first, then put what works into the script.

| What you need | Command that lists it |
|---|---|
| Services | `systemctl list-units --type=service` |
| Users | `cut -d: -f1 /etc/passwd` |
| Disks | `df -h` |
| Big files or folders | `du -sh ~/*` |
| Installed packages | `apt list --installed` |
| "Which command does X?" | `apropos disk` (search any word) |

### The whole process

1. Write your plan in plain words.
2. For each sentence, find the command by hand in the terminal until it shows what you want.
3. Copy the working commands into the right section of the frame.

### Worked example

**The plan:** *For each important service on my computer, check if it's running. If it is, write OK in a report. If not, write WARNING. Show me the report at the end.*

| Plain sentence | Code |
|---|---|
| For each important service | `SERVICES="cron NetworkManager systemd-journald"` then `for svc in $SERVICES; do` |
| check if it's running | `if systemctl is-active --quiet "$svc"; then` |
| If it is, write OK in a report | `echo "OK: $svc is running" >> "$REPORT"` |
| If not | `else` |
| write WARNING | `echo "WARNING: $svc is NOT running" >> "$REPORT"`, then `fi` and `done` |
| Show me the report | `cat "$REPORT"` |
| (the report itself) | `REPORT=~/scripts/services.txt` and `echo "Service check $(date)" > "$REPORT"` |

**Important:** the script runs in a different order from the sentences. The report must exist before you can write into it, so it goes near the top. That's what the frame's sections are for. The finished result is [`services.sh`](services.sh).

### Bash grammar

Commands like `systemctl`, `echo` and `cat` are the nouns and verbs. Connecting words turn them into a sentence Bash understands, like "CAR DRIVES BEACH" becomes "the car drives to the beach."

| Connecting word | Means |
|---|---|
| `in` | "…from this list" |
| `do` … `done` | "start doing this" … "stop, go to the next item" |
| `then` | "…then do this" |
| `else` | "otherwise…" |
| `fi` | "end of the if" (if spelled backwards) |
| `;` | "end of this part of the sentence" |

| Symbol | Means |
|---|---|
| `$` | "the value stored in…" (`$svc` = whatever svc holds right now) |
| `" "` | "keep this together as one thing" |
| `>` / `>>` | "into a new file" / "add to the end of the file" |
| `\|` | "pass the result on to the next command" |
| `&&` | "only if that worked, then do this next" |

Read as a sentence, the loop says: *for each svc in the SERVICES list, do: if it's active, then write OK; else write WARNING; fi. done.*

**Indentation** is only for humans in Bash: the script works without it, but it shows which lines belong to which block. (In Python, indentation is required.)

**Most common error:** blocks open and close in pairs, like HTML tags: `if` … `fi`, `do` … `done`. A missing closing word gives `syntax error: unexpected end of file`, the same kind of mistake as an unclosed `<div>`.

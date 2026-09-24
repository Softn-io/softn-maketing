#!/usr/bin/env bash
# env-guard — PreToolUse · Read | Write | Edit | MultiEdit | NotebookEdit | Bash
#
# Blocks any access (read AND write) to environment files that may contain
# secrets: .env, .env.local, .env.production, .env.<anything>.
# Also covers Bash commands that touch them (cat, echo >>, sed -i, cp, tee…).
# .env.example (documented placeholders) stays allowed.
#
# Replaces env-write-guard.sh (which only covered Write/Edit).
#
# Input on stdin: { "tool_name": "...", "tool_input": { "file_path": "..." | "command": "..." } }
# Exit 2 = block. stderr is surfaced to Claude.
#
# A guardrail, not a wall: a deliberately obfuscated command can get through.
# It complements the `deny` rules in .claude/settings.json.

set -euo pipefail

payload=$(cat)

verdict=$(PAYLOAD="$payload" /usr/bin/env python3 -c '
import json, os, re, sys

try:
    data = json.loads(os.environ.get("PAYLOAD", ""))
except Exception:
    print("ok")
    sys.exit(0)

tool = data.get("tool_name", "")
tool_input = data.get("tool_input") or {}
ENV_NAME = re.compile(r"^\.env(\..+)?$")

def is_secret_env(name):
    return bool(ENV_NAME.match(name)) and not name.endswith(".example")

if tool in ("Read", "Write", "Edit", "MultiEdit", "NotebookEdit"):
    path = tool_input.get("file_path") or tool_input.get("notebook_path") or ""
    if is_secret_env(os.path.basename(path)):
        print("file")
        sys.exit(0)
elif tool == "Bash":
    command = tool_input.get("command") or ""
    for token in re.split(r"[\s\"\x27=<>|&;()]+", command):
        if token and is_secret_env(os.path.basename(token)):
            print("bash")
            sys.exit(0)

print("ok")
')

if [ "$verdict" != "ok" ]; then
  cat >&2 <<'MSG'
BLOCKED: .env files are developer-managed and may contain secrets (no reading, no writing).

If you need to:
  - Know an env var       -> read .env.example and lib/env.ts (Zod schema)
  - Add a new env var     -> escalate with: name + purpose + scope (dev/preview/prod) + whether it is a secret
  - Document an env var   -> update .env.example (allowed) and the README

Never write secrets or production credentials into the repo.
MSG
  exit 2
fi

exit 0

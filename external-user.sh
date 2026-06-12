#!/usr/bin/env bash
# Emits {"user": "<name>"} for the external data source in main.tf.
# README previously referenced external-whoami.sh while main.tf called
# external-user.sh — this file is the canonical one; keep both names in sync
# or symlink one to the other.
set -euo pipefail

# whoami can be absent in minimal containers; fall back through id/USER.
user="$(whoami 2>/dev/null || id -un 2>/dev/null || echo "${USER:-unknown}")"

# The external provider requires a flat JSON object of strings on stdout.
printf '{"user": "%s"}\n' "${user}"

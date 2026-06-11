#!/usr/bin/env bash
# Linux setup placeholder - package installation varies by distribution.

set -euo pipefail

if [ "$(uname -s)" != "Linux" ]; then
  echo "⊘ skip: not Linux"
  exit 0
fi

echo "⊘ skip: Linux package installer is not configured yet"

#!/usr/bin/env bash
# Snapshot current system packages interactively

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SNAPSHOT_DIR="$DOTFILES_DIR/snapshots"
CATEGORIES_CONF="$SNAPSHOT_DIR/pacman-categories.conf"
ALL=false

usage() {
  cat <<EOF
Usage: $0 [-a|--all] [-h]
  -a, --all  Export all packages without interaction
  -h         Help
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--all) ALL=true; shift ;;
    -h|--help) usage ;;
    *) shift ;;
  esac
done

mkdir -p "$SNAPSHOT_DIR"

section() { echo; echo "━━━ $1 ━━━"; }

CLIP_CMD=""
detect_clipboard() {
  if command -v xclip >/dev/null 2>&1; then
    CLIP_CMD="xclip -selection clipboard"
  elif command -v xsel >/dev/null 2>&1; then
    CLIP_CMD="xsel --clipboard --input"
  elif command -v wl-copy >/dev/null 2>&1; then
    CLIP_CMD="wl-copy"
  elif command -v pbcopy >/dev/null 2>&1; then
    CLIP_CMD="pbcopy"
  fi
}

copy_to_clipboard() {
  local items="$1" label="$2"
  if [ -z "$CLIP_CMD" ] || [ -z "$items" ]; then return; fi
  echo "$items" | $CLIP_CMD
  local count
  count="$(echo "$items" | wc -l)"
  echo "✓ copied $count $label to clipboard (paste to AI to ask)"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "⊘ skip: $1 not found"
    return 1
  fi
  return 0
}

fzf_select() {
  local prompt="$1"
  shift
  fzf --multi \
    --reverse \
    --prompt="$prompt> " \
    --header="Tab=toggle  Ctrl-A=select-all  Ctrl-D=deselect-all  Enter=confirm" \
    --bind="ctrl-a:select-all,ctrl-d:deselect-all" \
    "$@"
}

match_category() {
  local pkg="$1"
  if [ ! -f "$CATEGORIES_CONF" ]; then echo "other"; return; fi
  local in_hardware=false
  while IFS= read -r line; do
    [[ "$line" == "# hardware"* ]] && { in_hardware=true; continue; }
    [[ "$line" == "# common"* ]] && { in_hardware=false; continue; }
    [[ -z "$line" || "$line" == \#* ]] && continue
    local cat="${line%%:*}"
    local patterns="${line#*:}"
    IFS=',' read -ra pats <<< "$patterns"
    for pat in "${pats[@]}"; do
      if [[ "$pkg" == "$pat" ]]; then
        if [ "$in_hardware" = true ]; then
          echo "hw/$cat"
        else
          echo "$cat"
        fi
        return
      fi
    done
  done < "$CATEGORIES_CONF"
  echo "other"
}

snapshot_pacman() {
  section "pacman packages (Arch)"
  if ! require_cmd pacman; then return; fi
  if [ ! -f /etc/arch-release ]; then return; fi

  local toplevel
  toplevel="$(comm -23 <(pacman -Qqe | sort) <(pacman -Qqd | sort -u))"
  local total_count
  total_count="$(echo "$toplevel" | wc -l)"

  local map_file
  map_file="$(mktemp)"

  local display_lines=""
  local grouped_set=""

  local all_groups
  all_groups="$(pacman -Qg 2>/dev/null | awk '{print $1}' | sort -u)"

  local claimed=""
  for grp in $all_groups; do
    local members
    members="$(comm -12 <(pacman -Qg "$grp" 2>/dev/null | awk '{print $2}' | sort) <(echo "$toplevel"))"
    if [ -n "$claimed" ]; then
      members="$(comm -23 <(echo "$members") <(echo "$claimed"))"
    fi
    if [ -n "$members" ]; then
      local mcount
      mcount="$(echo "$members" | wc -l)"
      local key="@group:$grp"
      local member_flat
      member_flat="$(echo "$members" | tr '\n' ' ' | sed 's/ *$//')"
      printf '%s\t%s\n' "$key" "$member_flat" >> "$map_file"
      display_lines+="$(printf '  @%s [%d packages]' "$grp" "$mcount")"$'\n'
      grouped_set+="$members"$'\n'
      if [ -z "$claimed" ]; then
        claimed="$members"
      else
        claimed="$(printf '%s\n%s\n' "$claimed" "$members" | sed '/^$/d' | sort -u)"
      fi
    fi
  done
  grouped_set="$(echo "$grouped_set" | sed '/^$/d' | sort -u)"

  local remaining
  remaining="$(comm -23 <(echo "$toplevel") <(echo "$grouped_set"))"

  while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    local cat
    cat="$(match_category "$pkg")"
    printf '[%s] %s\t%s\n' "$cat" "$pkg" "$pkg" >> "$map_file"
    display_lines+="$(printf '  [%s] %s' "$cat" "$pkg")"$'\n'
  done <<< "$remaining"

  display_lines="$(echo "$display_lines" | sed '/^$/d' | sort)"
  local entry_count
  entry_count="$(echo "$display_lines" | wc -l)"

  local group_count
  group_count="$(echo "$display_lines" | grep -c '@' || true)"
  local grouped_count
  grouped_count="$(echo "$grouped_set" | sed '/^$/d' | wc -l)"
  echo "found $entry_count entries ($total_count top-level packages, $grouped_count consolidated into $group_count groups)"

  copy_to_clipboard "$toplevel" "packages"

  local selected_entries
  if [ "$ALL" = true ]; then
    selected_entries="$display_lines"
  else
    selected_entries="$(echo "$display_lines" | fzf_select "pacman [$entry_count entries / $total_count pkgs]" \
      --preview='entry=$(echo {} | sed "s/^  //"); if [[ "$entry" == @* ]]; then grp=$(echo "$entry" | sed "s/^@\([^ ]*\).*/\1/"); pacman -Qg "$grp" 2>/dev/null | awk "{print \$2}" | xargs pacman -Qi 2>/dev/null; else line=$(grep -m1 -F "${entry}'"$(printf '\t')"'" "'"$map_file"'"); pkg=$(echo "$line" | cut -f2); pacman -Qi "$pkg" 2>/dev/null; fi' \
      --preview-window=right:50%:wrap)" || true
  fi

  if [ -z "$selected_entries" ]; then rm -f "$map_file"; return; fi

  local save_data=""
  while IFS= read -r line; do
    line="$(echo "$line" | sed 's/^  //')"
    if [[ "$line" == @* ]]; then
      local grp_name
      grp_name="$(echo "$line" | sed 's/^@\([^ ]*\).*/\1/')"
      save_data+="@group:$grp_name"$'\n'
    else
      local key pkg
      key="$(grep -m1 -F "$line"$'\t' "$map_file" | cut -f1)"
      pkg="$(grep -m1 -F "$line"$'\t' "$map_file" | cut -f2)"
      if [[ "$key" == \[hw/* ]]; then
        save_data+="@hw:$pkg"$'\n'
      else
        save_data+="$pkg"$'\n'
      fi
    fi
  done <<< "$selected_entries"

  save_data="$(echo "$save_data" | sed '/^$/d' | sort -u)"
  rm -f "$map_file"

  if [ -n "$save_data" ]; then
    echo "$save_data" > "$SNAPSHOT_DIR/pacman.txt"
    local saved_count
    saved_count="$(echo "$save_data" | wc -l)"
    echo "✓ saved $saved_count entries → snapshots/pacman.txt"
  fi
}

snapshot_aur() {
  section "AUR packages"
  if ! require_cmd pacman; then return; fi
  if [ ! -f /etc/arch-release ]; then return; fi

  local pkgs
  pkgs="$(comm -23 <(pacman -Qqm | sort) <(pacman -Qqmd 2>/dev/null | sort))"

  if [ -z "$pkgs" ]; then
    echo "⊘ no AUR packages found"
    return
  fi

  local count
  count="$(echo "$pkgs" | wc -l)"
  echo "found $count AUR package(s)"
  copy_to_clipboard "$pkgs" "AUR packages"

  local selected
  if [ "$ALL" = true ]; then
    selected="$pkgs"
  else
    local list_with_desc
    list_with_desc="$(while IFS= read -r pkg; do
      desc="$(yay -Ai "$pkg" 2>/dev/null | awk -F': ' '/^Description/{print $2; exit}' || echo "")"
      printf '%s  %s\n' "$pkg" "$desc"
    done <<< "$pkgs")"

    selected="$(echo "$list_with_desc" | fzf_select "AUR [$count]" \
      --preview='echo {} | awk "{print \$1}" | xargs yay -Ai 2>/dev/null' \
      --preview-window=right:50%:wrap)" || true
    selected="$(echo "$selected" | awk '{print $1}' | sed '/^$/d')"
  fi

  if [ -n "$selected" ]; then
    echo "$selected" > "$SNAPSHOT_DIR/aur.txt"
    echo "✓ saved $(echo "$selected" | wc -l) package(s) → snapshots/aur.txt"
  fi
}

snapshot_flatpak() {
  section "Flatpak apps"
  if ! require_cmd flatpak; then return; fi

  local apps
  apps="$(flatpak list --columns=application 2>/dev/null | grep -v '^$' | sort || true)"

  if [ -z "$apps" ]; then
    echo "⊘ no flatpak apps found"
    return
  fi

  copy_to_clipboard "$apps" "apps"

  local selected
  if [ "$ALL" = true ]; then
    selected="$apps"
  else
    flatpak list --columns=application,name 2>/dev/null | sed 's/^/  /'
    echo
    selected="$(flatpak list --columns=application,name 2>/dev/null | fzf_select "flatpak")" || true
    selected="$(echo "$selected" | awk '{print $1}')"
  fi

  if [ -n "$selected" ]; then
    echo "$selected" > "$SNAPSHOT_DIR/flatpak.txt"
    echo "✓ saved $(echo "$selected" | wc -l) app(s) → snapshots/flatpak.txt"
  fi
}

snapshot_npm_global() {
  section "npm global packages"
  if ! require_cmd npm; then return; fi

  local prefix
  prefix="$(npm config get prefix 2>/dev/null)"

  local toplevel
  toplevel="$(npm list -g --depth=0 --parseable 2>/dev/null \
    | tail -n+2 | xargs -I{} basename {} | sort -u)"

  local all_deps
  all_deps="$(for pkg_dir in "$prefix"/lib/node_modules/*/; do
    [ -f "$pkg_dir/package.json" ] && python3 -c "
import json,sys
d=json.load(open(sys.argv[1]+'package.json'))
[print(k) for k in d.get('dependencies',{})]
" "$pkg_dir" 2>/dev/null
  done | sort -u)"

  local pkgs
  pkgs="$(comm -23 <(echo "$toplevel") <(echo "$all_deps") | grep -v '^npm$')"

  if [ -z "$pkgs" ]; then
    echo "⊘ no global npm packages found"
    return
  fi

  copy_to_clipboard "$pkgs" "packages"

  local selected
  if [ "$ALL" = true ]; then
    selected="$pkgs"
  else
    echo "$pkgs" | sed 's/^/  /'
    echo
    selected="$(echo "$pkgs" | fzf_select "npm globals" --preview="npm info {} description 2>/dev/null")" || true
  fi

  if [ -n "$selected" ]; then
    echo "$selected" > "$SNAPSHOT_DIR/npm-global.txt"
    echo "✓ saved $(echo "$selected" | wc -l) package(s) → snapshots/npm-global.txt"
  fi
}

snapshot_dotnet_tools() {
  section ".NET global tools"
  if ! require_cmd dotnet; then return; fi

  export PATH="$HOME/.dotnet/tools:$PATH"

  local tools
  tools="$(dotnet tool list -g 2>/dev/null | tail -n+3 | awk '{print $1}')"

  if [ -z "$tools" ]; then
    echo "⊘ no .NET global tools found"
    return
  fi

  copy_to_clipboard "$tools" "tools"

  local selected
  if [ "$ALL" = true ]; then
    selected="$tools"
  else
    echo "$tools" | sed 's/^/  /'
    echo
    selected="$(echo "$tools" | fzf_select "dotnet tools" --preview="dotnet tool search {} --take 1 2>/dev/null")" || true
  fi

  if [ -n "$selected" ]; then
    echo "$selected" > "$SNAPSHOT_DIR/dotnet-tools.txt"
    echo "✓ saved $(echo "$selected" | wc -l) tool(s) → snapshots/dotnet-tools.txt"
  fi
}

snapshot_brew_formulae() {
  section "Homebrew formulae"
  if ! require_cmd brew; then return; fi

  local pkgs
  pkgs="$(brew leaves 2>/dev/null | sort)"

  if [ -z "$pkgs" ]; then
    echo "⊘ no brew formulae found"
    return
  fi

  local count
  count="$(echo "$pkgs" | wc -l)"
  echo "found $count top-level formula(e)"
  copy_to_clipboard "$pkgs" "formulae"

  local selected
  if [ "$ALL" = true ]; then
    selected="$pkgs"
  else
    local list_with_desc
    list_with_desc="$(while IFS= read -r pkg; do
      desc="$(brew info --json=v2 "$pkg" 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['formulae'][0]['desc'])" 2>/dev/null || echo "")"
      printf '%s  %s\n' "$pkg" "$desc"
    done <<< "$pkgs")"

    selected="$(echo "$list_with_desc" | fzf_select "brew formulae [$count]" \
      --preview='echo {} | awk "{print \$1}" | xargs brew info 2>/dev/null' \
      --preview-window=right:50%:wrap)" || true
    selected="$(echo "$selected" | awk '{print $1}' | sed '/^$/d')"
  fi

  if [ -n "$selected" ]; then
    echo "$selected" > "$SNAPSHOT_DIR/brew-formulae.txt"
    echo "✓ saved $(echo "$selected" | wc -l) formula(e) → snapshots/brew-formulae.txt"
  fi
}

snapshot_brew_casks() {
  section "Homebrew casks"
  if ! require_cmd brew; then return; fi

  local casks
  casks="$(brew list --cask 2>/dev/null | sort)"

  if [ -z "$casks" ]; then
    echo "⊘ no brew casks found"
    return
  fi

  local count
  count="$(echo "$casks" | wc -l)"
  echo "found $count cask(s)"
  copy_to_clipboard "$casks" "casks"

  local selected
  if [ "$ALL" = true ]; then
    selected="$casks"
  else
    selected="$(echo "$casks" | fzf_select "brew casks [$count]" \
      --preview='echo {} | xargs brew info --cask 2>/dev/null' \
      --preview-window=right:50%:wrap)" || true
  fi

  if [ -n "$selected" ]; then
    echo "$selected" > "$SNAPSHOT_DIR/brew-casks.txt"
    echo "✓ saved $(echo "$selected" | wc -l) cask(s) → snapshots/brew-casks.txt"
  fi
}

echo "Snapshot dir: $SNAPSHOT_DIR"
echo "Mode: $([ "$ALL" = true ] && echo "all (non-interactive)" || echo "interactive")"
detect_clipboard

case "$(uname -s)" in
  Linux)
    snapshot_pacman
    snapshot_aur
    snapshot_flatpak
    ;;
  Darwin)
    snapshot_brew_formulae
    snapshot_brew_casks
    ;;
  *)
    echo "✗ unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

snapshot_npm_global
snapshot_dotnet_tools

echo
echo "━━━ Done ━━━"
echo "Snapshot files:"
ls -1 "$SNAPSHOT_DIR"/*.txt 2>/dev/null | sed 's|^|  |' || echo "  (none)"

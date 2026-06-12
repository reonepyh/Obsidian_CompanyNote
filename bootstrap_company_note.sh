#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  ./bootstrap_company_note.sh "CompanyName" [install_root]

Environment:
  COMPANY_NOTE_VAULT_REPO     Vault template repo URL or local path
  COMPANY_NOTE_SETTINGS_REPO  Obsidian settings repo URL or local path
  COMPANY_NOTE_VAULT_DIR      Target vault directory name

Defaults:
  install_root                Parent directory of this script
  COMPANY_NOTE_VAULT_DIR      <CompanyName>Note
USAGE
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
default_install_root="$(dirname -- "$script_dir")"

company_name="${1:-}"
install_root="${2:-$default_install_root}"

if [[ "${company_name}" == "-h" || "${company_name}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ -z "$company_name" ]]; then
  read -r -p "Company name: " company_name
fi

[[ -n "$company_name" ]] || die "company name is required."
[[ "$company_name" != *"/"* ]] || die "company name cannot contain '/'."
[[ "$company_name" != "." && "$company_name" != ".." ]] || die "invalid company name."

vault_repo="${COMPANY_NOTE_VAULT_REPO:-git@gitReoneCompanyNote:reonepyh/Obsidian_CompanyNote.git}"
settings_repo="${COMPANY_NOTE_SETTINGS_REPO:-git@gitReonepyh:reonepyh/CompanyNoteSet.git}"
vault_dir_name="${COMPANY_NOTE_VAULT_DIR:-${company_name}Note}"

asset_dir_name="${company_name}Doc_Asset"
settings_dir_name=".CompanyNoteSet"

vault_dir="${install_root}/${vault_dir_name}"
note_asset_root="${install_root}/NoteAsset"
asset_dir="${note_asset_root}/${asset_dir_name}"
settings_dir="${asset_dir}/${settings_dir_name}"

[[ ! -e "$vault_dir" ]] || die "target vault already exists: $vault_dir"
[[ ! -e "$asset_dir" ]] || die "target asset directory already exists: $asset_dir"

mkdir -p "$install_root" "$note_asset_root"

printf 'Cloning vault template...\n'
git clone "$vault_repo" "$vault_dir"

printf 'Creating note asset structure...\n'
mkdir -p \
  "$asset_dir/00.Tasks" \
  "$asset_dir/01.Project" \
  "$asset_dir/02.Area" \
  "$asset_dir/03.Resources" \
  "$asset_dir/04.Archive/eo" \
  "$asset_dir/04.Archive/fo" \
  "$asset_dir/04.Archive/mo" \
  "$asset_dir/04.Archive/to"

touch \
  "$asset_dir/00.Tasks/.gitkeep" \
  "$asset_dir/01.Project/.gitkeep" \
  "$asset_dir/02.Area/.gitkeep" \
  "$asset_dir/03.Resources/.gitkeep" \
  "$asset_dir/04.Archive/eo/.gitkeep" \
  "$asset_dir/04.Archive/fo/.gitkeep" \
  "$asset_dir/04.Archive/mo/.gitkeep" \
  "$asset_dir/04.Archive/to/.gitkeep"

printf 'Cloning Obsidian settings...\n'
git clone "$settings_repo" "$settings_dir"

printf 'Applying company-specific vault names...\n'
if [[ -e "$vault_dir/01.(Company_name)Doc" ]]; then
  mv "$vault_dir/01.(Company_name)Doc" "$vault_dir/01.${company_name}Doc"
fi

rm -f "$vault_dir/.obsidian"
ln -s "../NoteAsset/${asset_dir_name}/${settings_dir_name}" "$vault_dir/.obsidian"

rm -f "$vault_dir/02.(Company_name)Doc_Asset"
ln -s "../NoteAsset/${asset_dir_name}" "$vault_dir/02.${asset_dir_name}"

printf '\nDone.\n'
printf 'Vault: %s\n' "$vault_dir"
printf 'Settings: %s\n' "$settings_dir"
printf 'Asset: %s\n' "$asset_dir"

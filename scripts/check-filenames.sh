#!/usr/bin/env bash
# Rejects file and folder names that Windows/Wine cannot handle (e.g. "Mocks "),
# which break Battle.net updates of the installed addon.
# Usage: check-filenames.sh [--staged | --all]   (default: --all)
set -u
export LC_ALL=C

mode="${1:---all}"

case "$mode" in
    --staged) list=(git diff --cached --name-only --diff-filter=ACMR -z) ;;
    --all) list=(git ls-files -z --cached --others --exclude-standard) ;;
    *)
        echo "Usage: $0 [--staged | --all]" >&2
        exit 2
        ;;
esac

reserved='^(con|prn|aux|nul|com[1-9]|lpt[1-9])(\..*)?$'
invalid='[<>:"|?*\\[:cntrl:]]'
errors=0
declare -A seen

report() {
    printf 'ERROR: %s: "%s"\n' "$1" "$2" >&2
    errors=$((errors + 1))
}

while IFS= read -r -d '' path; do
    [ -n "$path" ] || continue

    lower="${path,,}"
    if [ "$mode" = "--all" ]; then
        if [ -n "${seen[$lower]+x}" ] && [ "${seen[$lower]}" != "$path" ]; then
            report "differs only by letter case from '${seen[$lower]}'" "$path"
        fi
        seen[$lower]="$path"
    fi

    IFS='/' read -r -a parts <<< "$path"
    for part in "${parts[@]}"; do
        [[ "$part" == *" " ]] && report "name ends with a space" "$path"
        [[ "$part" == *"." ]] && report "name ends with a dot" "$path"
        [[ "$part" == " "* ]] && report "name starts with a space" "$path"
        [[ "$part" =~ $invalid ]] && report "name contains an invalid character" "$path"
        [[ "${part,,}" =~ $reserved ]] && report "reserved Windows name" "$path"
    done
done < <("${list[@]}")

if [ "$errors" -gt 0 ]; then
    echo "Found $errors invalid file name problem(s). Rename the files/folders listed above." >&2
    exit 1
fi

echo "File name check passed."

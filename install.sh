#!/bin/sh

REPO="$(cd "$(dirname "$0")" && pwd)"
SKIP=".git .gitignore $(basename "$0") readme.md"

should_skip() {
    for s in $SKIP; do
        [ "$1" = "$s" ] && return 0
    done
    return 1
}

is_git_ignored() {
    # git check-ignore returns 0 if file is ignored, 1 if not
    # We pass the relative path from repo root
    git -C "$REPO" check-ignore -q "$1"
}

find "$REPO" \( -type f -o -type l \) | while read -r src; do
    rel="${src#"$REPO"/}"
    top="${rel%%/*}"

    should_skip "$top" && continue

    if is_git_ignored "$rel"; then
        continue
    fi

    dst="$HOME/$rel"

    # Handle existing destination
    if [ -L "$dst" ]; then
        current="$(readlink "$dst")"
        if [ "$current" = "$src" ]; then
            continue
        fi
        printf 'WARN: %s -> %s (expected %s), skipping\n' "$dst" "$current" "$src"
        continue
    fi

    if [ -e "$dst" ]; then
        printf 'CONFLICT: %s already exists, skipping\n' "$dst"
        continue
    fi

    mkdir -p "$(dirname "$dst")"

    if [ -L "$src" ]; then
        # Recreate the symlink with the same target
        target="$(readlink "$src")"
        ln -s "$target" "$dst"
        printf 'linked %s -> %s (symlink)\n' "$dst" "$target"
    else
        ln -s "$src" "$dst"
        printf 'linked %s -> %s\n' "$dst" "$src"
    fi
done

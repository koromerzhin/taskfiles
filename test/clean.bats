#!/usr/bin/env bats
# Tests de `utils:clean:logs` (hermétiques, dossiers temporaires).
# `touch -t` (POSIX) plutôt que `touch -d` pour rester portable (macOS/BSD).

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  cd "$REPO_ROOT"
  TMP_DIR="$(mktemp -d)"
}

teardown() {
  rm -rf "$TMP_DIR"
}

@test "clean:logs supprime les logs anciens et garde les récents" {
  echo "vieux" > "$TMP_DIR/old.log"
  touch -t 200001010000 "$TMP_DIR/old.log"
  echo "récent" > "$TMP_DIR/recent.log"

  run task utils:clean:logs DAYS=7 LOG_PATTERN='*.log' DIRS="$TMP_DIR"
  [ "$status" -eq 0 ]
  [ ! -f "$TMP_DIR/old.log" ]
  [ -f "$TMP_DIR/recent.log" ]
}

@test "clean:logs ne touche pas aux autres extensions" {
  echo "data" > "$TMP_DIR/keep.txt"
  touch -t 200001010000 "$TMP_DIR/keep.txt"

  run task utils:clean:logs DAYS=7 LOG_PATTERN='*.log' DIRS="$TMP_DIR"
  [ "$status" -eq 0 ]
  [ -f "$TMP_DIR/keep.txt" ]
}

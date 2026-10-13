#!/usr/bin/env bats
# Tests de `utils:backup:create/list/restore` (hermétiques, dossiers temporaires).

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  cd "$REPO_ROOT"
  PROJECT_NAME="$(basename "$REPO_ROOT")"
  TMP_DIR="$(mktemp -d)"
  RESTORE_DIR="$(mktemp -d)"
}

teardown() {
  rm -rf "$TMP_DIR" "$RESTORE_DIR"
}

@test "backup:create produit une archive puis list la trouve" {
  run task utils:backup:create BACKUP_DIR="$TMP_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Sauvegarde créée"* ]]
  [ -n "$(ls "$TMP_DIR"/*.tar.gz 2>/dev/null)" ]

  run task utils:backup:list BACKUP_DIR="$TMP_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"sauvegarde(s) trouvée(s)"* ]]
}

@test "backup:restore restaure avec FORCE=true" {
  run task utils:backup:create BACKUP_DIR="$TMP_DIR"
  [ "$status" -eq 0 ]
  ARCHIVE="$(ls "$TMP_DIR"/*.tar.gz | head -n 1)"
  [ -n "$ARCHIVE" ]

  run task utils:backup:restore BACKUP_FILE="$ARCHIVE" RESTORE_DIR="$RESTORE_DIR" FORCE=true
  [ "$status" -eq 0 ]
  [[ "$output" == *"Restauration terminée"* ]]
  [ -d "$RESTORE_DIR/$PROJECT_NAME" ]
}

@test "backup:restore exige BACKUP_FILE" {
  run task utils:backup:restore BACKUP_FILE="" RESTORE_DIR="$RESTORE_DIR" FORCE=true
  [ "$status" -ne 0 ]
  [[ "$output" == *"BACKUP_FILE est requis"* ]]
}

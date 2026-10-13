#!/usr/bin/env bats
# Tests de `env:validate` (lecture passive du .env, sans source/eval).

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  cd "$REPO_ROOT"
  TMP_DIR="$(mktemp -d)"
}

teardown() {
  rm -rf "$TMP_DIR"
}

@test "env:validate accepte .env.example" {
  run task env:validate ENV_FILE=.env.example
  [ "$status" -eq 0 ]
  [[ "$output" == *"valide"* ]]
}

@test "env:validate échoue sur fichier manquant" {
  run task env:validate ENV_FILE="$TMP_DIR/inexistant.env"
  [ "$status" -ne 0 ]
  [[ "$output" == *"non trouvé"* ]]
}

@test "env:validate refuse un ENVIRONMENT invalide" {
  printf 'PROJECT_NAME=demo\nENVIRONMENT=recette\n' > "$TMP_DIR/bad.env"
  run task env:validate ENV_FILE="$TMP_DIR/bad.env"
  [ "$status" -ne 0 ]
  [[ "$output" == *"invalides"* ]]
}

@test "env:validate refuse une variable obligatoire manquante" {
  printf 'ENVIRONMENT=development\n' > "$TMP_DIR/missing.env"
  run task env:validate ENV_FILE="$TMP_DIR/missing.env"
  [ "$status" -ne 0 ]
  [[ "$output" == *"manquantes"* ]]
}

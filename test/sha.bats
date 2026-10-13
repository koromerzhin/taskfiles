#!/usr/bin/env bats
# Tests autour de la vérification SHA256 des `.phar` (hermétiques, sans réseau).
# - `download:php:checksum` ne lit que des fichiers locaux : testable tel quel.
# - Le garde `sha256sum -c` de `download:php:tools` (mismatch → rm + erreur)
#   est rejoué ici au niveau unitaire sur des fichiers factices.

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  cd "$REPO_ROOT"
  TMP_DIR="$(mktemp -d)"
}

teardown() {
  rm -rf "$TMP_DIR"
}

@test "download:php:checksum affiche les sommes des outils présents" {
  printf 'dummy-phpstan' > "$TMP_DIR/phpstan.phar"
  printf 'dummy-fixer' > "$TMP_DIR/php-cs-fixer.phar"
  expected_phpstan="$(sha256sum "$TMP_DIR/phpstan.phar" | awk '{print $1}')"
  expected_fixer="$(sha256sum "$TMP_DIR/php-cs-fixer.phar" | awk '{print $1}')"

  run task download:php:checksum TOOLS_DIR="$TMP_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"PHPSTAN_SHA256=\"$expected_phpstan\""* ]]
  [[ "$output" == *"PHP_CS_FIXER_SHA256=\"$expected_fixer\""* ]]
  [[ "$output" == *"manquant"* ]]
}

@test "sha256sum -c détecte un fichier altéré (garde anti-mismatch)" {
  printf 'contenu-sain' > "$TMP_DIR/outil.phar"
  recorded="$(sha256sum "$TMP_DIR/outil.phar" | awk '{print $1}')"

  run sh -c "echo '$recorded  $TMP_DIR/outil.phar' | sha256sum -c -"
  [ "$status" -eq 0 ]

  printf 'contenu-altéré' > "$TMP_DIR/outil.phar"
  run sh -c "echo '$recorded  $TMP_DIR/outil.phar' | sha256sum -c -"
  [ "$status" -ne 0 ]
}

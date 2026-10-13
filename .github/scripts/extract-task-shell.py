#!/usr/bin/env python3
"""Extrait les blocs shell (`cmds:`) des Taskfiles pour shellcheck.

Les templates Task `{{...}}` (et l'idiome docker `"{{`...`}}"`) sont masqués
par des tokens neutres : sans cela, shellcheck noie le résultat sous des
faux positifs (SC1083, ...). Les codes SC2157/SC2050/SC2193 restent exclus
côté shellcheck : ils raisonnent sur des "constantes" qui sont en réalité
des valeurs rendues à l'exécution (ex. `[ "TASKVAR" = "true" ]`).

Usage:
    extract-task-shell.py --root <repo> --out <dir>
"""

import argparse
import glob
import os
import re
import sys

try:
    import yaml
except ImportError:
    print("PyYAML requis (pip install pyyaml ou apt install python3-yaml)",
          file=sys.stderr)
    sys.exit(2)


def mask(text: str) -> str:
    # Idiome docker imbriqué "{{`...`}}" d'abord (sinon le regex simple
    # laisse des backticks orphelins qui cassent le parse shellcheck).
    text = re.sub(r"\{\{`.*?`\}\}", "DOCKERFMT", text)
    # Templates Task classiques.
    return re.sub(r"\{\{.*?\}\}", "TASKVAR", text)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    os.makedirs(args.out, exist_ok=True)
    count = 0
    for path in sorted(glob.glob("**/Taskfile.yml", root_dir=args.root,
                                 recursive=True)):
        full = os.path.join(args.root, path)
        with open(full) as fh:
            data = yaml.safe_load(fh) or {}
        for task_name, task in (data.get("tasks") or {}).items():
            for i, cmd in enumerate(task.get("cmds") or []):
                if not isinstance(cmd, str) or not cmd.strip():
                    continue  # appel `task:` — pas du shell
                masked = mask(cmd)
                if not masked.endswith("\n"):
                    masked += "\n"
                safe = (path.replace("/", "_").replace(".yml", "")
                        + f"__{task_name}__{i}.sh")
                with open(os.path.join(args.out, safe), "w") as fh:
                    fh.write(masked)
                count += 1
    print(f"{count} blocs shell extraits")
    return 0


if __name__ == "__main__":
    sys.exit(main())

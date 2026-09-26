#!/usr/bin/env python3
"""Check the book against `CSwFP.yaml` and against the rule that the book
never names its source:

  - every `:::exercise` under `CSwL/` is listed once in `CSwFP.yaml`, either
    as the CSwL exercise of a CSwFP exercise or under `original`;
  - every exercise named in `CSwFP.yaml` exists under `CSwL/`;
  - every exercise of CSwFP/1-6 is listed, in order;
  - every chapter named in `sections` is a file under `CSwL/`;
  - no prose outside a `:::dev` note cites CSwFP, or a page, section or
    exercise number (see `STYLE-WRITING.md`).

Prints each problem and exits with status 1 if there is any. `TODO` reasons
are listed but are not problems.

Needs PyYAML (`pip install pyyaml`).

Usage: scripts/check-cswfp.py
"""

import re
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
BOOK = ROOT / "CSwL"
DATA = yaml.safe_load((ROOT / "CSwFP.yaml").read_text())

# How many exercises each CSwFP chapter has.
COUNTS = {"CSwFP/1": 3, "CSwFP/2": 17, "CSwFP/3": 19,
          "CSwFP/4": 24, "CSwFP/5": 32, "CSwFP/6": 7}

EXERCISE = re.compile(r'^:+exercise\b.*\(name := "([^"]+)"\)')
CITATION = re.compile(r"CSwFP|página \d+|\(p\. \d+|§\s*\d|exemplo \(\d+\.\d+\)"
                      r"|Exercício \d+\.\d+|Seção \d+\.\d+")
DEV = re.compile(r"^(:+)dev\b")


def is_exercise_name(value):
    """A value with no space in it is the name of a CSwL exercise; anything
    else is the reason the exercise was not ported."""
    return (isinstance(value, str) and not re.search(r"\s", value)
            and not value.startswith("TODO"))


problems = []
todos = []

sources = sorted(BOOK.rglob("*.lean"))

# Exercises in the book, name -> file.
book = {}
for path in sources:
    for line in path.read_text().splitlines():
        if m := EXERCISE.match(line):
            book[m[1]] = path.relative_to(BOOK).as_posix()

# Exercises named in `CSwFP.yaml`, name -> times listed.
listed = {}
for chapter, exercises in DATA["exercises"].items():
    numbers = [int(re.match(r"\d+\.(\d+)", key)[1]) for key in exercises]
    if numbers != list(range(1, COUNTS[chapter] + 1)):
        problems.append(f"{chapter}: exercises are not numbered 1 to {COUNTS[chapter]}")
    for key, value in exercises.items():
        if is_exercise_name(value):
            listed[value] = listed.get(value, 0) + 1
        elif str(value).startswith("TODO"):
            todos.append(f"{key}: {value}")
for names in DATA["original"].values():
    for name in names:
        listed[name] = listed.get(name, 0) + 1

for name, path in book.items():
    if name not in listed:
        problems.append(f"not in CSwFP.yaml:      {name} ({path})")
    elif listed[name] > 1:
        problems.append(f"listed more than once:  {name}")

named = set(listed)
for exercise, needed in DATA["depends"].items():
    named |= {exercise, needed}
for name in sorted(named - set(book)):
    problems.append(f"no such exercise:       {name}")

# Chapters named in `sections`.
chapters = {path.relative_to(BOOK).with_suffix("").as_posix() for path in sources}
for sections in DATA["sections"].values():
    if not isinstance(sections, dict):
        continue
    for section, value in sections.items():
        target = value["to"] if isinstance(value, dict) else value
        chapter = re.match(r"[^,\s]+", target)[0]
        if chapter not in {"omitted", "absorbed", "dropped"} | chapters:
            problems.append(f"no such chapter:        {chapter} ({section})")

# Prose that cites the source.
for path in sources:
    fence = None
    for number, line in enumerate(path.read_text().splitlines(), 1):
        if m := DEV.match(line):
            fence = m[1]
        elif fence and line.strip() == fence:
            fence = None
        elif not fence and CITATION.search(line):
            problems.append(f"cites the source:       "
                            f"{path.relative_to(ROOT).as_posix()}:{number}")

print("\n".join(problems))
if todos:
    if problems:
        print()
    print(f"{len(todos)} exercises still to decide:")
    for todo in todos:
        print(f"  {todo}")
sys.exit(1 if problems else 0)

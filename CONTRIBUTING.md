# Contributing to CSwL

This file covers workflow and mechanics. For conventions, read `STYLE-CODE.md`
(Lean and Verso) and `STYLE-WRITING.md` (prose and Portuguese) — both are
normative, and both should be read before you edit anything that reaches the
book.

Everything about the project is in English: this file, identifiers, code
comments, commit messages, issues. Only the book's prose is in Portuguese.

## Who decides what

The book's content and its structure — what a chapter says, what order the
material comes in, which exercises exist, how chapters are divided — are the
author's. Contributions are welcome on everything else, and are most valuable
where a task is objective:

- reporting anything that does not build, or builds with an unexpected warning;
- reporting prose that is wrong, unclear, or badly translated;
- working the exercises and reporting those that are unsolvable, ambiguous, or
  mis-rated;
- checking that a chapter uses no Lean feature the book has not yet presented
  (`STYLE-CODE.md` has the ledger);
- fixes to typos, markup slips, and broken references.

A change that reorganizes material, adds or removes an exercise, or introduces
a Lean feature earlier than the ledger records is a proposal, not a fix: open
an issue and let the author decide.

## Getting set up

Install Lean via [elan](https://lean-lang.org/install), then clone the
repository and fetch the prebuilt Mathlib — without this, `lake build`
compiles all of Mathlib from scratch:

```sh
lake exe cache get
lake build
```

Use VS Code with the Lean 4 extension. Opening any file under `CSwL/` will
prompt to install the toolchain the book pins.

To build and read the book locally:

```sh
make serve   # http://127.0.0.1:8000/
```

`make all` generates all four variants under `_out/`. See `STYLE-CODE.md` for
what each variant is.

## Issues

Pending work is tracked in [GitHub
issues](https://github.com/cslib-community/CSwL/issues). Anything you find that
you are not fixing yourself belongs there.

For a comment that is local to one passage and only makes sense with that
section in view, use a `:::dev` note in the Lean file itself rather than an
issue. Those render as editorial notes and never reach the student.

## Branches and pull requests

- `main` must always build.
- Do not commit to `main`; work on a branch and open a pull request.
- Keep a pull request to one coherent piece of work. Smaller and sooner beats
  bigger and later.
- Before opening it, check that what you touched still builds — `lake build
  CSwL.Sets` for a single chapter, `make all` if you changed the
  infrastructure or anything that affects the generated variants.
- Delete the branch once it is merged.

Commit messages follow [Conventional
Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`,
`refactor:`, with an optional scope — `docs(readme): …`, `fix(logic): …`.

## Editing the right file

The book's sources are the Lean files under `CSwL/`. Everything under `_out/`
is generated and is overwritten by the next `make` — never edit there.

That includes the generated projects' `README.md`, which comes from
`readmeTemplate` in `CSwLMeta/Save/Project.lean`.

## AI usage

AI may be used in this project, under conditions that differ from the ones
some related projects adopt. The rules:

- **AI never writes prose on its own initiative.** It produces text only when
  explicitly asked, and what it produces is a draft for a human to revise.
- **When migrating material, AI translates.** English to Portuguese, as
  literally as the target language allows. It does not rewrite, expand,
  restructure, or invent. Deviating from the source is a human decision.
- **AI-generated commentary is marked as such**, and belongs in `:::dev`
  blocks, which never reach the student.
- **Infrastructure is different.** Code under `CSwLMeta/` and the scripts
  around the build are not book content, and AI may write them — but a file
  that is mostly AI-written says so at the top, because it will typically be
  less carefully considered than hand-written code.
- **Commit messages** that describe AI-assisted work carry a disclosure
  paragraph in English, added only after a human approves it. Never
  `Co-Authored-By: Claude`.

`CLAUDE.md` holds the instructions Claude Code reads at the start of a
session; it points at this file and the two style guides.

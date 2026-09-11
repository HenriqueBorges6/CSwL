# CSwL Code Style Guide

This file records the conventions for the Lean code and the Verso markup that
make up the book. `STYLE-WRITING.md` covers prose, pedagogy, and translation;
`CONTRIBUTING.md` covers workflow. In case of conflict with `CLAUDE.md`, the
style guides win on style and `CLAUDE.md` wins on project scope.

The book's prose is in Portuguese. Everything else — this file, identifiers,
code comments, commit messages — is in English.

## The hard constraint: nothing is used before it is presented

`DEVIATIONS.md` states the rule that governs the whole book:

> **Nothing is used before it is presented.**

In a book whose chapters are largely programs rather than proofs, this covers
**every Lean feature**, not only tactics: commands, declaration forms, syntax,
notation, standard-library types, and typeclasses alike. A reader meeting
`instance` for the first time inside a chapter on morphology has been given a
feature the book never introduced, exactly as much as one meeting `by_contra`
would have been.

The table below is the ledger that makes the rule checkable.

### How to read the table

It records the chapter where each feature is **first used in the sources**, in
book order (`Book.lean`). It is derived from the code inside ```` ```lean ````
blocks and must be kept in sync as chapters are rewritten.

First use is evidence, not compliance. The rule is about first *presentation* —
the prose that introduces the feature — and a row whose feature is used but
never presented is a defect, not an entry. Rows known to be in that state are
marked, and the open ones are listed under "Known gaps" below.

**A feature can be presented outside a `lean` block**, so the table's first-use
column does not by itself settle whether the rule holds. `IntroL.lean` presents
fourteen tactics in a plain code fence — one line each, `rfl` through `funext` —
and a scan that reads only ```` ```lean ```` blocks misses it. Check the prose
before recording a gap.

A feature marked **(solution only)** first appears inside a `solution!(…)`
block. Those rows are a distinct case: the feature is invisible in the
`student` and `terse` variants and visible in `solutions` and `grading`, so a
reader working the exercise meets it only in the answer. Introducing a feature
this way is usually a mistake; see "Known gaps."

### Features by chapter of first use

| Chapter | Commands and declarations | Types and syntax | Tactics |
| --- | --- | --- | --- |
| `IntroCS` | `namespace`, `def` (by pattern matching), `inductive`, `deriving Repr`, `example`, `#eval` | `Nat`, function type `→`, dot-notation constructors (`.num`) | `rfl`, `induction … with`, `rw`, `rewrite`, `unfold`, `repeat` |
| `IntroL` | `#check`, `#print`, `theorem`, `structure`, `instance`, `section`, `variable` | `Type`, `Prop`, `Bool`, `List`, `Option`, `Char`, `String`, `fun`/`λ`, `match`, `if … then … else`, `⟨…⟩`, implicit `{}`, instance-implicit `[]`, `∘`, `BEq`, `∀`, `∃`, `∧`, `∨`, `↔`, `≠` | `intro`, `exact`, `apply`, `cases … with`, `constructor`, `obtain`, `show`, `funext`, `omega`, `decide` (solution only) |
| `Morphology` | `abbrev`, `open`, `deriving BEq` | `×` | `native_decide` (solution only) |
| `Games` | — | `DecidableEq`, `Vector`, subtypes (`{ x : T // p x }`), `¬`, `∈` | `simp` (solution only) |
| `Logic` | `mutual`, `private` | `\|>` | `have`, `use`, `left`, `right`, `rcases`, `by_cases`, `by_contra` |
| `Sets` | — | `Set`, `Rel`, `Finset`, `Fintype`, `Setoid`, `⊆`, `∪`, `∩` | `assumption`, `trivial`, `symm`, `simp_all` |
| `InfEngine` | — | `do`-notation | — |
| `English` | *(none new)* | *(none new)* | *(none new)* |

`English` introduces no new feature: it is where `abbrev` and `ToString`
instances become the dominant idiom, but both arrive earlier.

`Games` introduces `Vector` and subtypes in `Games/Mastermind.lean`, and the
subtype gets a paragraph of prose before its first use — the rule working as
intended.

The table records features, not every piece of notation. Type ascription,
list literals, projection dots, and the like are not tracked: they arrive with
the constructs that use them and tracking them would produce a ledger nobody
maintains.

### Known gaps

Open questions about the table, recorded so they are not lost. Each needs an
author decision, not a mechanical fix.

- **`native_decide`** (`Morphology/SwedishPlural.lean:69`, `:72`) is used
  inside solutions and is not in `IntroL`'s tactic table. It closes a goal by
  compiling and running it, trusting the compiler rather than the kernel — a
  materially different promise from `decide`. Its use is justified where it
  appears, and a comment at `:63-66` says why, but that comment is inside the
  solution and in Portuguese, so the explanation reaches neither the student
  nor the English code-comment rule.
- **`trivial`** — one term-level use in `Sets.lean:507`, not presented
  anywhere. Give it a line or replace it when that chapter is revised.
- **`Sets.lean` uses `Setoid`, `Fintype` and `Finset` with no presentation.**
  A short paragraph plus a citation for each would settle it, under the
  loosening `DEVIATIONS.md` describes.

`IntroCS` is the constraint's one accepted exception: it uses Lean that
`IntroL` only presents later, deliberately, and the chapter says so where its
first code block appears — the code is there to show where the book is going,
nothing in it is presented, and reading it is optional. `DEVIATIONS.md`
records the decision.

## Verso markup

The book is written in [Verso](https://verso.lean-lang.org), in the `Manual`
genre. The directives below are defined in `CSwLMeta/` and are the vocabulary
available to a chapter.

### Chapter structure

A chapter file opens with its imports, the `#doc` declaration, and a metadata
block:

```
#doc (Manual) "Title in Portuguese" =>
%%%
tag := "ChapterTag"
htmlSplit := .never
file := "ChapterTag"
%%%
```

Mnemonic names, never numbers — for files, tags, and exercise names alike.
Material moves between chapters, and a number would be wrong the moment it
did.

A short chapter is a single file (`CSwL/Sets.lean`). A chapter whose sections
are long enough to deserve their own files is a "glue" file (`CSwL/Games.lean`)
that only gathers them via `{include 1 …}` from a same-named directory. Each
content file has its own `namespace`: the book redefines the same names in
different chapters, deliberately.

### Exercises and solutions

`:::exercise (rating := N) (name := "mnemonic")` — an exercise. `rating` is
difficulty, 1 to 5. `name` is the identifier used by `PROVENANCE.md` and by
the grading variant, and follows the mnemonic rule.

Inside an exercise, the answer is wrapped so the build variants can strip it:

- `solution!(…)` — an inline solution, for a term or a `by` block.
- `solution!` on its own line, followed by an indented block — a multi-line
  solution.
- `:::solution` — a prose solution, for exercises answered in words.

The `student` and `terse` variants replace these with `sorry`; `solutions` and
`grading` keep them. This is why a feature first used inside `solution!` is
invisible to the student.

### Grading

`:::gradeTheorem <points> <name> …` marks theorems the autograder scores.
Points may be a decimal in double quotes (`"0.25"`); an integer needs no
quotes. The directive is defined in `CSwLMeta/Grade.lean` and emitted as an
`[autogradedProof]` attribute by `CSwLMeta/Save/Extract.lean`, into the
`grading` variant only.

The theorems must be `theorem`s and not `example`s, since the attribute needs
a name to refer to.

### Build variants

Four variants are generated by `make all`, from the same sources:

| Variant | Solutions | Audience |
| --- | --- | --- |
| `student` | stripped to `sorry` | the students, published to the book repository |
| `terse` | stripped to `sorry` | the instructor, opened in VS Code during class |
| `solutions` | kept | the instructor |
| `grading` | kept, plus grading attributes | the autograder; never leaves the private repository |

Prose can be routed to a variant:

- `:::full` — appears in the full-prose variants, omitted from `terse`.
- `:::terse` — appears only in `terse`.
- `:::suppressPreviousHeaderWhenTerse` — drops the preceding heading in the
  `terse` build, where the prose under it is gone and the heading would dangle.

### Notes and commentary

- `:::dev` — an internal note to the authors, rendered under the heading
  "Nota editorial". AI-generated commentary belongs here, and is marked as
  such.

  It takes an optional author (a string, as `Full Name (github-handle)`), an
  optional urgency (`NOW`, `BeforeNextRelease` or `PotentialImprovement`, a
  bare identifier), and an optional `(year := N)`.

  Two filters decide where a note appears, and they are independent:

  - **By variant**, in `Block.devcomment`'s `traverse`: the `student` build
    drops every note, from the HTML and from the generated `.lean` alike.
    `terse`, `solutions` and `grading` keep them all — `terse` is the
    instructor's, so a note on screen during a class is harmless.
  - **By urgency**, in `devNoteShown`: a `PotentialImprovement` note renders
    nothing even where it is kept. Notes marked `NOW` or `BeforeNextRelease`,
    and unmarked ones, render.

  So a dev note never reaches a student, and nothing in one has to be written
  with a student in mind.
- `:::quiz` and `:::quizSolution` — a comprehension check.
- `:::diagramWithAlt` — a diagram with its textual alternative, for
  accessibility.

### Other blocks

- ```` ```lean ```` — live Lean, elaborated by `lake build`. Everything in the
  book's code is checked; there are no illustrative-only Lean blocks.
- ```` ```lean (name := tag) ```` with ```` ```leanOutput tag ```` — code whose
  output is shown and checked against the block.
- `{include N Module}` — pulls a section file into its glue chapter at heading
  depth `N`.

## Lean style

Follow the Mathlib
[style guide](https://leanprover-community.github.io/contribute/style.html)
and [naming conventions](https://leanprover-community.github.io/contribute/naming.html),
except where pedagogy asks otherwise. In particular:

- Types and propositions in `PascalCase` (`Phoneme`, `WellFormed`).
- Functions and values in `camelCase` (`appendSuffixF`, `surfaceTable`).
- Theorems in `snake_case` (`defeated_last`), keeping the casing of the
  definitions they are about (`WellFormed.ne_nil`).
- Greek letters for type variables (`α`, `β`).

All identifiers and all code comments are in English, including in the code
the students read.

Prefer `cases … with` and `induction … with`, one alternative per line, over
goal selectors.

Reuse Mathlib and CSLib where they fit; `DEVIATIONS.md` records where they
deliberately do not, and why.

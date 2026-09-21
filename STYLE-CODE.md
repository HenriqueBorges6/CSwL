# CSwL Code Style Guide

This file records the conventions for the Lean code and the Verso markup that
make up the book. `STYLE-WRITING.md` covers prose, pedagogy, and translation;
`CONTRIBUTING.md` covers workflow. In case of conflict with `CLAUDE.md`, the
style guides win on style and `CLAUDE.md` wins on project scope.

The book's prose is in Portuguese. Everything else — this file, identifiers,
code comments, commit messages — is in English.

## The hard constraint: nothing is used before it is presented

One rule governs the whole book:

> **Nothing is used before it is presented.**

It has one loosening and one exception. The loosening: a basic type of Lean's
own may be introduced where it is first needed, in a sentence or two with a
citation of the Lean Language Reference (`{citep Bib.LLR}[]`), rather than in
`IntroL`. `Fin` in `SeaBattle` is the case. This covers types the language
already gives, never a construct this book defines, and never one that needs
more than a short paragraph. The exception is `IntroCS`, described below.

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
column does not by itself settle whether the rule holds. `Logic/Proof.lean`
presents fourteen tactics in a plain code fence — one line each, `rfl` through
`funext` — and a scan that reads only ```` ```lean ```` blocks misses it. Check
the prose before recording a gap.

The scan has to be fence-aware in the other direction too, or it reports
Portuguese words as Lean: "trivialmente" matches `trivial`, and a tactic named
in a sentence is a mention, not a use. Search inside ```` ```lean ```` blocks
with `--` comments stripped to find *uses*, then search the prose separately to
find *presentations*; the rule is satisfied only when a presentation precedes
the first use in book order.

Two further traps, both of which have already produced wrong rows. A ```` ```lean
+error ```` block is code shown *because it fails to compile*, so what it
contains is not a use: `IntroL` has `def omega := (fun x => x x) (fun x => x x)`,
which is a definition named `omega` in a block that errors, not the `omega`
tactic. And a name can be a field or a definition rather than the tactic it
looks like — `symm` in `Sets` is the `Equivalence.symm` field, `contradiction`
in `Logic/PL` is `Formula.contradiction` inside a `simp only [...]` list.
Read the line before recording a row.

A feature marked **(solution only)** first appears inside a `solution!(…)`
block. Those rows are a distinct case: the feature is invisible in the
`student` and `terse` variants and visible in `solutions` and `grading`, so a
reader working the exercise meets it only in the answer. Introducing a feature
this way is usually a mistake; see "Known gaps."

### Features by chapter of first use

| Chapter | Commands and declarations | Types and syntax | Tactics |
| --- | --- | --- | --- |
| `IntroCS` | `namespace`, `def` (by pattern matching), `inductive`, `deriving Repr`, `example`, `#eval` | `Nat`, `String`, function type `→`, `++`, dot-notation constructors (`.num`) | `rfl`, `induction … with`, `rw`, `rewrite`, `unfold`, `repeat` |
| `IntroL` | `#check`, `#print`, `theorem`, `structure … where`, `instance` (named and anonymous), `opaque` | `Type`, `Bool`, `Int`, `Float`, `List`, `Option`, `Char`, `fun`/`λ`, `↦`, `match`, `if … then … else`, `⟨…⟩`, structure literal `{ x := … }` and update `{ s with … }`, implicit `{α : Type}`, instance-implicit `[Repr α]`, `∘`, `::`, `BEq`, `f!` strings, `List.all`/`List.any` | *(none — the chapter is deliberately pre-proof)* |
| `Logic/Proof` | `open`, `section`, `variable` | `Prop`, `¬`, `∀`, `∃`, `∧`, `∨`, `↔`, `≠`, `False`, `absurd` (term), focus dots `·`, `h.1`/`h.2` | `intro`, `exact`, `apply`, `cases … with`, `constructor`, `obtain`, `have`, `use`, `left`, `right`, `by_cases`, `by_contra`, `assumption`, `funext`, `linarith`, `native_decide`, `rcases` and `Or.inl`/`Or.inr` **(solution only)** |
| `Logic/PL` | `abbrev`, docstrings `/-- … -/`, `deriving DecidableEq`, `open … in` | `×` and tuples, `DecidableEq`, `True`, `≤`, section notation `(· ≤ ·)`, `\|>` **(solution only)** | `decide`, `simp`, `simp only [...]`, tactic locations `… at … ⊢`, `rw [← …]`, `all_goals`, `simpa … using` |
| `Logic/FOL` | `mutual`, polymorphic `inductive … (α : Type)`, `def` whose body is a type (`def Assign (D : Type) := Variable → D`), theorem defined by equations | `Fin`, `∈`, `∉`, `Std.Format` and a hand-written `Repr`, bare implicit `{α}`, `∀ (D : Type)`, anonymous-constructor patterns (`\| ⟨name, []⟩`), `match e₁, e₂ with` **(solution only)** | `induction … generalizing`, `<;>`, `refine` with `?_`, `omega` |
| `Sets` | — | `Set`, `Rel`, `Finset`, `Fintype`, `Setoid`, `⊆`, `∪`, `∩`, `trivial` (term), `show … by …` **(solution only)** | `simp_all` |
| `SeaBattle` | inductive predicate (`inductive WellFormed : Game → Prop where`) | structure fields that carry proofs, bounded `∀ x ∈ xs`, `by` as a structure-field value, `Fin.val`, dependent `if h : … then … else` **(solution only)**, `▸` **(solution only)** | *(none new)* |
| `Morphology` | `open` of constructor namespaces (`open Attr Value`) | `match e₁, e₂ with` (first use outside a solution), `mapM` over `Option` **(solution only)** | *(none new)* |
| `InfEngine` | `let rec` | `do`-notation, `ToString` and its instance, `s!` strings | — |
| `English` | `mutual` over `inductive` types (`Logic/FOL` only uses it over `def`) | guillemet identifiers (`«with»`), pattern-matching `fun \| … => …` (first use outside a solution) | *(none new)* |

`English` is where `abbrev` and `ToString` instances become the dominant
idiom, but both arrive earlier; what is genuinely new there is the mutually
recursive *grammar*, a `mutual` block over `inductive` declarations rather
than over `def`s, and `«with»`, which quotes a Lean keyword so it can be used
as a constructor name. The pattern-matching `fun` — `fun | .a => "a" | …`,
with no `match` — first appears in `IntroL` and `Logic/PL`, both times inside
a `solution!`, so `English`'s `ToString` instances are where a student first
meets it in ordinary code.

The table records features, not every piece of notation. Type ascription,
list literals, projection dots, and the like are not tracked: they arrive with
the constructs that use them and tracking them would produce a ledger nobody
maintains. Library functions are not tracked either — `String.intercalate`,
`List.zip`, `Std.Format.joinSep`, `List.Nodup` and their kind arrive with the
code that needs them. (`List.all`/`List.any` under `IntroL` is an older
inconsistency; do not take it as licence to add siblings.)

### Known gaps

Open questions about the table, recorded so they are not lost. Each needs an
author decision, not a mechanical fix.

- **`trivial`** — two term-level uses on `Sets.lean:507`, not presented
  anywhere. It is listed in the table under types rather than tactics, since
  that is what it is here. Give it a line or replace it when that chapter is
  revised.
- **`omega` in `Logic/FOL`** — first used at `FOL.lean:593`, in the `Fin`
  examples (`⟨0, by omega⟩`). The prose there presents `Fin` and `Fin.mk` and
  says nothing about `omega`, so the reader meets the tactic in passing. It
  returns in `fol-infinite`. One line of presentation next to the `Fin`
  examples covers both places.
- **`refine` with `?_` and `induction … generalizing` in `Logic/FOL`** — they
  appear in `Formula.eval_iff_denote`, `le_foldr_max` and `no_list_lists_Nat`,
  which are shown with their proofs as exposition. No exercise asks the reader
  to reproduce any of them, so the question is whether a proof the reader only
  *reads* counts as handing them a tactic. If it does, a few short lines of
  presentation are owed; if it does not, these rows are evidence rather than a
  gap. Author's call, and the cheaper fix is the lines.
- **`<;>` in `Logic/FOL`** — first used at `FOL.lean:525`. The prose describes
  what happens ("a tática `decide` é combinada com `cases v`, que abre um caso
  por construtor") without naming the combinator or saying what `<;>` means.
  Naming it costs half a sentence.
- **The `simp` family in `Logic/PL`** — `simp`, `simp only [...]`,
  `all_goals`, `simpa … using`, the `at … ⊢` locations and `rw [← …]` all
  arrive unannounced in the `pl-to-prop` metatheorems. `Logic/Proof` promises
  that `omega` and `simp` "serão explicadas à medida que se fizerem
  necessárias"; the promise is never kept. This is the largest gap in the
  ledger, and it lands on proofs the reader is expected to read closely.
- **`abbrev`** — `PL.lean:341`, no presentation; it is introduced by use.
  Docstring syntax `/-- … -/`, first used in the same chapter, is in the same
  state, and is cheap to leave alone.
- **Features that only the answer shows** — `rcases` (`Proof.lean:420`),
  `Or.inl`/`Or.inr` (`Proof.lean:196`), `|>` (`PL.lean:120`), `match e₁, e₂
  with` (`FOL.lean:614`), `show … by …` (`Sets.lean:643`), and dependent
  `if h : … then … else` and `▸` (`SeaBattle.lean:307` and `315`) all appear
  first inside `solution!`, so a student working the exercise is expected to
  produce syntax the book never showed them. Two of them surface later in
  ordinary code — `|>` at `FOL.lean:369` and `match e₁, e₂ with` at
  `Morphology/Phonemes.lean:227`. `mapM` is the same shape: first used inside
  a solution (`Phonemes.lean:309`) and visible only much later, at
  `InfEngine.lean:439`. The pattern-matching `fun` is the same shape again —
  `IntroL.lean:364` and `PL.lean:245`, both in solutions, then ordinary code
  throughout `English`. The rest never surface at all.

`IntroCS` is the constraint's one accepted exception: it uses Lean that
`IntroL` only presents later, deliberately, and the chapter says so where its
first code block appears — the code is there to show where the book is going,
nothing in it is presented, and reading it is optional. Without that sentence
the chapter is not a teaser but an unannounced prerequisite. The exception does
not extend to any other chapter.

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
are long enough to deserve their own files is a "glue" file (`CSwL/Logic.lean`)
that only gathers them via `{include 1 …}` from a same-named directory. Each
content file has its own `namespace`: the book redefines the same names in
different chapters, deliberately.

`htmlSplit := .never` keeps a chapter on one HTML page, and also forbids the
split in every part below it. A single-file chapter should keep it. A glue
chapter should *omit* it, so each included section becomes its own page under
the chapter's directory — `Logic/PL/`, `Logic/FOL/` — which is what the
default `htmlDepth` of 2 already asks for. A section that gets its own page
needs its own `file := "Tag"`, or Verso builds the URL by sluggifying the
Portuguese title and the accents come out mangled (`L___gica-proposicional`).

`file :=` also names the generated Lean. A section that sets it becomes its
own module in the extracted project — `CSwL/Logic/PL.lean` in the source
becomes `CSwL/Logic/PL.lean` in the output — and the chapter becomes a glue
module importing them, mirroring the source. A section without `file :=` is
merged into its chapter's file, as every chapter's inline sections are. This
is why the key must match the module name exactly: the extractor resolves a
chapter's `import` against the *generated* names, and a mismatch is now an
error rather than a dropped import.

### Exercises and solutions

`:::exercise (rating := N) (name := "mnemonic")` — an exercise. `rating` is
difficulty, 1 to 5. `name` is the identifier used by `CSwFP.yaml` and by
the grading variant, and follows the mnemonic rule.

Inside an exercise, the answer is wrapped so the build variants can strip it:

- `solution!(…)` — an inline solution, for a term or a `by` block.
- `solution!` on its own line, followed by an indented block — a multi-line
  solution.
- `:::solution` — a prose solution, for exercises answered in words.

The `student` and `terse` variants replace these with `sorry`; `solutions` and
`grading` keep them. This is why a feature first used inside `solution!` is
invisible to the student.

Which of the two forms to use is not a matter of taste, because the `solutions`
variant strips the marker in place and what is left has to parse and elaborate
on its own:

- **A tactic block takes the indented form**, never `solution!(…)`. As a
  tactic the marker is replaced by `all_goals`, so the block must make sense
  applied to a *single* goal — a proof that splits into cases has to perform
  the split itself, inside the block, rather than relying on goals its caller
  left open.
- **A multi-line term begins on the line after `solution!(`**, indented under
  it. Written on the same line, its continuation lines are aligned against a
  column that only exists while the marker is there; removing the marker
  shortens the first line and the alignment breaks.

The book's own build catches neither mistake — a solution is elaborated in
place there, marker and all. Only the generated project sees the stripped
source, which is why `solutions` is verified (see `ExtractConfig.verify`).

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
- `:::details "summary"` — a collapsible aside, for material that supports the
  narrative without belonging to it (an extra proof, a digression). The
  positional summary string is the teaser shown while the block is closed, and
  is optional. In the generated `.lean` the contents are inlined, bracketed by
  `THE FOLLOWING DETAILS CAN BE SKIPPED` / `END DETAILS` markers — nothing is
  hidden from the reader of the code, only from the reader of the page.
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

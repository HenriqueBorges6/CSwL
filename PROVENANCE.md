# Exercise provenance

Which CSwFP exercise each `CSwL` exercise comes from. This mapping
used to live in the book's own prose, as `Ref. CSwFP/4, exercício 4.9
(p. 74)` lines; the book must be self-contained and never name its
source, so those lines are removed and the correspondence is kept here
instead.

This file is for the instructor: checking coverage (which of the
book's exercises are ported, which are still missing) and finding the
original statement when an exercise needs revising. It is
documentation *about* the project, not part of the book.

The `CSwL id` column holds each exercise's `(name := …)`. Since the
rename of 2026-08-30 these are English mnemonics carrying no number,
so **this file is now the only link between an exercise and the
passage it comes from**. Keep it in step with any further rename.

`prose` marks an exercise whose answer is given in prose rather than
stated in Lean. In the source these carry a `✎` marker, which is
otherwise undocumented.

The book has 81 exercises as of 2026-09-02, and every one of them
appears somewhere below — either in a table that names its source, or
in the list of those with no counterpart. Two checks keep it that way:
no `(name := …)` in `CSwL/` should be absent from this file, and no
name cited here should have stopped existing.

## A correction to the numbers

The 17 references in `Sets.lean` were all off by one chapter: they
read `CSwFP/2, exercício 3.N` where the book has **Exercise 2.N**. The
page numbers they cite were right, which is what makes the shift
visible — CSwFP's Exercise 2.1 is on p. 17, and the file cited
"exercício 3.1 (p. 17)". The book's chapter 2 has exercises 2.1 to
2.17, and there are exactly 17 of them.

The table below carries the corrected numbers. `IntroCS.lean`,
`Logic/PL.lean`, `Logic/FOL.lean` and `Morphology/Phonemes.lean` were
checked against the same source and are correct.

## Exercises taken from CSwFP

### `IntroCS.lean` — CSwFP/1

| CSwL id          | Rating | CSwFP        | Page |
|------------------|--------|--------------|------|
| `possibilities`  | 1      | Exercise 1.1 | 6    |
| `sentence-go-on` | 1      | Exercise 1.2 | 8    |

CSwFP Exercise 1.3 (infinitely many sentences, p. 8) is not ported.

### `Morphology/Phonemes.lean` — CSwFP/3.14

| CSwL id             | Rating | CSwFP                                   | Page  |
|---------------------|--------|-----------------------------------------|-------|
| `yawelmani-harmony` | 3      | Exercise 3.19 (Yawelmani vowel harmony) | 61–62 |

`feature-value` (rating 2) and `append-suffix-text` (rating 3) have no counterpart:
CSwFP hands `feature-value`/`fMatch` to the reader as given code, and `CSwL` turns
them into exercises.

### `Sets.lean` — CSwFP/2 (exercises `twice` and `adjective-types` moved on with CSwFP/2.4 and 2.5, to `IntroL.lean` and `English.lean`)

| CSwL id                     | Rating | CSwFP         | Page  | Notes                                |
|-----------------------------|--------|---------------|-------|--------------------------------------|
| `empty-subset`              | 1      | Exercise 2.1  | 17    |                                      |
| `empty-vs-singleton`        | 1      | Exercise 2.2  | 17    | prose                                |
| `double-complement`         | 2      | Exercise 2.3  | 17    | prose                                |
| `cartesian-square`          | 2      | Exercise 2.4  | 18    |                                      |
| `successor-composition`     | 2      | Exercise 2.5  | 18    |                                      |
| `converse-subset`           | 2      | Exercise 2.6  | 18    |                                      |
| `which-are-transitive`      | 2      | Exercise 2.7  | 19    |                                      |
| `transitive-iff-comp`       | 2      | Exercise 2.8  | 19    |                                      |
| `transitive-not-idempotent` | 2      | Exercise 2.9  | 19    |                                      |
| `successor-as-relation`     | 1      | Exercise 2.10 | 21    |                                      |
| `leq-as-function`           | 1      | Exercise 2.11 | 21    |                                      |
| `graph-is-functional`       | 2      | Exercise 2.12 | 21    |                                      |
| `twice`                     | 1      | Exercise 2.13 | 26    |                                      |
| —                           | —      | Exercise 2.14 | 26–27 | prose; not in an `:::exercise` block |
| —                           | —      | Exercise 2.15 | 28    | prose; not in an `:::exercise` block |
| —                           | —      | Exercise 2.16 | 28    | prose; not in an `:::exercise` block |
| `adjective-types`           | 1      | Exercise 2.17 | 30    |                                      |


Note that 2.14, 2.15 and 2.16 sit in the prose without an exercise
directive, so they get no rating, no solution elision and no
autograding.

Exercises 2.1, 2.2 and 2.3 (`empty-subset`–`double-complement` above)
stay with this chapter when it moves after `Logic.lean`; 2.3 (`Ā̄ = A`)
is the one that needs classical reasoning, and is the reason for the
move.

### `Games/SeaBattle.lean` - CSwFP/4.1

- Exercise 4.1 is `game-over-grammar` (prose now, but better change to Lean code)



### `Logic/PL.lean` — CSwFP/4.4

| CSwL id           | Rating | CSwFP         | Page | Notes              |
|-------------------|--------|---------------|------|--------------------|
| —                 | —      | Exercise 4.9  | 74   | dropped 2026-09-02 |
| `exclusive-or`    | 1      | Exercise 4.10 | 74   |                    |
| —                 | —      | Exercise 4.11 | 74   | dropped 2026-09-02 |
| `count-operators` | 1      | Exercise 4.12 | 75   |                    |
| `formula-depth`   | 1      | Exercise 4.13 | 75   |                    |
| `collect-atoms`   | 2      | Exercise 4.14 | 75   |                    |

Exercises 4.9 and 4.11 were ported and then dropped when the chapter
was restructured around worked arguments. 4.9 asked for three
sentences to be translated into propositional logic; `exchange-prop`,
`dresses` and `bangu-form` ask the same thing of arguments the reader
then has to prove or settle, which is the same skill with a use
attached. 4.11 asked for unique readability — see `DEVIATIONS.md` on
why the original claim dissolves — and the section that carried it,
along with the parenthesis-counting results of Theorem 4.1 and
Proposition 4.2, went with the restructuring.

### `Logic/FOL.lean` — CSwFP/4.5–4.7

| CSwL id                 | Rating | CSwFP                   | Page | Notes   |
|-------------------------|--------|-------------------------|------|---------|
| -                       | 2      | Exercise 4.15           | 77   | dropped |
| -                       | 1      | Exercise 4.16           | 77   | dropped |
| -                       | 1      | Exercise 4.17           | 78   | dropped |
| `closed-form`           | 2      | Exercise 4.18           | 81   |         |
| `implication-as-abbrev` | 1      | Exercise 4.19           | 82   |         |
| `negation-normal-form`  | 2      | Exercise 4.20           | 82   |         |
| -                       | 1      | Exercise 4.21           | 83   | dropped |
| `vars-in-formula`       | 1      | Exercise 4.22           | 84   |         |
| `open-form`             | 2      | Exercises 4.23 and 4.24 | 84   | merged  |

All ten are `:::exercise` directives. Nine of them were plain `#` headings
carrying the source's page number until 2026-08-30; 4.23 and 4.24 became one
exercise, since 4.23 asked for the function that 4.24 builds on.

### `Logic/PL.lean` — CSwFP/5.2, 5.3

| CSwL id             | Rating | CSwFP         | Page | Notes      |
|---------------------|--------|---------------|------|------------|
| `valuation-table`   | 1      | Exercise 5.4  | 92   |            |
| `negated-tautology` | 1      | Exercise 5.5  | 93   | prose      |
| —                   | —      | Exercise 5.6  | 93   | not ported |
| —                   | —      | Exercise 5.7  | 93   | not ported |
| —                   | —      | Exercise 5.8  | 93   | not ported |
| —                   | —      | Exercise 5.9  | 93   | not ported |
| `implies-list`      | 2      | Exercise 5.10 | 96   |            |
| —                   | —      | Exercise 5.11 | 96   | not ported |
| —                   | —      | Exercise 5.12 | 96   | not ported |

### `Logic/FOL.lean` — CSwFP/5.5

| CSwL id                | Rating | CSwFP         | Page | Notes      |
|------------------------|--------|---------------|------|------------|
| `quantifier-strength`  | 2      | Exercise 5.17 | 102  | prose      |
| `translate-quantified` | 2      | Exercise 5.18 | 102  |            |
| —                      | —      | Exercise 5.19 | 102  | not ported |
| —                      | —      | Exercise 5.20 | 103  | not ported |
| —                      | —      | Exercise 5.21 | 103  | not ported |
| —                      | —      | Exercise 5.22 | 103  | not ported |
| —                      | —      | Exercise 5.23 | 104  | not ported |
| `valid-consequence`    | 2      | Exercise 5.24 | 104  | prose      |

### `InfEngine.lean` — CSwFP/5.7

| CSwL id | Rating | CSwFP         | Page | Notes      |
|---------|--------|---------------|------|------------|
| —       | —      | Exercise 5.28 | 109  | not ported |
| —       | —      | Exercise 5.29 | 109  | not ported |


## Exercises not ported, and why

An exercise absent from the tables above is a decision, not an oversight. The
reasons fall into three kinds.

**It asks for a construction the chapter does not have.** CSwFP/5.21 defines
substitution of a name for a variable in a term; 5.22 asks for a truth
definition that replaces assignments by names plus substitution; 5.23 asks for
the truth definition extended to structured terms. All three need substitution,
which `FOL.lean` never defines, and 5.23 additionally needs the interpretation
of function symbols. Writing those constructions is a chapter's worth of work,
not an exercise's.

**It is answered by something the chapter already states.** CSwFP/5.6 asks which
of three formulas are satisfiable, 5.7 which equivalences hold, 5.8 which
consequences hold, 5.19 and 5.20 the same for predicate logic. In this book
`satisfiable`, `equivalent` and `implies` are computable, so each of these is
`#eval` rather than a question — the answer is a keystroke, and the exercise
loses its point. They are worth keeping only if reformulated as proofs about
the definitions rather than queries against them.

**It asks for a variant implementation.** CSwFP/5.11 asks for a check of logical
equivalence, which `Form.equivalent` already is; 5.12 asks to reimplement the
semantics with `[String]` instead of `[(String, Bool)]` for valuations.

CSwFP/5.13–5.16 belong to Mastermind and are recorded with `Games.lean`.
CSwFP/5.18 is ported as `translate-quantified`. Its propositional counterpart,
4.9, was dropped; the two chapters no longer mirror each other here.

CSwFP/5.28 and 5.29 ask for soundness and completeness of the Aristotelian
inference system. Soundness is within reach — `InfEngine.lean` already proves
BARBARA, CELARENT and DARII valid over `Set` — but completeness needs a model
construction the chapter does not have.

Nine of the `Logic/FOL.lean` entries above were plain headings carrying the
book's page number rather than exercise directives; that is fixed.

## Exercises original to CSwL

No CSwFP counterpart. Listed so that "absent from the table above" is not read
as an oversight.

| File                            | CSwL id                    | Rating |
|---------------------------------|----------------------------|--------|
| `Morphology/Phonemes.lean`      | `feature-value`            | 2      |
| `Morphology/Phonemes.lean`      | `append-suffix-text`       | 3      |
| `Morphology/SwedishPlural.lean` | `swedish-plural`           | 2      |
| `English.lean`                  | `preposition-phrase`       | 1      |
| `English.lean`                  | `complex-relative-clauses` | 1      |
| `Sets.lean`                     | `five-in-above2`           | 1      |
| `Sets.lean`                     | `one-not-in-above2`        | 1      |
| `Sets.lean`                     | `above5-subset-above2`     | 1      |
| `Sets.lean`                     | `union-contains`           | 1      |
| `Sets.lean`                     | `intersection-contained`   | 1      |
| `Games/Mastermind.lean`         | `four-turn-game`           | 1      |
| `Games/Mastermind.lean`         | `chess-grammar`            | 1      |
| `Games/SeaBattle.lean`          | `game-over-grammar`        | 2      |
| `Games/SeaBattle.lean`          | `defeated-last`            | 3      |
| `Games/SeaBattle.lean`          | `add-ship`                 | 3      |
| `Games/SeaBattle.lean`          | `sunk`                     | 2      |
| `Games/SeaBattle.lean`          | `grice-maxims`             | 1      |
| `IntroL.lean`                   | `sum-of-squares`           | 1      |
| `IntroL.lean`                   | `building-terms`           | 1      |
| `IntroL.lean`                   | `rfl-arithmetic`           | 1      |
| `IntroL.lean`                   | `square-unfold`            | 1      |
| `IntroL.lean`                   | `identity-implication`     | 1      |
| `IntroL.lean`                   | `p-implies-q-implies-p`    | 1      |
| `IntroL.lean`                   | `and-intro`                | 1      |
| `IntroL.lean`                   | `and-comm`                 | 2      |
| `IntroL.lean`                   | `implication-transitivity` | 1      |
| `IntroL.lean`                   | `apply-several-premises`   | 1      |
| `IntroL.lean`                   | `unfold-direct-proof`      | 1      |
| `IntroL.lean`                   | `unfold-conjunction`       | 1      |
| `IntroL.lean`                   | `exists-witness`           | 1      |
| `IntroL.lean`                   | `cases-on-or`              | 1      |
| `IntroL.lean`                   | `is-weekend`               | 1      |
| `IntroL.lean`                   | `add-zero-induction`       | 1      |
| `IntroL.lean`                   | `sum-to`                   | 1      |
| `IntroL.lean`                   | `sum-list`                 | 1      |
| `IntroL.lean`                   | `count-zeros`              | 1      |
| `Logic/PL.lean`                 | `contrapositive`           | 1      |
| `Logic/PL.lean`                 | `de-morgan`                | 2      |
| `Logic/PL.lean`                 | `exchange-prop`            | 1      |
| `Logic/PL.lean`                 | `dresses`                  | 2      |
| `Logic/PL.lean`                 | `bangu-form`               | 1      |
| `Logic/PL.lean`                 | `bangu-proof`              | 1      |
| `Logic/FOL.lean`                | `forall-exists-swap`       | 2      |
| `InfEngine.lean`                | `inconsistent-kb`          | 2      |
| `InfEngine.lean`                | `ferio`                    | 2      |

CSwFP's chapter 3 exercises 3.1–3.18 are not ported: they are about Haskell
itself (types of Haskell functions, Haskell programs to read). Exercise 3.18
(the type of `vh`, p. 54) belongs with Finnish vowel harmony and is the one
worth reconsidering.

## Section-level references

These were also `Ref.` lines in the book's prose. The chapter-level mapping now
lives in `DEVIATIONS.md`; this table records the finer-grained pointers that
existed inside chapters.

| File                       | Section         | CSwFP                                                      | Page   |
|----------------------------|-----------------|------------------------------------------------------------|--------|
| `IntroCS.lean`             | chapter opening | CSwFP/1 Formal Study of Natural Language                   | —      |
| `IntroL.lean`              | Tipos indutivos | §3.13                                                      | 55     |
| `IntroL.lean`              | Recursão        | §3.5                                                       | 40     |
| `IntroL.lean`              | Listas          | §3.6, and §3.4 for polymorphism                            | 41, 39 |
| `IntroL.lean`              | `map`/`filter`  | §3.7, §3.8                                                 | 42–43  |
| `IntroL.lean`              | Type classes    | §3.9                                                       | 45     |
| `IntroL.lean`              | Strings         | §3.10                                                      | 47–48  |
| `Sets.lean`                | chapter opening | CSwFP/2 Lambda Calculus, Types, and Functional Programming | —      |
| `Morphology/Phonemes.lean` | chapter opening | §3.14                                                      | 58–61  |

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

The book has 76 exercises as of 2026-09-13, and all but one of them
appear somewhere below — either in a table that names its source, or
in the list of those with no counterpart. Two checks keep it that way:
no `(name := …)` in `CSwL/` should be absent from this file, and no
name cited here should have stopped existing.

The exception is `free-vars-in-formula`, in `Logic/FOL.lean`, which has
no entry here; it predates the chapter reorganization of 2026-09-13 and
still needs one.

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

### `SeaBattle.lean` - CSwFP/4.1

- Exercise 4.1 is `game-over-grammar` (prose now, but better change to Lean code)

### Mastermind — dropped

| CSwL id | Rating | CSwFP | Page | Notes |
|---------|--------|-------|------|-------|
| — | — | Exercise 5.13 | — | dropped 2026-09-13 |
| — | — | Exercise 5.14 | — | dropped 2026-09-13 |
| — | — | Exercise 5.15 | — | dropped 2026-09-13 |
| — | — | Exercise 5.16 | — | dropped 2026-09-13 |

`Games/Mastermind.lean` was removed with the chapter reorganization: it was
disconnected from what preceded it, and it promised a semantics in
propositional logic that it never gave. Two exercises went with it,
`four-turn-game` and `chess-grammar`, along with CSwFP/5.13–5.16, which had no
`CSwL` counterpart in the first place.

### `Logic/Proof.lean` 

No exercise from CSwFP, all exercises were created.

### `Logic/PL.lean` 

Source: CSwFP/4.4 CSwFP/5.2 CSwFP/5.3

Exercise 4.9 translation of NL to PL
= bangu-form
obs: temos também bangu-proof

Exercise 4.10 xor
= exclusive-or

Exercise 4.11 about the grammar
obs: we need ContextFreeGrammar from Mathlib

Exercise 4.12 opsNr 
= count-operators

Exercise 4.13 depth 
= formula-depth

Exercise 4.14 propNames 
= collect-atoms 

*novo*
= collect-atoms-alternative
obs: alternative for `names` without mergeSort and `eraseDups`

Exercise 5.4 evaluation of formulas
= valuations

Exercise 5.5 negation of a tautology is always a contradiction, and vice-verssa
obs: in the prose 

*novo*
= ex-pl-contingent
obs: definition of contingent

Exercise 5.6 quais formulas sao sat e para elas me da v!
= ex-pl-satisfiable

Exercise 5.7 quais equiv sao verdade!
= ex-pl-equiv

Exercise 5.8 Which of the following are true?
= pl-consequence
dep: implies-from-list

Exercise 5.9 Show principle of contraposition 
obs: in the prose

Exercise 5.10 implementar impliesL
= implies-from-list

*novo*
= bangu-proof
dep: bangu-form
obs: complete problem using logical consequence

Exercise 5.11 implement equivalence
obs: in the prose

Exercise 5.12 redefine Valuation from [(String, Bool)]
obs: implemented in the prose


### `Logic/FOL.lean` — CSwFP/4.5–4.7

Exercise 4.15 uniq readable
obs: not applicable without ContextFreeGrammar from Mathlib

Exercise 4.16 alternative BNF
obs: not formalizable without ContextFreeGrammar

Exercise 4.17 bound ocurrences of x in a formula
= ex-fol-freevars

Exercise 4.18 closedForm
= ex-fol-closedform

Exercise 4.19 withoutIDs
= ex-fol-remove-impl_equiv

Exercise 4.20 nnf
= ex-fol-nnf

Exercise 4.21 parse tree of terms
obs: not applicable without ContextFreeGrammar

Exercise 4.22 implement varsInForm
= ex-fol-vars-in-formula

Exercise 4.23 implement freeVarsInForm
= ex-fol-free-vars-in-form 

Exercise 4.24 openForm
= ex-fol-open-form

Exercise 5.17 all/exists weak/strong
= ex-fol-weak-strong

Exercise 5.18 translate to FOL
= ex-fol-translate

Exercise 5.19 check formulas model given
= ex-fol-model

Exercise 5.20 consequence are true?
= ex-fol-valid

Exercise 5.21 substitute vars in terms
obs: alternative definition, introduce names in the language

Exercise 5.22 language extension
obs: alternative definition, use 5.21 semantics of language + names - assigments

Exercise 5.23 Write out the truth definition for formulas with terms
obs: in the prose

Exercise 5.24 logical consequences a |= b holds?
= ex-fol-consequence

*novo*
= ex-fol-implies-from-list
obs: FOL analogue of implies-from-list (CSwFP/5.10); drawn from the prose
     between 5.24 and 5.25, "We can make this slightly more general by
     allowing sets of more than one premise"

Exercise 5.25 logical consequences Delta |= b holds?
= ex-fol-entails
dep: ex-fol-implies-from-list


### `InfEngine.lean` — CSwFP/5.7

| CSwL id | Rating | CSwFP         | Page | Notes      |
|---------|--------|---------------|------|------------|
| —       | —      | Exercise 5.28 | 109  | not ported |
| —       | —      | Exercise 5.29 | 109  | not ported |


## Exercises not ported, and why

An exercise absent from the tables above is a decision, not an oversight. The
reasons fall into three kinds.

**It asks for alternative definitions that are irrelevante.** CSwFP/5.21 defines
substitution of a name for a variable in a term, and 5.22 asks for a truth
definition that replaces assignments by names plus substitution. Both need
rename of variables, never defines.

CSwFP/5.23 — the truth definition extended to structured terms, we
decided to add it in the prose, many other parts of the prose would
need it, having it undefined would make the presentation harder.

**It asks for a variant implementation.**  5.12 asks to reimplement
the semantics with `[String]` instead of `[(String, Bool)]` for
valuations. The semantics in PL now uses `Variable -> Bool`.

CSwFP/5.28 and 5.29 ask for soundness and completeness of the Aristotelian
inference system. Soundness is within reach — `InfEngine.lean` already proves
BARBARA, CELARENT and DARII valid over `Set` — but completeness needs a model
construction the chapter does not have.

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
| `SeaBattle.lean`                | `game-over-grammar`        | 2      |
| `SeaBattle.lean`                | `defeated-last`            | 3      |
| `SeaBattle.lean`                | `add-ship`                 | 3      |
| `SeaBattle.lean`                | `sunk`                     | 2      |
| `SeaBattle.lean`                | `grice-maxims`             | 1      |
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
| `Logic/FOL.lean`                | `ex-fol-implies-from-list` | 2      |
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
| `IntroL.lean`              | Casamento de Padrões, Recursão e Indução | §3.5                                  | 40     |
| `IntroL.lean`              | Listas          | §3.6, and §3.4 for polymorphism                            | 41, 39 |
| `IntroL.lean`              | `map`/`filter`  | §3.7, §3.8                                                 | 42–43  |
| `IntroL.lean`              | Type classes    | §3.9                                                       | 45     |
| `IntroL.lean`              | Strings         | §3.10                                                      | 47–48  |
| `Sets.lean`                | chapter opening | CSwFP/2 Lambda Calculus, Types, and Functional Programming | —      |
| `Morphology/Phonemes.lean` | chapter opening | §3.14                                                      | 58–61  |

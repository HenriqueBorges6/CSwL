# How CSwL departs from CSwFP

`CSwL` reorders CSwFP so that the presentation is natural in Lean.
`CSwFP.yaml` says where each CSwFP section and exercise went. This
file records the decisions behind that, as they stand now; how they
were reached is in the git history and the pull requests. The rules
the decisions serve are in `STYLE-CODE.md` and `STYLE-WRITING.md`.

## Chapter order

CSwFP runs sets, lambda calculus and types (2) before Haskell (3). That works
because its chapter 2 is prose. In Lean the same material is code, so the
language has to come first, and chapter 2 is split: 2.3 and 2.4 into
`IntroL`, 2.1 and 2.2 into `Sets`; 2.5 is dropped.

| Chapter      | Requires  | Why                                                                         |
|--------------|-----------|-----------------------------------------------------------------------------|
| `IntroCS`    | —         |                                                                             |
| `IntroL`     | `IntroCS` |                                                                             |
| `Logic`      | `IntroL`  |                                                                             |
| `Sets`       | `Logic`   | its exercises are proofs, and 2.3 needs classical reasoning                 |
| `SeaBattle`  | `Logic`   | its exercises prove theorems by induction on `WellFormed`                   |
| `Morphology` | `IntroL`  | placed here so that its exercises may use tactics                           |
| `InfEngine`  | `Sets`    | the language of 4.3 is about sets, and the syllogisms are proved over `Set` |
| `English`    | `Logic`   | it translates into `FOL`'s `Formula` and evaluates with its `eval`; best after `Sets`, whose characteristic functions build the model |

CSwFP/6 is in `English`: it is built on the fragment of 4.2, whose
categories it translates one by one. 

## Reusing Mathlib and CSLib

The default is to reuse. What is reused today: `Set`, `Rel`, `Setoid`,
`Finset` and `Fintype` from Mathlib in `Sets`, `List.Chain` in `SeaBattle`,
and the tactic library. No chapter imports CSLib yet.

- **CSLib's propositional logic is not used.** It would put a third object,
  `Γ ⊢ A`, next to `Formula` and `Prop` in the reader's first logic chapter;
  it takes `imp` as primitive where `Formula` takes `neg`; and it presents
  minimal logic, with classical strength as axioms of a theory. CSLib has no
  semantics for propositional logic and no first-order logic, so 5.2, 5.3 and
  5.5 have nothing to reuse.
- **`PL` defines a plain `eval` and states the bridge to `Prop` as ordinary
  theorems**, not in CSLib's `Satisfies`/`HasInferenceSystem` shape. Adopting
  the shape later is one structure, one instance and one notation on top of
  `eval`, and belongs in a separate module.
- **Mathlib's `ContextFreeGrammar` is deferred.** `SeaBattle` models its BNF as
  ordinary types, and nothing checks that the types match the grammar. The
  library would supply that link, derivations, and unique readability for
  `PL`. It would also mean giving each grammar twice and proving membership by
  building `ReflTransGen` chains. The natural place is a closing section of
  `SeaBattle`. Exercises 4.11, 4.15, 4.16 and 4.21 wait on it.
- **A proof system as data** (CSLib's `Derivation`) is deferred, not rejected.
  Soundness needs CSLib's derivations and this book's valuations together.
  Its natural place is after `Sets`, once CSwFP/1–6 are in place.

## By chapter

Where a CSwFP section went, and why, is in `CSwFP.yaml`. What follows are the
decisions inside the chapters.

### `IntroL`

- `instance` is presented here: later chapters declare instances, and no
  chapter declares a `class`.
- `Prop` is not: `Logic` presents it, and every chapter that shows `Prop`
  comes after `Logic`. `IntroL` uses `example` and `rfl` only as the shape of
  an exercise's tests.

### `Logic`

- **`PL` and `FOL` have the same three parts**: syntax as an `inductive`, a
  computable semantics, and the bridge that interprets the syntax into `Prop`
  and proves the two readings agree. The bridge has no source.
- `Formula` is binary in both files, with `conjs`/`disjs` for the n-ary
  notation. A constructor holding a `List Formula` would make the type nested,
  costing `induction` and `deriving`. `mutual` is introduced in `FOL`, for
  `Term`.
- Structural induction is the recursor `inductive` generates. Unique
  readability is not stated: a term of `Formula` is already a tree, so there is
  no string to disambiguate.
- The domain of the model in `FOL` is an `inductive` plus a `List`, joined by
  `mem_vertices`, which discharges the hypothesis of the bridge theorem.
  `Fintype` does not replace the `List`: its quantifier instance is the same
  walk hidden in an instance, `deriving Fintype` fails on this toolchain, and
  no computable route leads back to a `List`.
- One `eval` serves `Formula Variable` and `Formula Term`, taking the term
  valuation as a parameter, where CSwFP has two evaluators.
- Validity comes in two families, `Valid`/`Satisfiable`/`Implies` for
  `Formula Variable` and `ValidT`/`ImpliesL` for `Formula Term`: a structure
  without function symbols is `(D, I)`, with them `(D, I, F)`.
- A model in `FOL` interprets predicates as functions (`D → Prop`), not with
  `Set` or `Rel`, which arrive in `Sets`.
- `no_list_lists_Nat` proves that no list covers `Nat`, so the bridge
  hypothesis cannot hold over `Nat`.

### `InfEngine`

- The least fixed point is computed with a fuel bound, the square of the
  domain size, since iterating to a fixed point has no structural termination
  argument.
- Relations are `List (α × α)`, named `Relation` so that Mathlib's `Rel` keeps
  its name.
- The closing section, which proves syllogisms valid over `Set`, has no source.

### `English`

- The sections are 6.1, 4.2, 6.2, and 6.3 with 6.4. 6.2 translates the 4.2
  grammar category by category, so the grammar comes first; 6.1 motivates the
  translation, so it opens the chapter.
- A Lean function is total, so the gaps `MCWPL.hs` leaves are decisions:
  - `most` is not in `DET`: it has no first-order translation, as 6.2 says,
    and the prose states the limitation. `a` is in `DET`, since 6.2 treats it.
  - `AV`, `To`, `INF` and `TINF` are not in the grammar: they illustrate
    intensionality, and 6.2 gives them no translation.
  - `ADJ` is translated intersectively. That is right for *happy* and *evil*,
    not for *fake*, and the prose says so.
  - `caught` gets an atom like every transitive verb. The model does not
    interpret it, so every sentence using it is false.
- The grammar is extended by wrapping, not by redeclaring: a new category
  containing the old one (`| base (np : NP)`) plus the new rules. The chapter
  shows it on sentence coordination, and the exercises of 4.7 and 4.8 use it.
  The extension is not recursive, and the new constructors never overlap with
  the old ones.
- Constructors are named for what they are (`npDet`, `rcnSubj`, `rcnObj`,
  `vpTrans`), not numbered (`NP1`, `RCN2`).
- The fairy-tale model of 6.3 is here, next to the grammar it interprets.
  Predicates are `Entity → Bool`; `admire` and `defeat` are written as
  conditions rather than list comprehensions; `Unspec` is the default of the
  `FInterp`; and names and argument order agree with the translation, which
  in the Haskell source they do not.

## Beyond CSwFP/6

Not planned yet. CSwFP/7 continues the fragment of `English` and builds on the
same syntax, so it comes after `English`.

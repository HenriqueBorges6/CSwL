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
`IntroL`, 2.1 and 2.2 into `Sets`, 2.5 into `English`.

| Chapter      | Requires  | Why                                                                         |
|--------------|-----------|-----------------------------------------------------------------------------|
| `IntroCS`    | —         |                                                                             |
| `IntroL`     | `IntroCS` |                                                                             |
| `Logic`      | `IntroL`  |                                                                             |
| `Sets`       | `Logic`   | its exercises are proofs, and 2.3 needs classical reasoning                 |
| `SeaBattle`  | `Logic`   | its exercises prove theorems by induction on `WellFormed`                   |
| `Morphology` | `IntroL`  | placed here so that its exercises may use tactics                           |
| `InfEngine`  | `Sets`    | the language of 4.3 is about sets, and the syllogisms are proved over `Set` |
| `English`    | `Sets`    | its categorial section interprets verbs over `Sets.Entity`                  |

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

Being written (#29). Planned: the semantic types are named `e` and `t`, since
`NP`, `VP` and the other category names are the fragment's `inductive`s, and
the typing rules of 2.5 are shown over the fragment's own types. `INF` is in
the 4.2 grammar but has no translation in CSwFP/6.

## Beyond CSwFP/6

Not planned yet. CSwFP/7 continues the fragment of `English` and builds on the
same syntax, so it comes after `English`.

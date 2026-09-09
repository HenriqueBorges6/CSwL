# How CSwL uses CSwFP

`CSwL` is not a section-by-section translation of CSwFP. It reorders the material so that the presentation is natural in Lean, under one hard constraint:

> **Nothing is used before it is presented.**

Names — of files, of chapter and section tags, of exercises — are English
mnemonics, never numbers. The prose is in Portuguese; the identifiers are not,
and they carry no number because material moves between chapters and a number
would be wrong the moment it did.

The prose never explains the book by contrast with anything else. A paragraph
saying why this text does something differently — from the source it adapts,
from a library, from an alternative it considered — is about the book, not
about its subject, and the reader has no use for it. Those reasons belong in
this document. The rule is not about naming CSwFP: a passage can break it
without mentioning any source at all, and two did.

The line to hold is not "never mention an alternative". It is:

- a **technical consequence in Lean** is content, because the reader will meet
  it. "A constructor holding a `List Form` makes the type a nested inductive,
  and a nested inductive has no `induction` tactic" states a fact about Lean
  that the chapter then depends on;
- an **editorial preference** is meta. "We preferred to keep `Game` as it is",
  "the columns could have been modelled like the rows, but we chose the usual
  convention" — these report what the authors decided, which is this
  document's subject and not the book's.

The test: would the sentence still be worth writing if this book had no source
and no alternatives? A fact about Lean survives that; a preference does not.

A chapter that translates keeps the original's structure — its section
boundaries, its order, its sentence boundaries and its punctuation. Subheadings
that the source does not have are not added, and headings the source has are not
merged, unless something in this document says so and says why.

Most chapters, though, are mixed: part translated, part written here because
Lean makes something sayable that the source could not say. In a mixed chapter
the rule applies section by section. A translated section follows the original;
a new section has a structure of its own, chosen for what it teaches. Which
sections are which is recorded per chapter below — a reader of this document
should never have to guess whether a heading came from the source or from us.

Any divergence from this plan is stated when it is made. A silent divergence is
worse than a wrong one: a wrong decision can be argued with, an unrecorded one
cannot.

"Presented" has one deliberate loosening and one exception.

The loosening: Lean's own basic types may be introduced *where they are first
needed*, in a sentence or two, with a citation of the Lean Language Reference
(`{citep Bib.LLR}[]`), instead of being pushed back into `IntroL.lean`. `Fin`
and `Vector` in `Games.lean` are the cases. `IntroL.lean` presents what the
book builds on repeatedly; a type used in one chapter is better introduced
there, next to its use. The loosening covers types the language already gives
us — never a construct this book defines, and never one that needs more than a
short paragraph.

The exception: `IntroCS.lean`, described in that chapter's section below.
Everywhere else, a construct in a code block is one an earlier chapter has
presented.

This document is the migration plan: which CSwFP sections each `CSwL` chapter consumes, in which order, and what each chapter presupposes. The order below is the book's order; the dependency columns are what justify it. Everything through CSwFP/6 is settled — where a section records a decision, that decision is made, not proposed. What remains is execution, tracked in `TODO.md`. Exercise-level correspondence with CSwFP is in `PROVENANCE.md`.

The current state of CSwL need major review to fulfill all decisions from this document.

## Why the order changes at all

CSwFP runs 1, 2 (sets, relations, lambda, types), 3 (Haskell), 4 (syntax), 5 (semantics), 6 (model checking). That works in Haskell because CSwFP/2 is *pure prose*: nothing in it is mechanised, so it owes nothing to the chapter that introduces the language. In Lean the same material is mechanisable, which inverts the dependency and forces the reordering below.

CSwFP/2 also cannot be split cleanly, because its sections form a definitional chain: 2.3 opens "Functions are relations with the following special property", so it needs 2.2, which needs 2.1; 2.4 opens "We already talked about functions informally", so it needs 2.3; 2.5 builds on the terms of 2.4. The chapter is therefore *dissolved* rather than moved — 2.3, 2.4 and 2.5 into `IntroL.lean`, 2.1 and 2.2 into `Sets.lean`, and the natural-language examples scattered through 2.4 and 2.5 into `English.lean`.

## Chapter order

*Requires* means the chapter does not stand without it — material it uses that the earlier chapter presents. *Best after* is placement by preference: the chapter would still work earlier, but reads better here. Only the *Requires* column is a constraint.

| # | `CSwL` chapter       | CSwFP sections                                    | Requires | Best after |
|---|----------------------|---------------------------------------------------|----------|------------|
| 1 | `IntroCS.lean`       | 1.1–1.6                                           | —        | —          |
| 2 | `IntroL.lean`        | 3.1–3.10, 3.13; 2.3, 2.4, 2.5                     | 1        | —          |
| 3 | `Morphology.lean`    | 3.11, 3.14                                        | 2        | —          |
| 4 | `Games.lean`         | 4.1, 5.1, 5.4 (implementation only)               | 2        | —          |
| 5 | `Logic.lean`         | 4.4, 4.5, 4.6, 4.7, 5.2, 5.3, 5.5, 5.4 (encoding) | 2, 4     | —          |
| 6 | `Sets.lean`          | 2.1, 2.2                                          | 2, 5     | —          |
| 7 | `InfEngine.lean`     | 4.3, 5.7                                          | 2, 5     | 6          |
| 8 | `English.lean`       | 4.2, 5.6                                          | 2, 5, 6  | —          |
| 9 | `ModelChecking.lean` | 6.1–6.5                                           | 2, 5, 8  | 6          |

`Logic.lean` requires `Games.lean` because its closing section encodes a game the reader has already implemented. `English.lean` requires `Sets.lean` because its categorial section interprets a transitive verb over `Sets.Entity` and `Sets.likesR`, the domain and relation that chapter introduces. `Sets.lean` requires `Logic.lean` because its exercises are proofs, and the tactics they need — quantifiers, `cases`, `by_contra` — arrive there; but nothing requires `Sets.lean` in turn, so its position is fixed from below and free from above.

## Reusing Mathlib and CSLib

Reusing Mathlib and CSLib is a declared intention of this project, and contributing back to CSLib is another. So the default is to reuse, and every place where this book defines something a library already has needs a reason. Two such places are recorded here; both are decisions for the chapters through CSwFP/6, and both are revisited in "Beyond CSwFP/6".

What is reused today is modest and worth stating plainly: Mathlib supplies `Set`, `Rel`, `Setoid`, `Finset` and `Fintype` to `Sets.lean`, `List.Chain` to `Games.lean`, and the tactic library throughout. No chapter imports CSLib yet.

### Propositional logic: why not CSLib's, for now

CSLib has, in `Cslib.Logic.PL`:

- `Proposition Atom` — `atom`, `and`, `or`, `imp`, with `¬A := A → ⊥` and `⊤` as derived notions;
- `Theory.Derivation : Ctx Atom → Proposition Atom → Type` — sequent-style natural deduction, `Finset` contexts, rules `ax`, `ass`, `andI`, `andE₁`, `andE₂`, `orI₁`, `orI₂`, `orE`, `implI`, `implE`, with `Γ ⊢ A` and `T⇓(Γ ⊢ A)` notation;
- weakening, cut and substitution as derived rules; `IsIntuitionistic` and `IsClassical` as *theories*, yielding `byContra`, `lem` and `pierce`.

That is a complete natural deduction system, ready to use, and `PL.lean` does not use it. Three reasons:

1. **It would put a third object in front of the reader at once.** The chapter already has to separate `p ∧ q : Prop` from `Form.conj p q : Form`, and that separation is the section glued to the `inductive`. Adding `Γ ⊢ A ∧ B` makes it a three-way distinction in the chapter where the reader meets all three for the first time. This is a pedagogical cost, not a technical one: CSLib solves the notation clash with a wrapper tag naming the logic (`Modal[m,w ⊨ φ]`), stated as a principle in `Cslib/Logics/README.md`.
2. **The connectives do not line up.** `CSwL`'s `Form` takes `neg`, `top` and `bot` as constructors and derives `impl` and `equi`; CSLib's `Proposition` takes `imp` as primitive and derives negation and `⊤`. Adopting CSLib's type rewrites 4.4, 5.2, 5.3 and every exercise in the chapter; keeping both means maintaining a translation between them. Note that CSLib itself does not insist: its modal chapter declares its *own* `Proposition` rather than reusing the propositional one — precedent for `CSwL` keeping its own `Form` and instantiating the interfaces around it.
3. **CSLib's presentation is minimal logic**, with intuitionistic and classical strength added as *axioms of a theory* rather than as deduction rules. The module itself notes that this differs from most on-paper presentations, and the design is still under discussion upstream. It is a defensible formalisation and an odd first contact with natural deduction for a course that is not about proof theory.

Reasons 1 and 3 are about this book's audience and would not change if CSLib changed. Reason 2 is ours to remove, by taking `imp` as primitive in `Form`; that is the cheapest route into CSLib if the decision is ever reopened.

**What CSLib does not have, and what its house style already prescribes.** There is no semantics for propositional logic — no valuation, no truth tables, no soundness — and no first-order logic at all (`Cslib/Logics/` holds propositional, modal, HML and linear logic). So CSwFP/5.2, 5.3 and 5.5 have nothing to reuse, and the reuse question does not even arise for `FOL.lean`.

The *shape* such a semantics should take is not open, though. CSLib treats proof systems and semantics uniformly, both instantiating `InferenceSystem`, and the modal chapter is the worked example: `Satisfies m w φ` is an ordinary recursive function into `Prop`, bundled as a `Judgement` with `instance : HasInferenceSystem`, and the object/meta bridge is stated as theorems like

    Satisfies.and_iff_and : ⇓Modal[m,w ⊨ φ₁ ∧ φ₂] ↔ ⇓Modal[m,w ⊨ φ₁] ∧ ⇓Modal[m,w ⊨ φ₂]

which is exactly the bridge that `PL.lean` promises, in modal clothing.

Decision: `PL.lean` defines a plain `eval : Valuation → Form → Bool` and states the bridge as ordinary theorems, without the `Judgement` wrapper, the `HasInferenceSystem` instance or a `⇓LP[v ⊨ F]` notation. The course is not about Lean and introduces only what the material needs, and this is the reader's first logic chapter; library machinery there is machinery the book would have to explain. Adopting the shape later is mechanical — `Satisfies` is itself an ordinary recursive function, and the bundling is one structure, one instance and one notation on top of it, with nothing about `eval` changing. Packaging this chapter's semantics for CSLib is a separate deliverable from the book, and belongs in a separate module.

### Grammars: Mathlib's `ContextFreeGrammar`, deferred

`Games.lean` presents a BNF grammar for each game in prose, and then models it not as a grammar but as a handful of ordinary Lean types: enumerations for the terminal categories (`Colour`, `Answer`, `Column`, `Ship`), a `structure` for each rule with a fixed shape (`Turn`, `Attack`, `Move`), and `List`, `Vector` or a subtype where the BNF recurses or bounds a length (`abbrev Game := List Turn`, `abbrev Guess := Vector Colour 4`, `Reaction := { r : List Answer // r.length ≤ 4 }`).

This flattens the grammar. The BNF rule `game ::= turn | turn game` is recursive; `List Turn` is that recursion already collapsed, and nothing in the chapter connects the two — the correspondence between the displayed BNF and the types below it is asserted in prose and nowhere checked. Sea Battle then adds `inductive WellFormed : Game → Prop` by hand, which is a well-formedness judgement written out because the type alone does not carry it.

Mathlib has `Mathlib.Computability.ContextFreeGrammar`, which models the missing side:

- `ContextFreeRule T N` — `input : N`, `output : List (Symbol T N)`;
- `ContextFreeGrammar T` — a nonterminal type `NT`, an `initial : NT`, and `rules : Finset (ContextFreeRule T NT)`;
- `Produces` (one rewriting step), `Derives` (its reflexive-transitive closure), `Generates`, and `language : Language T`;
- `Language.IsContextFree`, with closure results such as closure under reversal.

The two are not the same object, and the difference is the point. An `inductive` type *is* the parse tree — this holds for `Form` in `PL.lean` and for the `Sent`/`NP`/`VP`/`RCN` fragment in `English.lean`, where a value is a derivation already built and there is no string. `ContextFreeGrammar` is about generating strings: `Derives` is a `Prop`-valued rewriting relation over `List (Symbol T NT)`, and `w ∈ g.language` says a word is generated.

So the library supplies exactly what neither encoding in the book states today:

- that a grammar *generates* a given sentence, as a theorem rather than as a `#eval` — and in `Games.lean` this is the missing link between the BNF in the prose and the types below it;
- derivation in the grammar sense, a sequence of rewriting steps, which is what a BNF actually describes and what `Derives` is. `SeaBattle.lean`'s hand-written `WellFormed` is a partial substitute for it;
- unique readability, which `PL.lean` gives up precisely because there is no string to disambiguate. Against a `ContextFreeGrammar` there is one again, and the claim recovers its content: that `toString` lands in the language, and is injective.

Deferred all the same, for now. Carrying both representations means giving each grammar twice, which is the duplication this book avoids; `Finset` rules and `Symbol T NT` are heavy machinery for the chapter right after the introduction to Lean; and proving `w ∈ g.language` for a concrete word means building `ReflTransGen` chains, which is real work with no payoff before CSwFP/6. Nothing in CSwFP/1–6 requires it, and the flattened types are what the rest of the chapter computes with.

Taken up after the pending work is done, the natural form is a closing section of `Games.lean` — one grammar given twice, as the flattened types the chapter computes with and as a `ContextFreeGrammar` value, with the bridge theorem between them — and a back-reference from `PL.lean`'s unique-readability discussion, which is the same question in a different chapter.

## Chapter by chapter

### 1. `IntroCS.lean` — CSwFP/1

Kept in the original presentation and section order. Sections 1.7 (Overview of the Book) and 1.8 (Further Reading) are omitted.

**The one exception to the constraint.** CSwFP/1 has no code; this chapter has some, and all of it uses Lean that `IntroL.lean` only presents later — `example … := by rfl`, a recursive definition matching on `0`/`n + 1`, an `inductive` with `deriving Repr`, and a proof by `induction … with` using `rw`. This is deliberate and stays: the code is there to provoke the reader's curiosity, showing at the outset what the book will be able to say precisely, and the reader is not expected to write it or to follow it in detail.

What makes the exception legitimate is that this chapter *presents* nothing. Every construct it displays is presented properly later, and the prose has to say so at the point where the code appears — that the code will be explained in the chapters that follow, and that reading it now is optional. Without that sentence the chapter is not a teaser, it is an unannounced prerequisite.

The exception is this chapter only, and only for code that presents nothing. It does not extend to later chapters: `Fin`, `Vector` and subtypes are covered by the loosening stated at the top of this document, and `instance` and `mutual` are introduced where the sections above say.

*Migration*: this chapter is to be rewritten as a faithful translation of CSwFP/1, section by section; the current file departs from the original's presentation and organisation. The code stays for now — it is illustrative, and the formalisations in it are slight — but it is not what the chapter is for, and the rewrite decides how much of it survives. Two things are needed either way: the framing sentence, which is not in the prose yet, and the replacement of the chapter's numeric cross-references.

### 2. `IntroL.lean` — CSwFP/3, plus 2.3, 2.4, 2.5

Presents Lean as a functional programming language. Translated aggressively, adapting to Lean style and primitives.

scope and order of presentations: terms, types, lambda and function definition, function composition, polymorphism, inductive types, `List`, `Nat`, recursion, `structure`, type classes, list processing (`map`, `foldl`, `foldr`, `filter`), strings, chars and slices. Only what the rest of the book actually uses.

- 3.1 and 3.2 merge into a single section about Lean.
- 3.12 (Identifiers in Haskell) and 3.15 (Further Reading) are omitted.
- 3.13 contributes inductive types and pattern matching; its `Subject`/ `Predicate` example is dropped here, because a fragment of natural language introduced this early collides with the fragments presented later. It is absorbed into `English.lean`.

**2.3, 2.4 and 2.5 live here.** CSwFP presents lambda calculus and types before the programming language, as preliminaries justifying a language the reader has not seen. With Lean already on screen the direction inverts: `#check fun x => x * x` exhibits the lambda abstraction of 2.4, `#check (Nat → Nat)` exhibits the type BNF `τ ::= b | (τ → τ)` of 2.5, and `#reduce` exhibits β-reduction happening. The chapter becomes the theory of what the reader has just written.

Two consequences of moving 2.3 here:

- CSwFP defines a *function as a special kind of relation* (2.3), so 2.3 depends on 2.2. In Lean `A → B` is primitive, so the definition is not needed to introduce functions. When relations arrive in `Sets.lean`, "a function is a functional relation" stops being a definition and becomes a statement to prove — new text that CSwFP does not have.
- The linguistic examples of 2.4 (lambda abstraction for word formation) and 2.5 are not presented here: word formation collides with `Morphology.lean`, and the natural-language semantics example is premature. They are in `English.lean`.
- One example had to change in the move. The demonstration of the typing rules read `opaque happy : Entity → Prop`, and `Entity` is declared in `Sets.lean`, which now comes after this chapter. It is `opaque restful : Day → Prop`, over the inductive this chapter declares itself.

**`instance` is presented here.** The chapter's "Classes de tipos" section shows type classes only from the *use* side — the `[BEq α]` in a signature, and the difference between `BEq` and `DecidableEq`. But instances are declared from `Logic.lean` onwards: `PL.lean` gives `ToString Form`, `FOL.lean` three more, and `English.lean` fifteen, all of them `ToString`. Declaring an instance is a small step from the section already there, and it is the last piece of type classes the book actually needs — no chapter declares a `class` of its own.

**`Prop` is presented here, minimally.** Not by choice: inductive types bring `deriving DecidableEq`, `decide` and `#check 1 = 1`, all of which display `Prop`. `Games/Mastermind.lean` already derives `DecidableEq` on `Colour` and `Answer` in its first code block, two chapters before any logic. The student sees `Prop` whether or not it is introduced. So the chapter presents proposition-as-type, proof-as-term, and `rfl`, `intro`, `exact`, `decide` — and leaves natural deduction and quantifiers to `Logic.lean`. Without this, `IntroL.lean`, `Morphology.lean` and `Games.lean` are `Bool` and `#eval` throughout, which is the original book with Lean as a costume.

2.6 (Functional Programming) exists in CSwFP to motivate its chapter 3 from its chapter 2 — "functional programming languages actually are lambda calculi". With the order inverted, that bridge is not needed and the section is absorbed.

2.7 (Further reading) is omitted.

### 3. `Morphology.lean` — CSwFP/3.11, 3.14

`Applications` is too vague a name; the chapter is about morphology. Section 3.11 is split into two sections, `FinnishVowelHarmony` and `SwedishPlural` (CSwFP covers Swedish plural inside 3.11, pp. 54–55). Section 3.14 becomes `Phonemes`.

A short introduction should note that although the book is not about morphology, these examples exercise the Lean concepts just learned.

*Migration*: check that every Lean feature used here was presented in `IntroL.lean`.

### 4. `Games.lean` — CSwFP/4.1, 5.1, 5.4

Syntax and semantics are presented one after the other for each game, instead of split across two chapters. CSwFP/4.1 carries the syntax of both games, so it is split between the two files.

- `SeaBattle.lean` — 4.1 (Sea Battle part) + 5.1. Verified free of logic: 5.1 is state-transition semantics.
- `Mastermind.lean` — 4.1 (Mastermind part) + the implementation half of 5.4 (`samepos`, `occurscount`, `reaction`, `updateMM`, `playMM`).

5.4 opens by announcing itself as an application of propositional logic, but the announcement is not kept: the propositional content is confined to about eighteen lines (the encoding paragraph, Exercise 5.14, and the remark that the secret pattern is *logically implied* by the rules plus the answers). Everything after that is list counting. So 5.4 splits:

- the implementation stays here;
- the opening sentence, the encoding paragraph and Exercise 5.14 move to `Logic.lean`. Exercise 5.13 stays (combinatorics, and it sets up the size of the search space that `updateMM` filters).

Splitting Mastermind bends the principle of keeping each game's syntax and semantics together, and the alternative that respects it is to move `Logic.lean` up, right after `IntroL.lean`. That alternative is rejected: it puts the two heaviest formal chapters back to back, before any linguistic payoff, for an audience that `IntroCS.lean` promised natural language to. The game keeps its syntax and its state semantics here; the propositional reading returns as commentary and exercises at the end of `PL.lean`, once the reader has the logic to state it.

The grammars here are flattened into ordinary types — enumerations, `structure`s, `List` and `Vector` — rather than given as values of Mathlib's `ContextFreeGrammar`; that is a decision, argued in "Reusing Mathlib and CSLib", and the one deferred item that would change this chapter once taken up.

**`Fin`, `Vector` and subtypes are introduced here, not in `IntroL.lean`.** They are Lean's own basic types, each needed by one grammar and nowhere else: `Fin 10` for a board row, `Vector Colour 4` for a guess of fixed length, and `{ r : List Answer // r.length ≤ 4 }` for a reaction of at most four pins. Each gets a short paragraph where it first appears, with a citation of the Lean Language Reference for the reader who wants more. `Fin` already has one; `Vector` and the subtype do not, and need it.

CSwFP writes 5.4 as an *echo* of 5.3 — "As in the case of propositional logic, we can now give a Mastermind update function" — the same list comprehension discarding states incompatible with new information. `CSwL` inverts the direction of the analogy: here `updateMM` stands on its own, and in `Logic.lean` the valuation `update` presents itself as having the shape of the `updateMM` the reader already knows.

### 5. `Logic.lean` — CSwFP/4.4–4.7, 5.2, 5.3, 5.5

Two files, `PL.lean` (propositional logic) and `FOL.lean` (predicate logic).

Doing logic in Lean is doing deduction — `intro` is →-introduction, `constructor` is ∧-introduction, `cases` on ∨ is ∨-elimination. CSwFP reaches deduction only in its inference engine (5.7); here it arrives with the logic itself. Deduction lives at the meta level, in `Prop` and the tactics.

The chapter could carry a third object: a proof system *as data*, an inductive of derivations `Γ ⊢ A` over `Form`. CSLib already has one, so leaving it out is a decision rather than an omission — argued in "Reusing Mathlib and CSLib" above, and revisited in "Beyond CSwFP/6".

**What is translated and what is written here.** Parts 2 and 3 below are
translations — CSwFP/4.4 for the syntax, 5.2 and 5.3 for the semantics — and
follow the original's structure. Parts 1 and 4 have no source: the first
condenses `logic_and_proof`, the second states a bridge the original cannot
state. Those two carry a structure of their own, and part 1's subheadings, one
per connective, are that structure — a connective's introduction and elimination
rules are what the section teaches.

**The chapter's opening example is not CSwFP's.** The potassium/chlorine
example that opens `PL.lean` — `K` for "traces of potassium were observed", `C`
for "the sample contained chlorine", and the four compound sentences built from
them — has no counterpart in CSwFP, whose chapter 4 opens with Sea Battle. It
is adapted from the opening of Enderton's *A Mathematical Introduction to
Logic*, and the prose cites it as such. Recorded here because the rest of parts
2 and 3 *are* translations, and a reader of this document checking coverage
would otherwise look for a source passage that does not exist.

Two divergences inside the translated part. CSwFP gives the semantics in two
sections, "Semantics of Propositional Logic" and "Propositional Reasoning in
Haskell"; here they are one, because the separation does not survive the move:
the definitions are already Lean from the first line, so there is no later point
at which implementation begins. And the discussion of what an empty conjunction
should be worth does not arise, since `top` and `bot` are constructors.

`PL.lean`, in this internal order:

1. **`Prop` and proof in Lean** — meta level. Tactics presented as the rules they are, building on the `rfl`/`intro`/`exact`/`decide` of `IntroL.lean`: `apply`; `constructor` and anonymous constructors for ∧ and ↔; `left`, `right` and `cases` for ∨; `False.elim` and `absurd` for ¬; `by_contra`, `by_cases` and `em` for classical reasoning.
2. **`Form` as syntax** — object level: BNF, `inductive Form` (4.4). Glued to it, the section that separates the two levels: `Form.conj p q` is data, `p ∧ q` is a proposition. Glued, not deferred to the end of the chapter — the confusion is born the instant the `inductive` appears. This is a cost Lean creates and Haskell does not have: there the meta level is invisible, living in the prose, so `data Form = ...` cannot be confused with it.
3. **Valuation** — 5.2 and 5.3: truth tables, consequence, `update` over valuations. Then Mastermind's propositional encoding, from 5.4.
4. **The bridge** — interpreting `Form` into `Prop` and proving `eval v F = true ↔ ⟦F⟧`. Where deduction and valuation meet. CSwFP cannot have this section.

The Mastermind closing section gains something the original cannot state: because the game is already implemented, there is a theorem to prove — that filtering by `reaction` and filtering by the formula yield the same set of states, i.e. that the propositional encoding is faithful to the implementation.

`FOL.lean` mirrors `PL.lean`'s order: the quantifier rules first — `intro`/`apply` for ∀, `use` and `obtain` for ∃ — then 4.5, 4.6, 4.7, then 5.5. Putting the tactics last would have made the two logic chapters teach the same thing in opposite positions, for no reason.

**`Formula` is binary too.** Its `conj` and `disj` take two arguments, with `top` and `bot` as constructors and `Formula.conjs`/`Formula.disjs` recovering the n-ary notation — the same design as `Form`, for the same reason. A constructor holding a `List (Formula α)` would make the type a nested inductive, costing `induction` and `deriving`. The `List α` in `atom name (args : List α)` does not: `α` is a parameter, not the type being defined, so an atom may still take any number of arguments. With that, the definition of truth in 5.5 is a plain recursion, one case per constructor, instead of three mutually recursive functions. The one `mutual` block left in the chapter belongs to `Term`, where a list of terms inside `Term` is what function symbols of arbitrary arity require.

**`mutual` is introduced here.** Its first use in the book's order is `FOL.lean`, and `English.lean` then uses it six times over for the fragment's mutually recursive categories. A note right after that first block — why a group of types that refer to one another has to be declared together, and what `mutual` therefore does — is enough; it does not need a section of its own, and it does not belong in `IntroL.lean`, where nothing would motivate it.

**What is taken from `logic_and_proof`.** Only the chapters that teach *proving in Lean*; the ones that present logic on paper are already CSwFP's job, and covering the same ground twice is exactly the duplication this book avoids. Reference: <https://leanprover-community.github.io/logic_and_proof/>.

| `logic_and_proof` chapter                   | Taken                                                                                |
|---------------------------------------------|--------------------------------------------------------------------------------------|
| `propositional_logic`                       | no — CSwFP/4.4 and 5.2 do this                                                       |
| `natural_deduction_for_propositional_logic` | the rule names only, to present each tactic as the rule it is                        |
| `propositional_logic_in_lean`               | yes, condensed — this is the core of `PL.lean`'s first section                       |
| `classical_reasoning`                       | yes — needed for the two-valued valuation of 5.2, and for `Sets.lean`'s Exercise 2.3 |
| `semantics_of_propositional_logic`          | no — CSwFP/5.2 and 5.3 do this                                                       |
| `first_order_logic`                         | no — CSwFP/4.5–4.7 do this                                                           |
| `natural_deduction_for_first_order_logic`   | the rule names only                                                                  |
| `first_order_logic_in_lean`                 | yes, condensed                                                                       |
| `semantics_of_first_order_logic`            | no — CSwFP/5.5 does this                                                             |

`sets_in_lean` and `relations_in_lean` are the corresponding reference for `Sets.lean`, not for this chapter.

**Representation note.** 5.5 is prose in CSwFP — a model is `M = (D, I)` with `I(P) = {1,3}` and `I(R) ⊆ D²`, and the text points back at the Cartesian product of 2.2. Mechanised here, before `Sets.lean` exists, the interpretation is represented by function types (`D → Prop`, `D → D → Prop`), which `IntroL.lean` already provides. This is also what CSwFP itself does once it writes code: `Model.hs` uses `type OnePlacePred = Entity -> Bool`. Mathlib's `Set` and `Rel` are deliberately *not* used here; they arrive in `Sets.lean`.

**Two syntactic results of 4.4 change content, not just position.** Structural induction is not a theorem to state — it is the recursor that `inductive` generates.

Unique readability is the other. In CSwFP it is a claim about *strings*: a formula written out as a sequence of symbols has exactly one parse tree, so the notation is unambiguous. In Lean there is no string to disambiguate — a term of type `Form` already *is* the tree, and `Form.conj p q` cannot be read two ways. The claim has nothing left to assert.

Decision: `PL.lean` does not state unique readability as a theorem. What it states instead is what survives the translation — that the constructors are injective and pairwise disjoint, provable by `injection`, which is what Exercise 4.11 already does. The prose says why the original statement dissolves: the ambiguity it rules out is a property of writing formulas down, and the type never writes them down. Recovering the original claim would take a string to disambiguate — either a parser `String → Option Form` with a round-trip theorem, or the grammar stated as a `ContextFreeGrammar` so that `toString` can be shown to land in its language and to be injective. Both are deferred for the same reason: parsing and grammars-as-data are topics of their own, and nothing before CSwFP/6 needs either. See "Reusing Mathlib and CSLib"; it is the same question this chapter and `Games.lean` both run into.

### 6. `Sets.lean` — CSwFP/2.1, 2.2

What is left of CSwFP/2 after 2.3, 2.4 and 2.5 moved to `IntroL.lean` and `English.lean`: sets and relations. Renamed from `Foundation.lean`, which promised a foundations chapter that no longer exists. `Sets` covers both halves honestly, because CSwFP/2.2 *defines* a relation as a subset of A × B — a relation is a set — and because what the chapter adds in Lean is precisely the representation choice for `Set α`.

**What the chapter is.** Sets and relations are presupposed notation from CSwFP/1 onwards, as in any mathematical text — which is why 5.5 can speak of `I(R) ⊆ D²` before this chapter exists. This chapter is where they are *mechanised in Lean*, and its opening has to say so, or it promises the wrong thing. That is also what makes it worth having: Lean forces representation choices — `Set α` vs. the predicate `α → Bool` vs. `Finset`, `Rel` vs. a list of pairs, decidability — and those choices determine how the models of `ModelChecking.lean` are built.

**Why after `Logic.lean`.** Nothing downstream requires this chapter — no later chapter fails to compile without it — but the chapter itself requires `Logic.lean`, and that is what fixes its position. Both reasons are about the exercises:

- The chapter's point in Lean is *proving* theorems about sets and relations, which needs quantifiers and the connective tactics. `IntroL.lean`'s minimal `Prop` does not reach them; `Logic.lean` does.
- CSwFP's Exercise 2.3 is "check that A̿ = A". In Lean one direction requires classical reasoning (`¬¬P → P` does not hold constructively). Placed early, the third exercise of the book would force a conversation about the nature of negation before any truth table exists. After `Logic.lean`, `by_contra` and `em` are already presented and the exercise is routine.

`Logic.lean` must therefore not use `Set` or `Rel` — see the representation note above.

From the `logic_and_proof`, the chapters `sets_in_lean` and `relations_in_lean` can give some exercises or ideas on how to present sets and relations in Lean.

### 7. `InfEngine.lean` — CSwFP/4.3, 5.7

The language for talking about classes (4.3) and the inference engine over it (5.7), together instead of split across two chapters.

4.3 is literally about classes, which is what makes it the chapter immediately after the one that mechanises them:

| 4.3 fragment         | 2.1 vocabulary |
|----------------------|----------------|
| `All PN are PN`      | `A ⊆ B`        |
| `No PN are PN`       | `A ∩ B = ∅`    |
| `Some PN are PN`     | `A ∩ B ≠ ∅`    |
| `Some PN are not PN` | `A \ B ≠ ∅`    |

CSwFP's `derive kb stmt` is proof search over syllogisms. Read as deduction over set inclusion, the validity of the syllogisms becomes provable in Lean — where CSwFP can only implement and test it.

This chapter is independent of the English fragment: `InfEngine.hs` imports nothing from the syntax module.

**What is translated and what is written here.** CSwFP/4.3 and the theory in 5.7 — Aristotle, the square of opposition, the knowledge base as inclusion and non-inclusion, the inference rules — are translated, and so is the engine: `rSection`, relational composition, the reflexive-transitive closure, `subsetRel`, `nsubsetRel`, `derive` and `tellAbout`. The closing section, which proves the syllogisms valid over `Set`, has no source: it is the payoff the plan promises, and the reason the chapter sits after `Sets.lean`.

Three divergences. The least fixed point is computed with a fuel bound rather than by iterating until the value stops changing, because the latter has no structural termination argument; the bound is the square of the domain size, which is beyond what the closure can need. Relations are `List (α × α)`, named `Relation` rather than `Rel`, so that Mathlib's `Rel` — which `Sets.lean` introduces and this chapter's closing section uses through `Set` — keeps its name. And CSwFP/5.7's natural-language *input* is not ported: the parser, the file I/O and the `chat` loop are the only place in the book that would need `IO`, and the chapter states its interface through `ToString` on `Statement`, which is the output half.

### 8. `English.lean` — CSwFP/4.2, 5.6

The fragment of English (4.2) and its semantics (5.6), plus the natural-language fragments that CSwFP scatters earlier and that `CSwL` deliberately does not present in place: the `likes` example of 2.4, the `S → NP VP` of 2.5, and the `Subject`/`Predicate` example of 3.13. CSwFP introduces a slightly larger grammar in 4.2 and then, in 5.6, sketches the semantics of an initial vocabulary largely disconnected from it. Gathering these fragments in one place is the point of this chapter.

**What this chapter must deliver to `ModelChecking.lean`.** Gathering the fragments is the editorial goal, but the chapter also has a hard obligation: CSwFP/6 translates the 4.2 grammar category by category, so every category it destructures has to exist by the end of this chapter. `MCWPL.hs` defines one translation function per category — `lfSent`, `lfNP`, `lfDET`, `lfCN`, `lfRCN`, `lfVP`, `lfTV`, `lfDV` — so the required inventory is:

`Sent`, `NP`, `DET`, `CN`, `RCN`, `VP`, `TV`, `DV`, plus the auxiliaries `ADJ` and `That` that `RCN` uses.

**Semantic types are named `e` and `t`, and that is not cosmetic.** The categorial section that arrived from CSwFP/2.5 originally wrote the semantic types as `NP`, `S`, `VP` and `TV` — the category names. In this chapter those names are already taken, by the `inductive`s that *are* the fragment's syntactic categories: two meanings for one name in one namespace, which does not compile and would not be worth compiling. The types now carry Montague's letters, `e` for entities and `t` for truth values, which the prose was already naming as the conventional choice; the categories keep `NP`/`VP` where they belong, in the prose. So "the VP has type `e → t`" now says two different things with two different notations, which is exactly the distinction the section is about.

`INF` is part of the 4.2 grammar but has no translation in CSwFP/6; it is not required by `ModelChecking.lean`.

### 9. `ModelChecking.lean` — CSwFP/6

Sections 6.1–6.5; 6.6 (Further Reading) omitted.

**This chapter must come after `English.lean`.** CSwFP/6 does not merely allude to the fragment of 4.2 — it is built on it. The text says so ("to translate the fragment from Section 4.2 into predicate logic, all we have to do is find appropriate translations for all the categories in the grammar"), and the code confirms it: `MCWPL.hs` imports the syntax module and its first definition is `lfSent :: Sent -> LF`, destructuring `Sent np vp`. Placing the English fragment after model checking would use the grammar before presenting it.

This is also why `Sets.lean` reads best just before it, though it is not required: `Model.hs` builds the model with `OnePlacePred = Entity -> Bool` and `list2OnePlacePred xs = \x -> elem x xs` — the characteristic function of 2.3 and the set-as-predicate of 2.1, applied. The choice between `Set Entity` and `Entity → Bool` is exactly the one `Sets.lean` makes.

## Omitted throughout

All "Further Reading" sections (1.8, 2.7, 3.15, 4.8, 5.8, 6.6), 1.7 (Overview of the Book), and 3.12 (Identifiers in Haskell).

## Beyond CSwFP/6

Everything above is settled and covers CSwFP/1 to CSwFP/6. The rest of the book is deferred, and the placements below are provisional, not decisions.

CSwFP/7 (The Composition of Meaning in Natural Language) goes after `ModelChecking.lean`. It continues `English.lean`'s fragment and, in CSwFP, builds on the same syntax module, so the same constraint that puts `English.lean` before `ModelChecking.lean` keeps 7 downstream of both. How much of `English.lean` it absorbs — CSwFP/7 is where a consolidated semantics of a natural-language fragment actually appears — is the question to settle when that chapter is taken up.

A proof system as data — CSLib's `Cslib.Logic.PL.Theory.Derivation` — is deferred rather than rejected, for the reasons in the `Logic.lean` section. It becomes attractive exactly where `CSwL` would have something to give back: CSLib has the derivations but no propositional semantics, and this book builds the valuation. Soundness — every derivable sequent is true under every valuation satisfying its context — needs both halves, and neither project has both today. `Cslib/Logics/README.md` invites exactly this ("we are interested in expanding them or creating new ones that can cover your use cases"). Its natural place is after `Sets.lean`, once relations and quantifiers are available. It stays out of the plan until CSwFP/1–6 are in place.

Mathlib's `ContextFreeGrammar` for the grammars of `Games.lean` is deferred on the same footing, and for reasons that are ours rather than the library's — see "Reusing Mathlib and CSLib". It is the one deferred item that would change a chapter already written, so it belongs after the pending work in `TODO.md`, not before it.

The related question — whether `PL.lean`'s valuation is written in CSLib's shape from the start — is settled above, and settled against it.

Chapters 8 onwards are not planned yet.

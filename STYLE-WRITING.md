# CSwL Writing Style Guide

This file records the conventions for the book's prose: pedagogy,
presentation, and the Portuguese it is written in. `STYLE-CODE.md` covers Lean
code and Verso markup; `CONTRIBUTING.md` covers workflow.

The book's prose is in Portuguese. This guide, like every other document about
the project, is in English — the rule is about the medium, not the audience.

## Pedagogical decisions

These are the project's standing decisions about how material is presented.

**Avoid fragmented presentation.** A topic is developed in one place, as far
as the material allows. This is the reason the book largely reorders its
source: a presentation that is natural in Lean is not the one the source
needed.

**Do not present a definition that a later chapter will rephrase under the
same name.** Namespaces would keep such a pair compiling, but the reader is
not a compiler and will read the second definition as a correction of the
first. Exceptions happen; they should be deliberate and visible.

**Never discuss the book's sources or alternatives in the prose.** The reader
has not read the book this one adapts and does not need to know Haskell. The
book is self-contained: it never names sections, pages, or exercises of
another work, and it never explains itself by contrast with one.

`DEVIATIONS.md` draws the line precisely, and that discussion is not repeated
here: a **technical consequence in Lean** is content, because the reader will
meet it; an **editorial preference** is meta, and belongs in `DEVIATIONS.md`.
The test is whether the sentence would still be worth writing if this book had
no source and no alternatives.

**The course is not about Lean.** Lean is introduced as far as the semantics
needs it and no further. A feature that earns no work in a later chapter does
not need a section.

**Exercises should not be load-bearing.** Prefer exercises whose solutions are
not required by later presentations; a reader who skips one, or gets it wrong,
should not be locked out of the next chapter.

**Prefer naming a chapter over naming a position.** "O capítulo anterior",
"mais adiante", "já vimos" are true only of one arrangement, and material
moves between chapters — that is why nothing in this book is numbered. A
`{ref "Tag"}[…]` survives a reorder; "the previous chapter" silently becomes
false.

Where a positional phrase is genuinely the clearest thing to write, it is a
liability to be repaid: **after moving any chapter or section, sweep for the
prose the move invalidated.** The search that has caught them so far:

```
capítulo anterior | capítulos anteriores | próximo capítulo |
no capítulo seguinte | adiante | mais adiante | já vimos | vimos no | visto no
```

plus every `{ref "…"}`, whose target still resolves but may now be so far away
that the sentence around it stops making sense.

## Writing advice

This section adapts the guidance developed for SF-in-Lean, whose exercise-led
structure this book follows. It is about how to write a section, not about
what the project has decided.

**Imagine your audience.** What do the students know before this course? They
arrive by different paths. What do they know *so far in this book*, at the
point you are writing? Use concepts they have; do not use terms they have not
met. Do not re-explain what they know well — but do remind them of something
introduced a while back, because they will have forgotten it.

**Context, Gap, Solution.** Readers want to know why they are reading
something. They will suspend impatience, but not for long. Three parts: what
do we want to do, what stops us, what do we do about it.

Two near-misses to watch for. The problem may be stated too big, so the path
to the solution is long and its rightness is not obvious — break it into
smaller problems, each with the three parts. Or the solution may not
obviously match the problem, appearing to do more than was asked — then either
simplify it or explain the excess.

**Start from something specific the reader knows; work toward the general.**
You begin on the same page as the reader and make small deltas before the
bigger leaps. Use good examples, simple before general.

**Minimize complexity.** Ask what would make this simpler. Reuse an example
rather than introducing a new one. Prefer a multi-step development where the
concerns separate. Avoid an expert-level solution that solves problems you do
not want to explain yet.

**Do not forget exercises.** This book's signature is that each interesting
concept comes with something to do. An explanation plus an example can often
become an explanation plus an exercise.

**Cutting is good.** Material grows and the temptation is to keep everything.
Ask: does this serve the goal, does the audience need it? If some readers
would benefit but not all, a `:::details` block or an appendix will hold it.

## Portuguese conventions

The book is in Brazilian Portuguese.

Where AI is used to translate, the translation is as literal as the target
language allows, produced as a draft for a human to revise. Prose is never
invented, expanded, or restructured on the AI's initiative — see `CLAUDE.md`.
The failure mode this section guards against is the systematic one: a
translation that is fluent, plausible, and consistently wrong about a term.

### Terms

The preferred form, then the form to avoid. This list is short on purpose: it
records decisions actually taken, not a vocabulary invented in advance.
Prescribing a term the book has never used, against an alternative it has
never used, is the same failure this section exists to catch. Add an entry
when a bad translation is found and corrected.

The chapters are already consistent on their main terms — "tática",
"tipo indutivo", "hipótese de indução", "predicado" — and those need no
entry until something contradicts them. What the sweep found instead:

- "supor" / "assumir" (in the sense of English *to assume*; the Portuguese
  verb means *to take on*, and the false friend is the commonest
  translation error in this material)
- "avaliar" / "rodar" (for `#eval`)

### Code and prose

Lean identifiers, keywords, and literal values keep their Lean spelling and go
in code font: write `true` and `false`, not "verdadeiro" and "falso", when the
term is the Lean value. Use the Portuguese words when the sense is the
ordinary one — a proposition is *verdadeira*, a `Bool` is `true`.

Keep a term's translation stable across the whole book. A concept that
acquires a second name in a later chapter reads as a second concept.

### Punctuation and typography

- Em dashes for parenthetical breaks, spaced as the surrounding prose does.
- Portuguese quotation marks or straight quotes, consistently within a file.
- Lean code in prose always in code font, never italicized.
- Every sentence starts with a capital letter. If a sentence would open with a
  lowercase Lean identifier, rephrase it — `Nat.add` may open a sentence,
  `omega` may not.

## Informal proofs

The book uses informal proofs sparingly: to teach a reasoning principle in the
abstract, as opposed to a Lean tactic. When one appears, it ends with *QED*.

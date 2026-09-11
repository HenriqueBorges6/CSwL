
# Project Goal

Port the CSwFP (Computational Semantics with Functional Programming) to Lean. 

The Haskell source files from CSwFP and the book PDF come from https://staff.fnwi.uva.nl/d.j.n.vaneijck2/cs/.

The repo lives at https://github.com/cslib-community/CSwL.

We want to reuse Mathlib and CSLib as much as possible.

We want to explore Lean's richer expressiveness compared to Haskell as much as possible. But always considering the possible risks for the next chapters. 

If an exercise in prose from CSwFP could be translated into code or proof, CLAUDE needs to propose it. It is better to avoid exercises whose solutions will be used/demanded in the rest of the book; exercise solutions should not be needed for later presentations. Exercises should be translate to the approach used in sf-in-lean.

The course is not about Lean; we will introduce Lean as much as necessary. In the same way, the authors of CSwFP introduced Haskell. We may cite further references 

- https://github.com/lean-forward/logical_verification_2026/

- https://lean-lang.org/functional_programming_in_lean/

- https://github.com/sorrachai/FAA2025

- https://leanprover-community.github.io/logic_and_proof/

# Format

We will use https://verso.lean-lang.org and follow, as closely as possible, the ideas from https://github.com/plclub/sf-in-lean.

We will also follow the ideas on how to use verso from https://lean-lang.org/functional_programming_in_lean/.

We will not name files or sections with numbers, precisely because during the project we need to reorder sections and eventually move them between chapters. We will always use acronyms for exercise identifiers, file names, and section identifiers. CLAUDE may suggest, and humans need to accept. 

We still need to investigate the auto-grading approach.

Using Verso, we could also create slides; see https://github.com/arademaker/sviL-hackathon-2026. But we will not use this resource now. Students are intended to read the book online. From the student variant, we will make the HTML and Lean Source available at https://github.com/emap-nlp/book. During class, the instructor will open the Lean code for the `terse` variant in VS Code; the class will use this material.

# English vs Portuguese 

The textbook will be written in Portuguese. Later, we plan to translate it back into English. 

But all names in the Lean code are in English; comments in the Lean code are also in English. This applies to the code presented to the students and also the code of the project itself, the Lean code that produces the book (verso extensions, infrastructure, etc)

The repo README is in English. All documentation *about* the project should be in English. Use English for git commit messages as well.

# Git and GitHub

Always try to follow [Conventional Commits](https://www.conventionalcommits.org/pt-br/v1.0.0-beta.4/)
for commit messages (e.g., `feat: ...`, `fix: ...`, `docs: ...`, `refactor: ...`,
with an optional scope like `docs(readme): ...`).

All commit messages need to be revised by a human before being accepted for use in a new commit.

We will use GitHub issues to track pending issues.

Never write local absolute filesystem paths (e.g. `/Users/ar/r/sf-in-lean/...`) into any versioned file — comments, docstrings, README/DEVIATIONS prose, this file included. Use a relative/bare reference instead (e.g. `sf-in-lean/SFLMeta/Run.lean`). `CSwL` is a public repo distributed to students; an absolute path leaks the professor's local machine layout for no benefit.

Where each of the resources above is cloned on this machine is recorded in `CLAUDE.local.md`, which `.gitignore` keeps out of the repository and Claude Code loads alongside this file every session.

# AI usage

AI-usage disclosure paragraph at the end of commit messages is important whenever AI was used. CLAUDE needs to advise on it and ask a human to confirm whether to add the disclosure. Never use `Co-Authored-By: Claude ...`, but use a paragraph with a disclaimer when approved by a human. The disclosure paragraph need to be written in English.

When migrating material, AI should try to translate (English to Portuguese) but not rewrite or invent new text. Only humans should deviate from the original CSwFP texts.


# Style guides

The normative conventions live in two files, which are to be read in addition
to this one. **Read both in full before creating or editing any file that ends
up in the book**; everything you write must conform to them.

- `STYLE-CODE.md` — Lean code and Verso markup: the ledger of which Lean
  feature is first used in which chapter (the book's hard constraint is that
  nothing is used before it is presented), the directive vocabulary, the build
  variants, and naming.
- `STYLE-WRITING.md` — prose: the project's pedagogical decisions, writing
  advice, and the Portuguese conventions including the term list.

`CONTRIBUTING.md` covers workflow. `DEVIATIONS.md` records what departs from
CSwFP and why. In case of conflict, the style guides win on style and this
file wins on project scope.


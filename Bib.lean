import VersoManual

open Verso.Genre.Manual

/-!
Citing uses `{citep Bib.key}[]` or `{citet Bib.key}[]`, and a missing key
becomes a compile error instead of a dangling `[Key]` in the text.

Verso offers four citable types (`VersoManual/Bibliography.lean`):
`InProceedings`, `Thesis`, `ArXiv`, and `Article`. There is no type for
`@book` or `@unpublished`, so entries that are not articles are entered as
`Article` with the `journal` field used for the publisher or the nature of
the text — the same convention as `sf-in-lean/Bib.lean`, which records books
(Pierce, Harper, Nipkow) this way.
-/

namespace Bib

def logicandproof : Article where
  title  := inlines!"Logic and Proof"
  authors := #[inlines!"Jeremy Avigad", inlines!"Joseph Hua",
               inlines!"Robert Y. Lewis",  inlines!"Floris van Doorn"]
  journal := inlines!""
  year := 2017
  month := none
  volume := inlines!""
  number := inlines!""
  url := "https://leanprover-community.github.io/logic_and_proof/"

def beesley2003 : Article where
  title   := inlines!"Finite State Morphology"
  authors := #[inlines!"Kenneth R. Beesley", inlines!"Lauri Karttunen"]
  journal := inlines!"CSLI Publications"
  year    := 2003
  month   := none
  volume  := inlines!"18"
  number  := inlines!""

def love2026 : Article where
  title   := inlines!"The Hitchhiker's Guide to Logical Verification"
  authors := #[inlines!"Anne Baanen", inlines!"Alexander Bentkamp",
               inlines!"Jasmin Blanchette", inlines!"Xavier Généreux",
               inlines!"Johannes Hölzl", inlines!"Jannis Limperg"]
  journal := inlines!"Manuscrito não publicado, edição de 2026"
  year    := 2026
  month   := none
  volume  := inlines!""
  number  := inlines!""
  url     := "https://github.com/lean-forward/logical_verification_2026"

def FPiL : Article where
  title   := inlines!"Functional Programming in Lean"
  authors := #[inlines!"David Thrane Christiansen"]
  journal := inlines!"Manuscrito não publicado"
  year    := 2023
  month   := none
  volume  := inlines!""
  number  := inlines!""
  url     := "https://lean-lang.org/functional_programming_in_lean/"

def LLR : Article where
  title   := inlines!"The Lean Language Reference"
  authors := #[inlines!"Lean FRO"]
  journal := inlines!"Manuscrito não publicado"
  year    := 2026
  month   := none
  volume  := inlines!""
  number  := inlines!""
  url     := "https://lean-lang.org/doc/reference/latest/"

def grice1975 : Article where
  title   := inlines!"Logic and Conversation"
  authors := #[inlines!"H. Paul Grice"]
  journal := inlines!"Syntax and Semantics, Vol. 3: Speech Acts (P. Cole e J. Morgan, eds.), Academic Press, p. 41–58"
  year    := 1975
  month   := none
  volume  := inlines!"3"
  number  := inlines!""

def montague1974 : Article where
  title   := inlines!"Formal Philosophy: Selected Papers of Richard Montague"
  authors := #[inlines!"Richard Montague"]
  journal := inlines!"Editado por Richmond H. Thomason. Yale University Press, New Haven"
  year    := 1974
  month   := none
  volume  := inlines!""
  number  := inlines!""

def keller1902 : Article where
  title   := inlines!"The Story of My Life"
  authors := #[inlines!"Helen Keller"]
  journal := inlines!"Doubleday, Page & Co., Nova York"
  year    := 1902
  month   := none
  volume  := inlines!""
  number  := inlines!""

def enderton2001 : Article where
  title   := inlines!"A Mathematical Introduction to Logic"
  authors := #[inlines!"Herbert B. Enderton"]
  journal := inlines!"2ª edição. Harcourt/Academic Press, San Diego"
  year    := 2001
  month   := none
  volume  := inlines!""
  number  := inlines!""

def FAA2025 : Article where
  title   := inlines!"Formalizing Analysis of Algorithms, Autumn 2025"
  authors := #[inlines!"Sorrachai Yingchareonthawornchai"]
  journal := inlines!"Manuscrito não publicado"
  year    := 2025
  month   := none
  volume  := inlines!""
  number  := inlines!""
  url     := "https://github.com/sorrachai/FAA2025"

end Bib

-- Adapted from sf-in-lean/SFLMeta/Comment.lean
-- (namespace SFLMeta -> CSwLMeta; `SFLMeta.Ignore`/`SFLMeta.Details` imports
-- dropped -- nothing in `Comment.lean` uses them, they are inherited out of
-- habit from neighboring modules in sf-in-lean). Only one thing from this
-- file is ported: the `:::dev`/`Block.devcomment` directive. Used here to
-- mark deviations from CSwFP's presentation (not for the course's own
-- development notes).
import VersoManual
import CSwLMeta.Variant

open Lean Elab
open Verso
open Verso.Doc Elab
open Verso.ArgParse

namespace CSwLMeta

/-- The three urgency keywords a `:::dev` note may carry, in canonical spelling.
Any other urgency is rejected as an error by the directive's argument parser. -/
def devUrgencies : List String := ["NOW", "BeforeNextRelease", "PotentialImprovement"]

/-- Canonicalize a `:::dev` urgency keyword, recognized case-insensitively:
`NOW`, `BeforeNextRelease`, `PotentialImprovement` (in any case) map to their
canonical spelling; every other keyword yields `none` (an error at parse time). -/
def canonUrgency? (s : String) : Option String :=
  match s.toUpper with
  | "NOW" => some "NOW"
  | "BEFORENEXTRELEASE" => some "BeforeNextRelease"
  | "POTENTIALIMPROVEMENT" => some "PotentialImprovement"
  | _ => none

/-- Author-facing configuration for `:::dev`.  All fields are optional; author
and urgency are positional and year is named:  `:::dev`,
`:::dev "Alexandre Rademaker"`, `:::dev BeforeNextRelease`, and
`:::dev "Alexandre Rademaker" PotentialImprovement (year := 2026)` are all
valid. The two positionals cannot be confused: an author is always a *string
literal* (it contains spaces) while an urgency keyword is always a bare
identifier, and the parsers accept only their own category. -/
structure DevConfig where
  /-- Who filed the note. -/
  author : Option String
  /-- An urgency keyword — one of `NOW`, `BeforeNextRelease`, or
  `PotentialImprovement` (recognized in any case), written as a bare identifier
  and stored canonicalized. -/
  urgency : Option String
  /-- The year the note was filed. -/
  year : Option Nat
deriving Repr

section
variable [Monad m] [MonadError m]

/-- Argument parser for `DevConfig`: optional positional author (a string) and
urgency (an identifier, validated/canonicalized later by the `dev` expander via
`canonUrgency?`), and an optional named year. -/
def DevConfig.parse : ArgParse m DevConfig :=
  DevConfig.mk
    <$> ((some <$> ArgParse.positional `author ValDesc.string) <|> Pure.pure none)
    <*> ((some <$> (fun (id : Ident) => id.getId.toString) <$>
          ArgParse.positional `urgency ValDesc.ident) <|> Pure.pure none)
    <*> ArgParse.named `year .nat true

instance : FromArgs DevConfig m := ⟨DevConfig.parse⟩

end

/-- Decode a `Block.devcomment` payload `(author, urgency, year)`. -/
def decodeDevData? (data : Json) : Option (Option String × Option String × Option Nat) :=
  match data with
  | .arr #[a, u, y] =>
    let str? : Json → Option String
      | .str s => some s
      | _ => none
    let nat? : Json → Option Nat
      | .num n => some n.toFloat.toUInt32.toNat
      | _ => none
    some (str? a, str? u, nat? y)
  | _ => none

/-- Should a dev note be rendered at all, in the variants that keep it (every
one but `student`)?  Only *actionable* notes are: those with urgency `NOW` or
`BeforeNextRelease`, or with no urgency at all.  `PotentialImprovement` notes
remain suppressed.

This is the second of two filters and is about urgency alone; which variants
keep a note is decided in `Block.devcomment`'s `traverse`. -/
def devNoteShown (urgency : Option String) : Bool :=
  match urgency with
  | none => true
  | some u => u == "NOW" || u == "BeforeNextRelease"

/-- Render an urgency keyword for a note label: the multi-word canonical
spellings are spelled out with spaces (`BeforeNextRelease` → `before next
release`), `NOW` is left as is. -/
def devUrgencyText (urgency : String) : String :=
  match urgency with
  | "BeforeNextRelease" => "before next release"
  | "PotentialImprovement" => "potential improvement"
  | u => u

/-- Label for a rendered dev note —
`Nota editorial (Alexandre Rademaker, before next release, 2026)` — with
absent fields omitted.  The heading names the note without naming the source
this book adapts, since `CSwL` is self-contained: the note does not reach the
student build, but it does reach the `terse` one the instructor opens in
class. -/
def devNoteLabel (author urgency : Option String) (year : Option Nat)
    (heading : String := "Nota editorial") : String :=
  let fields := author.toList ++ (urgency.map devUrgencyText).toList ++ (year.map toString).toList
  if fields.isEmpty then heading
  else s!"{heading} ({String.intercalate ", " fields})"

/-! `Block.devcomment` carries the note body as its children and records its
author/urgency metadata in `data`.

A dev note is addressed to the book's authors, so **no note survives traversal
in the `student` variant** — neither the HTML nor the generated `.lean`, since
both are produced from the per-variant traversed tree. The other three
variants keep every note: `solutions` and `grading` are the authors' own, and
`terse` is the instructor's, where a note on screen during a class is
harmless.

Among the surviving blocks, a note is rendered only when its urgency passes
`devNoteShown` (`NOW`, `BeforeNextRelease`, or none): highlighted in the HTML
book, and passed through as a labelled comment in generated `.lean` files by
`CSwLMeta.Save.Extract.walkBlock`.  `PotentialImprovement` notes render
nothing. -/
block_extension Block.devcomment (author : Option String)
    (urgency : Option String) (year : Option Nat) where
  data := Json.arr #[toJson author, toJson urgency, toJson year]
  traverse _ _ _ := do
    if (← getCurrVariant).isStudent then
      -- Dev notes are for the authors; the student build gets none of them.
      return some (.concat #[])
    else
      return none
  toHtml :=
    open Verso.Output.Html in
    some fun _ goB _ data contents => do
      let some (author, urgency, year) := decodeDevData? data
        | pure .empty
      if devNoteShown urgency then
        let body : Verso.Output.Html ← contents.foldlM (init := .empty) fun acc b =>
          return acc ++ (← goB b)
        return {{
          <div class="cswl-dev-note">
            <div class="cswl-dev-note-label">{{devNoteLabel author urgency year}}</div>
            {{body}}
          </div>
        }}
      else
        pure .empty
  toTeX := none
  extraCss := [
r##"
div.cswl-dev-note {
  margin: 1em 0;
  padding: 0.5em 0.9em;
  border: 1px solid #e6a700;
  border-left: 6px solid #e6a700;
  background: #fff3b0;
  border-radius: 3px;
}
div.cswl-dev-note > .cswl-dev-note-label {
  font-family: var(--verso-structure-font-family);
  font-weight: 700;
  font-size: 0.85em;
  letter-spacing: 0.03em;
  color: #7a5800;
  margin-bottom: 0.3em;
}
"##
  ]

/-- A `:::dev` directive marks a deviation from the CSwFP presentation. It
accepts optional positional author and urgency arguments and an optional named
year, e.g. `:::dev "Alexandre Rademaker" BeforeNextRelease (year := 2026)`; all
are recorded in the block's data, and the body is elaborated and kept as the
block's children.  Whether anything is *rendered* is decided per-note by
`devNoteShown` (only `NOW`, `BeforeNextRelease`, or urgency-free notes
surface). NB: since the body elaborates, a ` ```lean ` fence inside a dev note
runs the Lean code — use a plain ` ``` ` fence for code that must stay inert. -/
@[directive]
def dev : DirectiveExpanderOf DevConfig
  | cfg, contents => do
    let author ← match cfg.author with
      | some a => ``(some $(quote a))
      | none => ``(none)
    let urgency ← match cfg.urgency with
      | some u =>
        match canonUrgency? u with
        | some c => ``(some $(quote c))
        | none =>
          throwError m!"Unknown :::dev urgency '{u}'; expected one of {devUrgencies}"
      | none => ``(none)
    let year ← match cfg.year with
      | some y => ``(some $(quote y))
      | none => ``(none)
    let blocks ← contents.mapM elabBlock
    ``(Verso.Doc.Block.other (CSwLMeta.Block.devcomment $author $urgency $year)
        #[$blocks,*])

end CSwLMeta

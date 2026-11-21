/-
========================================================================
SUN
========================================================================

Sun.lean
Sun: 72 Poems for the Solar Eclipse of August 12th 2026
After the glossematic and acoustic architecture of https://bergholt.net/sun
A Lean 4 realisation of sun.pl (github.com/bergholt/triptych, MIT license).

Plain Lean 4 core. No Mathlib, no Lake project: one file.

RUN    : lean --run Sun.lean                  (Saros edition, the default)
         lean --run Sun.lean glossematic      (or: manifestations, saros,
                                               mutation, sounding)
WEB    : in live.lean-lang.org nothing runs `main` by itself, so the last
         line of this file is  #eval discard (main [])  which prints the
         Saros edition in the infoview. For another edition write e.g.
           #eval discard (main ["sounding"])
CHECK  : lean Sun.lean                       (elaborates the file; every
                                               self_check claim is a theorem
                                               and must be proved to compile)
QUERY  : add lines such as these at the end of the file, or in an editor:
           #eval Sun.poem 48                  -- some "now, apertures emerge"
           #eval Sun.poemsOf "now, apertures emerge"          -- [48]
           #eval Sun.selection 48
           #eval Sun.commutation .noun 48     -- [(60, ..), (72, ..)]
           #eval Sun.permutation 48           -- [(12, "prefix", "suffix")]
           #eval Sun.mutations 48
           #eval Sun.Category.all.map fun c => (c, Sun.stride c, Sun.characteristicInterval c)
           #eval Sun.spectrum "now"           -- [(2, 1), (3, 1), (11, 1)]
           #eval Sun.fundamentalFree          -- ["thicken", "now"]
           #eval Sun.sounding 48
           #eval Sun.ordinals.filter Sun.deictic

Translation notes.
  Prolog is relational: one predicate answers in several directions. Lean
  is functional, so each direction the Prolog file uses is written out:
  `selection` decodes an ordinal, `encode` goes the other way, `cells`
  enumerates the grid, `poemsOf` runs a poem backwards to its ordinal.
  Both directions share one stride formula, as in sun.pl, and a theorem
  holds them to each other.

  sun.pl's `self_check/0` throws at run time if the edition drifts from
  the numbers the work claims. Here the same checks are Boolean functions,
  and each one is also stated as a theorem, so a file that no longer
  satisfies them does not compile. `main` runs them again before printing.
  The theorems are decided by evaluation (`decide +native`), which trusts
  Lean's compiler in the same way the Prolog checks trust the Prolog
  engine.

  Prolog atoms become strings for the words of the poem, so that the
  sounding rule can read their letters, and inductive types for the
  closed vocabularies around them (categories, eclipse types, registers).
  Gamma is stored as an integer in ten-thousandths (-1.5356 is -15356),
  which is exactly the precision the Prolog table and its printer use.

  The inventory order is part of the artwork: changing it changes eclipse
  assignments. Everything numerical about the edition (strides, intervals,
  counts, spectra) is derived from the inventory and the Saros table, and
  the checks then hold the derived values to the ones the work asserts.
  Astronomical data and the epigraph are retained from the original; the
  checks validate structure, not external accuracy. ASCII output; dates
  use the original Julian/Gregorian catalogue convention.

Two findings the sounding rule yields that the essay does not state:
  'recursively' touches partial 1 once (its final y, 25 mod 12);
  'thicken' never touches partial 1 at all (t h i c k e n = 8 8 9 3 11 5 2).
The words that leave the drone hanging are therefore exactly the two
Germanic cells. A theorem asserts that equivalence. Under a literal
mod 12 the letter l (12) yields partial 0, printed as a silence.
-/

namespace Sun

-- ============================================================
-- I. GLOSSEMATIC INVENTORY AND STRATA
-- ============================================================

inductive Plane | expression | content
  deriving DecidableEq, Repr

inductive Stratum | form | substance
  deriving DecidableEq, Repr

/-- The four strata of the work (Hjelmslev, Prolegomena, def. 16-20). -/
def glossematicStratum : List (Plane × Stratum × String) :=
  [ (.expression, .form,      "paradigmatic_syntagmatic_grid"),
    (.expression, .substance, "overtone_field_above_a2"),
    (.content,    .form,      "saros_126_ordinal_series"),
    (.content,    .substance, "solar_eclipse_ephemeris") ]

inductive Category | noun | verb | adverb | order
  deriving DecidableEq, Repr

namespace Category
/-- The categories in the order sun.pl declares them. -/
def all : List Category := [noun, verb, adverb, order]
/-- The three paradigms that hold words (order holds syntagms). -/
def lexical : List Category := [noun, verb, adverb]
def name : Category → String
  | noun => "noun" | verb => "verb" | adverb => "adverb" | order => "order"
instance : ToString Category := ⟨name⟩
end Category

/-- Paradigmatic invariants: 3 x 3 x 4 = 36 commutable selections.
    Syntagmatic invariants: 2 orders permute 36 to 72.
    The position of each word in its list is its index. -/
def invariants : Category → List String
  | .noun   => ["apertures", "auguries", "apparitions"]
  | .verb   => ["align", "thicken", "emerge"]
  | .adverb => ["rhythmically", "vertically", "recursively", "now"]
  | .order  => ["suffix", "prefix"]

def invariant (c : Category) (i : Nat) : Option String := (invariants c)[i]?

def functive (c : Category) (w : String) : Bool := (invariants c).contains w

/-- Diachronic precursor (2011): the grid this one regularises. -/
def precursor2011 : Category → List String
  | .noun   => ["interpretants", "phases", "conscience"]
  | .verb   => ["flow", "infer", "projects"]
  | .adverb => ["rhythmically", "conclusively", "vertically"]
  | .order  => []

-- ============================================================
-- II. EXPRESSION-FORM: CARDINALITY AND STRIDE
-- ============================================================

def expressionSchema : List String × List String × List String × List String :=
  (invariants .noun, invariants .verb, invariants .adverb, invariants .order)

def cardinality (c : Category) : Nat := (invariants c).length

def systemCardinality : Nat :=
  Category.all.foldl (fun acc c => acc * cardinality c) 1

/-- "The categories are not distinguished by part of speech. They are
     distinguished by how far a commutation carries you through the cycle."
    Stride: ordinals moved by one step within a category. Derived. -/
def stride : Category → Nat
  | .adverb => 1
  | .verb   => cardinality .adverb
  | .noun   => cardinality .adverb * cardinality .verb
  | .order  => cardinality .adverb * cardinality .verb * cardinality .noun

-- ============================================================
-- III. SELECTION (BOTH DIRECTIONS)
-- ============================================================

/-- One cell of the grid: a choice from each paradigm and an order. -/
structure Cell where
  noun   : String
  verb   : String
  adverb : String
  order  : String
  deriving DecidableEq, Repr

def Cell.get (c : Cell) : Category → String
  | .noun => c.noun | .verb => c.verb | .adverb => c.adverb | .order => c.order

def indexOf? (x : String) : List String → Option Nat
  | []      => none
  | y :: ys => if x == y then some 0 else (indexOf? x ys).map (· + 1)

/-- A bound ordinal decodes directly. -/
def selection (n : Nat) : Option Cell := do
  guard (1 ≤ n ∧ n ≤ systemCardinality)
  let k  := n - 1
  let oi := k / stride .order
  let r1 := k % stride .order
  let ni := r1 / stride .noun
  let r2 := r1 % stride .noun
  let vi := r2 / stride .verb
  let ai := r2 % stride .verb
  pure { order  := ← invariant .order oi,  noun := ← invariant .noun ni,
         verb   := ← invariant .verb vi,   adverb := ← invariant .adverb ai }

/-- A cell encodes to its ordinal by the same stride formula, so the
    mapping cannot drift between directions. -/
def encode (c : Cell) : Option Nat := do
  let oi ← indexOf? c.order  (invariants .order)
  let ni ← indexOf? c.noun   (invariants .noun)
  let vi ← indexOf? c.verb   (invariants .verb)
  let ai ← indexOf? c.adverb (invariants .adverb)
  pure (1 + oi * stride .order + ni * stride .noun + vi * stride .verb + ai)

/-- An unbound ordinal enumerates the inventory and encodes, in the order
    Prolog would find the solutions: order, noun, verb, adverb. -/
def cells : List (Nat × Cell) :=
  (invariants .order).flatMap fun o =>
  (invariants .noun).flatMap fun n =>
  (invariants .verb).flatMap fun v =>
  (invariants .adverb).filterMap fun a =>
    let c : Cell := { noun := n, verb := v, adverb := a, order := o }
    (encode c).map (·, c)

def ordinals : List Nat := cells.map (·.1)

-- ============================================================
-- IV. SYNTAGMATIC FUNCTION AND MANIFESTATION
-- ============================================================

def syntagmaticFunction (c : Cell) : Option (List String) :=
  match c.order with
  | "suffix" => some [c.noun, " ", c.verb, " ", c.adverb]
  | "prefix" => some [c.adverb, ", ", c.noun, " ", c.verb]
  | _        => none

def atomJoin (parts : List String) : String := String.join parts

def manifestationOf (c : Cell) : Option String :=
  (syntagmaticFunction c).map atomJoin

def manifestation (n : Nat) : Option String := selection n >>= manifestationOf

def poem (n : Nat) : Option String := manifestation n

/-- poem(N, Text) with Text bound: the poem read back to its ordinal(s). -/
def poemsOf (text : String) : List Nat :=
  cells.filterMap fun (n, c) =>
    if manifestationOf c == some text then some n else none

-- ============================================================
-- V. CONTENT-FORM: SAROS 126 (1179 J - 2459)
-- ============================================================

inductive EclipseType | «partial» | annular | hybrid | total
  deriving DecidableEq, Repr

def EclipseType.name : EclipseType → String
  | .«partial» => "partial" | .annular => "annular"
  | .hybrid    => "hybrid"  | .total   => "total"

/-- One eclipse. `gamma` is in ten-thousandths of an Earth radius. -/
structure Eclipse where
  ordinal : Nat
  year    : Nat
  month   : Nat
  day     : Nat
  type    : EclipseType
  gamma   : Int
  deriving DecidableEq, Repr

def sarosTable : List Eclipse := [
  ⟨ 1, 1179,  3, 10, .«partial», (-15356)⟩,
  ⟨ 2, 1197,  3, 20, .«partial», (-14880)⟩,
  ⟨ 3, 1215,  3, 31, .«partial», (-14344)⟩,
  ⟨ 4, 1233,  4, 11, .«partial», (-13717)⟩,
  ⟨ 5, 1251,  4, 22, .«partial», (-13041)⟩,
  ⟨ 6, 1269,  5,  2, .«partial», (-12291)⟩,
  ⟨ 7, 1287,  5, 14, .«partial», (-11500)⟩,
  ⟨ 8, 1305,  5, 24, .«partial», (-10658)⟩,
  ⟨ 9, 1323,  6,  4, .annular,    (-9799)⟩,
  ⟨10, 1341,  6, 14, .annular,    (-8922)⟩,
  ⟨11, 1359,  6, 26, .annular,    (-8038)⟩,
  ⟨12, 1377,  7,  6, .annular,    (-7168)⟩,
  ⟨13, 1395,  7, 17, .annular,    (-6318)⟩,
  ⟨14, 1413,  7, 27, .annular,    (-5506)⟩,
  ⟨15, 1431,  8,  8, .annular,    (-4737)⟩,
  ⟨16, 1449,  8, 18, .annular,    (-4030)⟩,
  ⟨17, 1467,  8, 29, .annular,    (-3391)⟩,
  ⟨18, 1485,  9,  9, .annular,    (-2811)⟩,
  ⟨19, 1503,  9, 20, .annular,    (-2314)⟩,
  ⟨20, 1521,  9, 30, .annular,    (-1892)⟩,
  ⟨21, 1539, 10, 12, .annular,    (-1551)⟩,
  ⟨22, 1557, 10, 22, .annular,    (-1266)⟩,
  ⟨23, 1575, 11,  2, .annular,    (-1061)⟩,
  ⟨24, 1593, 11, 22, .annular,     (-906)⟩,
  ⟨25, 1611, 12,  4, .annular,     (-803)⟩,
  ⟨26, 1629, 12, 14, .annular,     (-725)⟩,
  ⟨27, 1647, 12, 26, .annular,     (-675)⟩,
  ⟨28, 1666,  1,  5, .annular,     (-624)⟩,
  ⟨29, 1684,  1, 16, .annular,     (-565)⟩,
  ⟨30, 1702,  1, 28, .annular,     (-484)⟩,
  ⟨31, 1720,  2,  8, .annular,     (-375)⟩,
  ⟨32, 1738,  2, 18, .annular,     (-211)⟩,
  ⟨33, 1756,  3,  1, .annular,          6⟩,
  ⟨34, 1774,  3, 12, .annular,        284⟩,
  ⟨35, 1792,  3, 22, .annular,        618⟩,
  ⟨36, 1810,  4,  4, .annular,       1031⟩,
  ⟨37, 1828,  4, 14, .hybrid,        1498⟩,
  ⟨38, 1846,  4, 25, .hybrid,        2038⟩,
  ⟨39, 1864,  5,  6, .hybrid,        2622⟩,
  ⟨40, 1882,  5, 17, .total,         3269⟩,
  ⟨41, 1900,  5, 28, .total,         3943⟩,
  ⟨42, 1918,  6,  8, .total,         4658⟩,
  ⟨43, 1936,  6, 19, .total,         5389⟩,
  ⟨44, 1954,  6, 30, .total,         6135⟩,
  ⟨45, 1972,  7, 10, .total,         6872⟩,
  ⟨46, 1990,  7, 22, .total,         7597⟩,
  ⟨47, 2008,  8,  1, .total,         8307⟩,
  ⟨48, 2026,  8, 12, .total,         8977⟩,
  ⟨49, 2044,  8, 23, .total,         9613⟩,
  ⟨50, 2062,  9,  3, .«partial»,    10191⟩,
  ⟨51, 2080,  9, 13, .«partial»,    10723⟩,
  ⟨52, 2098,  9, 25, .«partial»,    11184⟩,
  ⟨53, 2116, 10,  6, .«partial»,    11589⟩,
  ⟨54, 2134, 10, 17, .«partial»,    11931⟩,
  ⟨55, 2152, 10, 28, .«partial»,    12213⟩,
  ⟨56, 2170, 11,  8, .«partial»,    12426⟩,
  ⟨57, 2188, 11, 18, .«partial»,    12591⟩,
  ⟨58, 2206, 12,  1, .«partial»,    12711⟩,
  ⟨59, 2224, 12, 11, .«partial»,    12791⟩,
  ⟨60, 2242, 12, 22, .«partial»,    12836⟩,
  ⟨61, 2261,  1,  2, .«partial»,    12873⟩,
  ⟨62, 2279,  1, 13, .«partial»,    12899⟩,
  ⟨63, 2297,  1, 23, .«partial»,    12940⟩,
  ⟨64, 2315,  2,  5, .«partial»,    12991⟩,
  ⟨65, 2333,  2, 15, .«partial»,    13087⟩,
  ⟨66, 2351,  2, 27, .«partial»,    13209⟩,
  ⟨67, 2369,  3,  9, .«partial»,    13392⟩,
  ⟨68, 2387,  3, 20, .«partial»,    13624⟩,
  ⟨69, 2405,  3, 31, .«partial»,    13928⟩,
  ⟨70, 2423,  4, 11, .«partial»,    14282⟩,
  ⟨71, 2441,  4, 21, .«partial»,    14706⟩,
  ⟨72, 2459,  5,  3, .«partial»,    15188⟩
]

def saros (n : Nat) : Option Eclipse := sarosTable.find? (·.ordinal == n)
def sarosYear (n : Nat) : Option Nat := (saros n).map (·.year)
def sarosDate (n : Nat) : Option (Nat × Nat × Nat) :=
  (saros n).map fun e => (e.year, e.month, e.day)
def sarosType (n : Nat) : Option EclipseType := (saros n).map (·.type)

-- ============================================================
-- VI. SEMIOTIC FUNCTION
-- ============================================================

/-- The solidarity of expression-form (the text) and content-form (an
    eclipse). -/
def signFunction (n : Nat) : Option (Eclipse × String) := do
  pure (← saros n, ← manifestation n)

def sarosPoem (n : Nat) : Option (Nat × Nat × Nat × EclipseType × String) := do
  let (e, t) ← signFunction n
  pure (e.year, e.month, e.day, e.type, t)

-- ============================================================
-- VII. MUTATION: COMMUTATION AND PERMUTATION
-- ============================================================

/-- Hjelmslev (def. 54-56). Hold every category but one and exchange the
    member of that one. Results: (target ordinal, old member, new member),
    in ascending ordinal order. -/
def exchanges (cat : Category) (n1 : Nat) : List (Nat × String × String) :=
  match selection n1 with
  | none => []
  | some c1 =>
    cells.filterMap fun (n2, c2) =>
      if Category.all.all (fun k => k == cat || c1.get k == c2.get k)
         && c1.get cat != c2.get cat
      then some (n2, c1.get cat, c2.get cat) else none

/-- A commutation exchanges one member of one paradigm with the chain held. -/
def commutation (cat : Category) (n1 : Nat) : List (Nat × String × String) :=
  if cat == .order then [] else exchanges cat n1

/-- A permutation shifts the chain with the paradigms held. -/
def permutation (n1 : Nat) : List (Nat × String × String) := exchanges .order n1

inductive MutationKind | commutation (cat : Category) | permutation
  deriving DecidableEq, Repr

/-- A signed displacement in years through the Saros. -/
def displacement (n1 n2 : Nat) : Option Int := do
  let y1 ← sarosYear n1
  let y2 ← sarosYear n2
  pure ((y2 : Int) - y1)

/-- A mutation registers on the content plane as a displacement in years. -/
def mutations (n1 : Nat) : List (MutationKind × Nat × Int) :=
  let comms := Category.lexical.flatMap fun cat =>
    (commutation cat n1).filterMap fun (n2, _, _) =>
      (displacement n1 n2).map (.commutation cat, n2, ·)
  let perms := (permutation n1).filterMap fun (n2, _, _) =>
      (displacement n1 n2).map (.permutation, n2, ·)
  comms ++ perms

/-- The characteristic interval of a category: the years one minimal step
    through it carries the reader, measured from the series' first member. -/
def characteristicInterval (cat : Category) : Option Int :=
  displacement 1 (1 + stride cat)

-- ============================================================
-- VIII. MARKED CELLS: REGISTER, DEIXIS, BODY
-- ============================================================

/-- latinate covers Greek. -/
inductive Register | latinate | germanic
  deriving DecidableEq, Repr
inductive Reference | autonomous | deictic
  deriving DecidableEq, Repr
inductive Mode | event | action | manner | tactileDensity | temporalUtterance
  deriving DecidableEq, Repr

/-- word, register, reference, mode -/
def lexiconMeta : List (String × Register × Reference × Mode) :=
  [ ("apertures",    .latinate, .autonomous, .event),
    ("auguries",     .latinate, .autonomous, .event),
    ("apparitions",  .latinate, .autonomous, .event),
    ("align",        .latinate, .autonomous, .action),
    ("emerge",       .latinate, .autonomous, .action),
    ("rhythmically", .latinate, .autonomous, .manner),
    ("vertically",   .latinate, .autonomous, .manner),
    ("recursively",  .latinate, .autonomous, .manner),
    ("thicken",      .germanic, .autonomous, .tactileDensity),
    ("now",          .germanic, .deictic,    .temporalUtterance) ]

def register (w : String) : Option Register :=
  (lexiconMeta.find? (·.1 == w)).map (·.2.1)

def manifestationRegisters (n : Nat) : Option (List Register) := do
  let c ← selection n
  pure [← register c.noun, ← register c.verb, ← register c.adverb]

def onCell (p : Cell → Bool) (n : Nat) : Bool :=
  match selection n with
  | some c => p c
  | none   => false

/-- 18 require a present body; 54 can be read from anywhere. -/
def deictic    : Nat → Bool := onCell (·.adverb == "now")
def autonomous : Nat → Bool := onCell (·.adverb != "now")
/-- 24 import tactile density (Old English thiccian). -/
def tactile    : Nat → Bool := onCell (·.verb == "thicken")
/-- 36 where the body breaks through measurement (24 + 18 - 6). -/
def bodilyBreak : Nat → Bool :=
  onCell fun c => c.verb == "thicken" || c.adverb == "now"
/-- 6 where the two Germanic cells align. -/
def germanicAlignment : Nat → Bool :=
  onCell fun c => c.verb == "thicken" && c.adverb == "now"

/-- 12 August 2026: "now, apertures emerge" -/
def anchor : Nat := 48
def anchorManifestation : Option String := manifestation anchor

-- ============================================================
-- IX. EXPRESSION-SUBSTANCE: THE OVERTONE FIELD ABOVE A2
-- ============================================================

-- Each letter selects a partial of the drone by alphabet position
-- modulo twelve; letters are weighted by recurrence within the word;
-- the line is parsed noun, verb, adverb whatever its syntactic order.

def droneHz : Nat := 110

def letterPartial (ch : Char) : Option Nat :=
  if 'a' ≤ ch ∧ ch ≤ 'z' then some ((ch.toNat - 96) % 12) else none

def partialHz (p : Nat) : Nat := p * droneHz

/-- Ascending (partial, weight) pairs. -/
def spectrum (w : String) : List (Nat × Nat) :=
  let ps := w.toList.filterMap letterPartial
  (List.range 12).filterMap fun p =>
    let k := ps.count p
    if k > 0 then some (p, k) else none

def partialWeight (w : String) (p : Nat) : Nat :=
  ((spectrum w).find? (·.1 == p)).map (·.2) |>.getD 0

def touchesFundamental (w : String) : Bool := partialWeight w 1 > 0

/-- The ten words, category by category, in inventory order. -/
def lexicalWords : List String := Category.lexical.flatMap invariants

/-- Words that never return the line to the drone. -/
def fundamentalFree : List String :=
  lexicalWords.filter (! touchesFundamental ·)

def sounding (n : Nat) : Option (List (String × List (Nat × Nat))) :=
  (selection n).map fun c =>
    [c.noun, c.verb, c.adverb].map fun w => (w, spectrum w)

/-- How many letters of a line sound the fundamental. -/
def grounding (n : Nat) : Option Nat :=
  (selection n).map fun c =>
    partialWeight c.noun 1 + partialWeight c.verb 1 + partialWeight c.adverb 1

-- ============================================================
-- X. FORMATTING
-- ============================================================

def spaces (k : Nat) : String := "".pushn ' ' k
def padLeft  (s : String) (w : Nat) : String := spaces (w - s.length) ++ s
def padRight (s : String) (w : Nat) : String := s ++ spaces (w - s.length)

/-- Gamma to four decimals, from the stored ten-thousandths. -/
def writeGamma (g : Int) : String :=
  let a := g.natAbs
  let frac := toString (a % 10000)
  (if g < 0 then "-" else "") ++ toString (a / 10000) ++ "."
    ++ "".pushn '0' (4 - frac.length) ++ frac

def beforeReform (y m d : Nat) : Bool :=
  y < 1582 || (y == 1582 && (m < 10 || (m == 10 && d < 15)))

def calendarMarker (y m d : Nat) : String :=
  if beforeReform y m d then " J" else "  "

def monthName (m : Nat) : String :=
  ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
   "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][m - 1]?.getD "???"

def printDate (e : Eclipse) : String :=
  padLeft (toString e.ordinal) 2 ++ ". " ++ padLeft (toString e.day) 2 ++ " "
    ++ monthName e.month ++ " " ++ toString e.year
    ++ calendarMarker e.year e.month e.day ++ "  "

def printSpectrum (s : List (Nat × Nat)) : String :=
  " ".intercalate <| s.map fun (p, w) =>
    (if p == 0 then "silence" else toString p)
      ++ (if w > 1 then "x" ++ toString w else "")

def printKind : MutationKind → String
  | .commutation cat => "commutation " ++ padRight cat.name 7
  | .permutation     => "permutation " ++ padRight "order" 7

def signed (i : Int) : String := (if i ≥ 0 then "+" else "") ++ toString i

-- ============================================================
-- XI. EDITIONS
-- ============================================================

-- Each edition is a list of lines, enumerated from the model; no bounds
-- are written.

def epigraph : List String :=
  [ "Nulle archive sans dehors.",
    "-- Jacques Derrida, Mal d'archive, Galilee, 1995, page 26",
    "--" ]

def manifestationsEdition : List String :=
  epigraph ++ ordinals.filterMap fun n =>
    (manifestation n).map fun t => toString n ++ ". " ++ t

def sarosEdition : List String :=
  epigraph ++ sarosTable.filterMap fun e =>
    (manifestation e.ordinal).map fun t =>
      printDate e ++ padRight e.type.name 9 ++ t

def glossematicEdition : List String :=
  epigraph ++ ["expression-form / content-form", "--"]
    ++ sarosTable.filterMap fun e => do
      let t ← manifestation e.ordinal
      let c ← selection e.ordinal
      pure <| printDate e
        ++ "[" ++ c.order ++ ": " ++ c.noun ++ " / " ++ c.verb ++ " / "
        ++ c.adverb ++ "]  " ++ padRight e.type.name 9
        ++ "gamma " ++ writeGamma e.gamma ++ "  ->  " ++ t

def mutationEdition : List String :=
  let intervals := Category.all.filterMap fun cat =>
    (characteristicInterval cat).map fun years =>
      padRight cat.name 8 ++ "stride " ++ padLeft (toString (stride cat)) 2
        ++ "  interval " ++ padLeft (toString years) 3 ++ " years"
  let fromLine := ("from " ++ toString anchor ++ ". " ++ ·) <$>
    (manifestation anchor).toList
  let moves := (mutations anchor).filterMap fun (kind, n2, years) => do
    let (e, t) ← signFunction n2
    pure <| "  " ++ printKind kind ++ "-> " ++ printDate e
      ++ padRight e.type.name 9 ++ "gamma " ++ writeGamma e.gamma ++ "  "
      ++ signed years ++ "y  " ++ t
  epigraph ++ ["mutation: the chain held, one cell exchanged", "--"]
    ++ intervals ++ ["--"] ++ fromLine ++ moves

def soundingEdition : List String :=
  let words := lexicalWords.map fun w =>
    padRight w 13 ++ printSpectrum (spectrum w)
      ++ (if touchesFundamental w then "" else "   [no fundamental]")
  let lines := ordinals.filterMap fun n => do
    let c ← selection n
    let g ← grounding n
    let part (w : String) := w ++ " " ++ printSpectrum (spectrum w)
    pure <| padLeft (toString n) 2 ++ ". " ++ padLeft (toString g) 2 ++ "  "
      ++ part c.noun ++ " | " ++ part c.verb ++ " | " ++ part c.adverb
  epigraph
    ++ ["drone A2 " ++ toString droneHz
          ++ " Hz; partial = alphabet position mod 12; noun, verb, adverb", "--"]
    ++ words ++ ["--"] ++ lines

inductive Edition | manifestations | saros | glossematic | mutation | sounding
  deriving DecidableEq, Repr

def Edition.all : List Edition :=
  [.manifestations, .saros, .glossematic, .mutation, .sounding]

def Edition.name : Edition → String
  | .manifestations => "manifestations" | .saros => "saros"
  | .glossematic => "glossematic" | .mutation => "mutation"
  | .sounding => "sounding"

def Edition.ofString? (s : String) : Option Edition :=
  Edition.all.find? (·.name == s)

def Edition.lines : Edition → List String
  | .manifestations => manifestationsEdition
  | .saros          => sarosEdition
  | .glossematic    => glossematicEdition
  | .mutation       => mutationEdition
  | .sounding       => soundingEdition

-- ============================================================
-- XII. EDITION CHECKS
-- ============================================================

-- The generator derives everything from the inventory; these checks hold
-- the derived edition to the numbers this artwork asserts of itself.

def sortNats (l : List Nat) : List Nat := l.mergeSort (fun a b => decide (a ≤ b))
def sortStrings (l : List String) : List String := l.mergeSort (fun a b => decide (a ≤ b))
def distinct (l : List String) : Bool := l.eraseDups.length == l.length

/-- Every paradigm holds distinct words, every word has its lexicon entry,
    every lexicon entry is a word of the grid. (Contiguous indices and the
    fixed set of four categories are guaranteed here by the types.) -/
def inventoryValid : Bool :=
  Category.all.all (fun c => distinct (invariants c))
  && lexiconMeta.all (fun (w, _) => Category.lexical.any (functive · w))
  && lexicalWords.all (fun w => lexiconMeta.any (·.1 == w))

def editionShape : Bool :=
  expressionSchema ==
    (["apertures", "auguries", "apparitions"], ["align", "thicken", "emerge"],
     ["rhythmically", "vertically", "recursively", "now"], ["suffix", "prefix"])

def cardinalityValid : Bool := systemCardinality == 72

def uniquePoems : Bool :=
  let texts := ordinals.filterMap poem
  texts.length == 72 && distinct texts

def eclipseCoverage : Bool := sortNats (sarosTable.map (·.ordinal)) == ordinals

/-- Selection enumerates ordinals in ascending order and decodes each
    ordinal to the same cell it was encoded from; nothing outside 1..72
    decodes. (Prolog also rejects 1.5 and x; here the type rules them out.) -/
def selectionValid : Bool :=
  sortNats ordinals == ordinals
  && cells.all (fun (n, c) => selection n == some c)
  && (poem 0).isNone && (poem 73).isNone

def countOf (p : Nat → Bool) : Nat := (ordinals.filter p).length

def markedCounts : Bool :=
  countOf deictic == 18 && countOf autonomous == 54
  && countOf (onCell fun c => c.adverb == "now" && c.order == "prefix") == 9
  && countOf (onCell fun c => c.adverb == "now" && c.order == "suffix") == 9
  && countOf tactile == 24 && countOf germanicAlignment == 6
  && countOf bodilyBreak == 36

def anchorValid : Bool :=
  saros anchor == some ⟨48, 2026, 8, 12, .total, 8977⟩
  && manifestation anchor == some "now, apertures emerge"
  && poemsOf "now, apertures emerge" == [anchor]

def boundariesValid : Bool :=
  poem 1  == some "apertures align rhythmically"
  && poem 36 == some "apparitions emerge now"
  && poem 37 == some "rhythmically, apertures align"
  && poem 72 == some "now, apparitions emerge"

/-- The essay's intervals and its anchor commutation, derived not asserted. -/
def mutationValid : Bool :=
  stride .adverb == 1 && characteristicInterval .adverb == some 18
  && stride .verb == 4 && characteristicInterval .verb == some 72
  && stride .noun == 12 && characteristicInterval .noun == some 216
  && stride .order == 36 && characteristicInterval .order == some 649
  && ((commutation .noun 48).filterMap fun (n2, old, _) =>
        if old == "apertures" then (sarosYear n2).map (n2, ·) else none)
     == [(60, 2242), (72, 2459)]
  && (commutation .verb 48).map (·.1) == [40, 44]
  && (commutation .adverb 48).map (·.1) == [45, 46, 47]
  && (permutation 48).contains (12, "prefix", "suffix")
  && (mutations 48).contains (.permutation, 12, -649)
  -- Every mutation registers on the content plane.
  && ordinals.all (fun n1 => (mutations n1).all fun (_, n2, y) => n1 == n2 || y != 0)
  -- Each commutation is its own inverse.
  && Category.lexical.all (fun cat => ordinals.all fun a =>
       (commutation cat a).all fun (b, x, y) => (commutation cat b).contains (a, y, x))

/-- The sounding claims that survive the literal rule, plus the two findings. -/
def soundingValid : Bool :=
  spectrum "now" == [(2, 1), (3, 1), (11, 1)]
  && sortStrings fundamentalFree
       == sortStrings (lexicalWords.filter (register · == some .germanic))
  && partialWeight "thicken" 8 == 2 && partialWeight "emerge" 5 == 3
  && partialWeight "rhythmically" 1 == 4 && partialWeight "vertically" 1 == 2
  && partialWeight "recursively" 1 == 1
  && (spectrum "align").length == 5
  -- Every noun opens on the fundamental.
  && (invariants .noun).all touchesFundamental
  && ordinals.all (fun n => grounding n != some 0)
  -- The least grounded lines are exactly ones where both body cells sound.
  && (let gs := ordinals.filterMap grounding
      let least := gs.foldl min (gs.headD 0)
      ordinals.all fun n => grounding n != some least || germanicAlignment n)
  -- The deictic lines are exactly those whose adverb is unanchored.
  && ordinals.filter (onCell fun c => !touchesFundamental c.adverb)
     == ordinals.filter deictic

def checks : List (String × Bool) :=
  [ ("inventory", inventoryValid), ("edition_order", editionShape),
    ("cardinality", cardinalityValid), ("unique_poems", uniquePoems),
    ("eclipse_coverage", eclipseCoverage), ("selection", selectionValid),
    ("marked_cells", markedCounts), ("anchor", anchorValid),
    ("boundaries", boundariesValid), ("mutation", mutationValid),
    ("sounding", soundingValid) ]

/-- The run-time check `main` performs before printing, as sun.pl does. -/
def selfCheck : Except String Unit :=
  match checks.find? (!·.2) with
  | some (label, _) => .error s!"sun_check_failed({label})"
  | none            => .ok ()

-- The same checks as theorems: the file compiles only if they hold.

theorem inventory_valid   : inventoryValid   = true := by decide +native
theorem edition_shape     : editionShape     = true := by decide +native
theorem system_cardinality : systemCardinality = 72 := by decide
theorem unique_poems      : uniquePoems      = true := by decide +native
theorem eclipse_coverage  : eclipseCoverage  = true := by decide +native
theorem selection_valid   : selectionValid   = true := by decide +native
theorem marked_counts     : markedCounts     = true := by decide +native
theorem anchor_valid      : anchorValid      = true := by decide +native
theorem boundaries_valid  : boundariesValid  = true := by decide +native
theorem mutation_valid    : mutationValid    = true := by decide +native
theorem sounding_valid    : soundingValid    = true := by decide +native
theorem self_check        : checks.all (·.2) = true := by decide +native

-- Statements the Prolog could only test by running, given as theorems
-- over every ordinal.

/-- Selection is total on 1..72 and nowhere else. -/
theorem selection_total :
    ∀ n < 100, (selection n).isSome = (1 ≤ n ∧ n ≤ 72) := by decide +native

/-- Encoding inverts decoding on every ordinal: the two directions agree. -/
theorem encode_selection :
    ∀ n < 73, 1 ≤ n → (selection n >>= encode) = some n := by decide +native

/-- The ordinals are exactly 1..72, and so are the eclipses. -/
theorem ordinals_eq : ordinals = List.range' 1 72 := by decide +native
theorem saros_ordinals : sarosTable.map (·.ordinal) = List.range' 1 72 := by
  decide +native

/-- Prefix and suffix halves: ordinal n + 36 is n with the order permuted. -/
theorem order_halves :
    ∀ n < 37, 1 ≤ n → permutation n = [(n + 36, "suffix", "prefix")] := by
  decide +native

/-- The 2026 eclipse is total, the forty-eighth of the cycle, and its poem
    is deictic: readable only from here. -/
theorem anchor_is_now :
    sarosType anchor = some .total ∧ deictic anchor = true := by decide +native

end Sun

-- ============================================================
-- XIII. ENTRY POINT
-- ============================================================

/-- Validate quietly, then print an edition (Saros by default). -/
def main (args : List String) : IO UInt32 := do
  match Sun.selfCheck with
  | .error e => IO.eprintln e; return 1
  | .ok () =>
    let edition? := match args with
      | []       => some Sun.Edition.saros
      | [name]   => Sun.Edition.ofString? name
      | _        => none
    match edition? with
    | none =>
      IO.eprintln s!"usage: lean --run Sun.lean [{" | ".intercalate (Sun.Edition.all.map (·.name))}]"
      return 2
    | some ed =>
      for line in ed.lines do IO.println line
      return 0

-- Web editor (live.lean-lang.org): this line prints the edition in the
-- infoview. Delete it when running with `lean --run`, or it prints twice.
#eval discard (main [])

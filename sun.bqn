# ========================================================================
# SUN
# ========================================================================
#
# sun.bqn
# Sun: 72 Poems for the Solar Eclipse of August 12th 2026
# After the glossematic and acoustic architecture of https://bergholt.net/sun
# A BQN realisation of sun.pl (github.com/bergholt/triptych, MIT license).
#
# Plain BQN: no libraries, and no system values beyond •Out, •Fmt, •Type,
# so the same file runs in CBQN, in the JavaScript BQN, and in the online
# REPL at https://mlochbaum.github.io/BQN/try.html
#
# RUN    : bqn sun.bqn                 (CBQN; prints the edition below)
#          node bqn.js sun.bqn         (the JavaScript implementation)
# ONLINE : paste the whole file into the REPL and run it. The REPL also
#          shows the program's final value, which is the 2026 poem.
#
# The edition printed is set by `edition`, directly below. (The online REPL
# has no •args, and BQN rejects an unknown system value when it compiles
# the file, so reading the edition from the command line would stop the
# file from running there.)
#
# Translation notes.
#   Prolog's grid is a relation searched by backtracking. In BQN the grid
#   is an array: ↕shape is every cell at once, laid out order, noun, verb,
#   adverb, the order in which Prolog finds the solutions. The strides
#   are not counted out category by category, as sun.pl does: they are
#   the place values of that array's shape (36 12 4 1), so the claim
#   "categories are distinguished by how far a commutation carries you"
#   becomes a property of the array. Selection decodes an ordinal through
#   the place values, Encode multiplies back, and the checks hold the two
#   directions to each other.
#
#   sun.pl's self_check/0 throws at run time if the edition drifts from
#   the numbers the work claims. Here the same eleven checks run before
#   anything is printed, and a failing one raises the BQN error
#   sun_check_failed(label).
#
#   Gamma is stored as an integer in ten-thousandths (¯1.5356 is ¯15356),
#   the precision the Prolog table and printer use, so no floating-point
#   formatting is involved. "Not found", which Prolog expresses as
#   failure, is an empty result here: no cell, no poem.
#
#   The inventory order is part of the artwork: changing it changes eclipse
#   assignments. Everything numerical about the edition (strides, intervals,
#   counts, spectra) is derived from the inventory and the Saros table, and
#   the checks then hold the derived values to the ones the work asserts.
#   Astronomical data and the epigraph are retained from the original; the
#   checks validate structure, not external accuracy. ASCII output; dates
#   use the original Julian/Gregorian catalogue convention.
#
# Two findings the sounding rule yields that the essay does not state:
#   'recursively' touches partial 1 once (its final y, 25 mod 12);
#   'thicken' never touches partial 1 at all (t h i c k e n = 8 8 9 3 11 5 2).
# The words that leave the drone hanging are therefore exactly the two
# Germanic cells. The sounding check asserts that equivalence. Under a
# literal mod 12 the letter l (12) yields partial 0, printed as a silence.

# One of: "manifestations", "saros", "glossematic", "mutation", "sounding"
edition ← "saros"

# ============================================================
# I. GLOSSEMATIC INVENTORY AND STRATA
# ============================================================

planes ← "expression"‿"content"
strata ← "form"‿"substance"

# The four strata of the work (Hjelmslev, Prolegomena, def. 16-20).
glossematicStratum ← ⟨
  "expression"‿"form"‿"paradigmatic_syntagmatic_grid"
  "expression"‿"substance"‿"overtone_field_above_a2"
  "content"‿"form"‿"saros_126_ordinal_series"
  "content"‿"substance"‿"solar_eclipse_ephemeris"
⟩

# The categories in the order sun.pl declares them.
categories ← "noun"‿"verb"‿"adverb"‿"order"
noun‿verb‿adverb‿order ← ↕≠categories
lexical ← noun‿verb‿adverb           # the paradigms that hold words

# Paradigmatic invariants: 3 x 3 x 4 = 36 commutable selections.
# Syntagmatic invariants: 2 orders permute 36 to 72.
# The position of each word in its list is its index.
inventory ← ⟨
  "apertures"‿"auguries"‿"apparitions"
  "align"‿"thicken"‿"emerge"
  "rhythmically"‿"vertically"‿"recursively"‿"now"
  "suffix"‿"prefix"
⟩

Invariant ← {𝕩 ⊑ 𝕨 ⊑ inventory}       # category Invariant index
In ← {⊑ (<𝕨) ∊ 𝕩}                      # value In list
IndexOf ← {⊑ 𝕨 ⊐ ⋈𝕩}                   # list IndexOf value (≠list if absent)
Functive ← {𝕩 In 𝕨 ⊑ inventory}        # category Functive word

# Diachronic precursor (2011): the grid this one regularises.
precursor2011 ← ⟨
  "interpretants"‿"phases"‿"conscience"
  "flow"‿"infer"‿"projects"
  "rhythmically"‿"conclusively"‿"vertically"
⟩

# ============================================================
# II. EXPRESSION-FORM: CARDINALITY AND STRIDE
# ============================================================

cardinality ← ≠¨ inventory
systemCardinality ← ×´ cardinality

# The grid's axes run order, noun, verb, adverb.
axes ← order‿noun‿verb‿adverb
shape ← axes ⊏ cardinality                   # 2 3 3 4
placeValue ← ⌽ ×` 1 ∾ ⌽ 1 ↓ shape            # 36 12 4 1

# "The categories are not distinguished by part of speech. They are
#  distinguished by how far a commutation carries you through the cycle."
# Stride of each category: the place value of its axis. Derived.
stride ← placeValue ⊏˜ axes ⊐ ↕≠categories   # noun 12, verb 4, adverb 1, order 36

# ============================================================
# III. SELECTION (BOTH DIRECTIONS)
# ============================================================

# A cell is one index per category, in category order.

# A bound ordinal decodes through the place values; anything that is not
# an ordinal of the grid selects nothing.
Selection ← {
  1 ≠ •Type 𝕩 ? ⟨⟩ ;
  (𝕩 ≠ ⌊𝕩) ∨ (𝕩 < 1) ∨ 𝕩 > systemCardinality ? ⟨⟩ ;
  (shape | ⌊ (𝕩 - 1) ÷ placeValue) ⊏˜ axes ⊐ ↕≠categories
}

# A cell encodes by the same strides, so the mapping cannot drift between
# directions.
Encode ← {1 + +´ stride × 𝕩}

# An unbound ordinal enumerates the inventory and encodes: every cell of
# the grid, in the order Prolog would find the solutions.
cells ← (<axes ⊐ ↕≠categories) ⊏¨ ⥊ ↕ shape
ordinals ← Encode¨ cells

Words ← {𝕩 ⊑¨ inventory}                     # the four words of a cell

# ============================================================
# IV. SYNTAGMATIC FUNCTION AND MANIFESTATION
# ============================================================

SyntagmaticFunction ← {
  "suffix" ≡ 𝕨 ? n‿v‿a ← 𝕩 ⋄ ⟨n, " ", v, " ", a⟩ ;
  "prefix" ≡ 𝕨 ? n‿v‿a ← 𝕩 ⋄ ⟨a, ", ", n, " ", v⟩ ;
  ⟨⟩
}

AtomJoin ← ∾

ManifestationOf ← {
  0 = ≠𝕩 ? "" ;
  w ← Words 𝕩 ⋄ AtomJoin (order ⊑ w) SyntagmaticFunction 3 ↑ w
}

Manifestation ← ManifestationOf Selection
Poem ← Manifestation

# poem(N, Text) with Text bound: the poem read back to its ordinal(s).
PoemsOf ← {((<𝕩) ≡¨ ManifestationOf¨ cells) / ordinals}

# ============================================================
# V. CONTENT-FORM: SAROS 126 (1179 J - 2459)
# ============================================================

typeNames ← "partial"‿"annular"‿"hybrid"‿"total"
partial‿annular‿hybrid‿total ← ↕≠typeNames

# ordinal, year, month, day, type, gamma (ten-thousandths)
sarosTable ← >⟨
  1‿1179‿3‿10‿partial‿¯15356
  2‿1197‿3‿20‿partial‿¯14880
  3‿1215‿3‿31‿partial‿¯14344
  4‿1233‿4‿11‿partial‿¯13717
  5‿1251‿4‿22‿partial‿¯13041
  6‿1269‿5‿2‿partial‿¯12291
  7‿1287‿5‿14‿partial‿¯11500
  8‿1305‿5‿24‿partial‿¯10658
  9‿1323‿6‿4‿annular‿¯9799
  10‿1341‿6‿14‿annular‿¯8922
  11‿1359‿6‿26‿annular‿¯8038
  12‿1377‿7‿6‿annular‿¯7168
  13‿1395‿7‿17‿annular‿¯6318
  14‿1413‿7‿27‿annular‿¯5506
  15‿1431‿8‿8‿annular‿¯4737
  16‿1449‿8‿18‿annular‿¯4030
  17‿1467‿8‿29‿annular‿¯3391
  18‿1485‿9‿9‿annular‿¯2811
  19‿1503‿9‿20‿annular‿¯2314
  20‿1521‿9‿30‿annular‿¯1892
  21‿1539‿10‿12‿annular‿¯1551
  22‿1557‿10‿22‿annular‿¯1266
  23‿1575‿11‿2‿annular‿¯1061
  24‿1593‿11‿22‿annular‿¯906
  25‿1611‿12‿4‿annular‿¯803
  26‿1629‿12‿14‿annular‿¯725
  27‿1647‿12‿26‿annular‿¯675
  28‿1666‿1‿5‿annular‿¯624
  29‿1684‿1‿16‿annular‿¯565
  30‿1702‿1‿28‿annular‿¯484
  31‿1720‿2‿8‿annular‿¯375
  32‿1738‿2‿18‿annular‿¯211
  33‿1756‿3‿1‿annular‿6
  34‿1774‿3‿12‿annular‿284
  35‿1792‿3‿22‿annular‿618
  36‿1810‿4‿4‿annular‿1031
  37‿1828‿4‿14‿hybrid‿1498
  38‿1846‿4‿25‿hybrid‿2038
  39‿1864‿5‿6‿hybrid‿2622
  40‿1882‿5‿17‿total‿3269
  41‿1900‿5‿28‿total‿3943
  42‿1918‿6‿8‿total‿4658
  43‿1936‿6‿19‿total‿5389
  44‿1954‿6‿30‿total‿6135
  45‿1972‿7‿10‿total‿6872
  46‿1990‿7‿22‿total‿7597
  47‿2008‿8‿1‿total‿8307
  48‿2026‿8‿12‿total‿8977
  49‿2044‿8‿23‿total‿9613
  50‿2062‿9‿3‿partial‿10191
  51‿2080‿9‿13‿partial‿10723
  52‿2098‿9‿25‿partial‿11184
  53‿2116‿10‿6‿partial‿11589
  54‿2134‿10‿17‿partial‿11931
  55‿2152‿10‿28‿partial‿12213
  56‿2170‿11‿8‿partial‿12426
  57‿2188‿11‿18‿partial‿12591
  58‿2206‿12‿1‿partial‿12711
  59‿2224‿12‿11‿partial‿12791
  60‿2242‿12‿22‿partial‿12836
  61‿2261‿1‿2‿partial‿12873
  62‿2279‿1‿13‿partial‿12899
  63‿2297‿1‿23‿partial‿12940
  64‿2315‿2‿5‿partial‿12991
  65‿2333‿2‿15‿partial‿13087
  66‿2351‿2‿27‿partial‿13209
  67‿2369‿3‿9‿partial‿13392
  68‿2387‿3‿20‿partial‿13624
  69‿2405‿3‿31‿partial‿13928
  70‿2423‿4‿11‿partial‿14282
  71‿2441‿4‿21‿partial‿14706
  72‿2459‿5‿3‿partial‿15188
⟩
eOrd‿eYear‿eMonth‿eDay‿eType‿eGamma ← <˘ ⍉ sarosTable

Saros ← {i ← eOrd IndexOf 𝕩 ⋄ i < ≠eOrd ? i ⊏ sarosTable ; ⟨⟩}
SarosYear ← {1 ⊑ Saros 𝕩}
SarosDate ← {1‿2‿3 ⊏ Saros 𝕩}
SarosType ← {4 ⊑ Saros 𝕩}

# ============================================================
# VI. SEMIOTIC FUNCTION
# ============================================================

# The solidarity of expression-form (the text) and content-form (an
# eclipse).
SignFunction ← {(Saros 𝕩) ⋈ Poem 𝕩}

# ============================================================
# VII. MUTATION: COMMUTATION AND PERMUTATION
# ============================================================

# Hjelmslev (def. 54-56). Hold every category but one and exchange the
# member of that one. Results: target ordinal, old member, new member, in
# ascending ordinal order.
ExchangesOf ← {cat 𝕊 c1:
  held ← cat ≠ ↕≠categories
  Hit ← {eq ← (Words 𝕩) ≡¨ Words c1 ⋄ (∧´ held / eq) ∧ ¬ cat ⊑ eq}
  {⟨Encode 𝕩, cat ⊑ Words c1, cat ⊑ Words 𝕩⟩}¨ (Hit¨ cells) / cells
}
Exchanges ← {0 = ≠Selection 𝕩 ? ⟨⟩ ; 𝕨 ExchangesOf Selection 𝕩}

# A commutation exchanges one member of one paradigm with the chain held.
Commutation ← {𝕨 = order ? ⟨⟩ ; 𝕨 Exchanges 𝕩}
# A permutation shifts the chain with the paradigms held.
Permutation ← {order Exchanges 𝕩}

# A signed displacement in years through the Saros.
Displacement ← {(SarosYear 𝕩) - SarosYear 𝕨}

# A mutation registers on the content plane as a displacement in years.
# Kind: the category exchanged; order means the permutation.
Moves ← {𝕨 = order ? Permutation 𝕩 ; 𝕨 Commutation 𝕩}
Mutations ← {n1 ← 𝕩 ⋄
  ∾ {c ← 𝕩 ⋄ {⟨c, ⊑𝕩, n1 Displacement ⊑𝕩⟩}¨ c Moves n1}¨ ↕≠categories
}

# The characteristic interval of a category: the years one minimal step
# through it carries the reader, measured from the series' first member.
CharacteristicInterval ← {1 Displacement 1 + 𝕩 ⊑ stride}

# ============================================================
# VIII. MARKED CELLS: REGISTER, DEIXIS, BODY
# ============================================================

regLatinate‿regGermanic ← ↕2                 # latinate covers Greek
refAutonomous‿refDeictic ← ↕2
modeEvent‿modeAction‿modeManner‿modeTactileDensity‿modeTemporalUtterance ← ↕5

# word, register, reference, mode
lexiconMeta ← ⟨
  "apertures"‿regLatinate‿refAutonomous‿modeEvent
  "auguries"‿regLatinate‿refAutonomous‿modeEvent
  "apparitions"‿regLatinate‿refAutonomous‿modeEvent
  "align"‿regLatinate‿refAutonomous‿modeAction
  "emerge"‿regLatinate‿refAutonomous‿modeAction
  "rhythmically"‿regLatinate‿refAutonomous‿modeManner
  "vertically"‿regLatinate‿refAutonomous‿modeManner
  "recursively"‿regLatinate‿refAutonomous‿modeManner
  "thicken"‿regGermanic‿refAutonomous‿modeTactileDensity
  "now"‿regGermanic‿refDeictic‿modeTemporalUtterance
⟩
lexWords ← ⊑¨ lexiconMeta

Register ← {i ← lexWords IndexOf 𝕩 ⋄ i < ≠lexWords ? 1 ⊑ i ⊑ lexiconMeta ; ¯1}
ManifestationRegisters ← {Register¨ 3 ↑ Words Selection 𝕩}

_onCell ← {0 = ≠Selection 𝕩 ? 0 ; 𝔽 Words Selection 𝕩}

# 18 require a present body; 54 can be read from anywhere.
Deictic    ← {"now" ≡ adverb ⊑ 𝕩}_onCell
Autonomous ← {"now" ≢ adverb ⊑ 𝕩}_onCell
# 24 import tactile density (Old English thiccian).
Tactile    ← {"thicken" ≡ verb ⊑ 𝕩}_onCell
# 36 where the body breaks through measurement (24 + 18 - 6).
BodilyBreak ← {("thicken" ≡ verb ⊑ 𝕩) ∨ "now" ≡ adverb ⊑ 𝕩}_onCell
# 6 where the two Germanic cells align.
GermanicAlignment ← {("thicken" ≡ verb ⊑ 𝕩) ∧ "now" ≡ adverb ⊑ 𝕩}_onCell

# 12 August 2026: "now, apertures emerge"
anchor ← 48
anchorManifestation ← Poem anchor

# ============================================================
# IX. EXPRESSION-SUBSTANCE: THE OVERTONE FIELD ABOVE A2
# ============================================================

# Each letter selects a partial of the drone by alphabet position
# modulo twelve; letters are weighted by recurrence within the word;
# the line is parsed noun, verb, adverb whatever its syntactic order.

droneHz ← 110
Partials ← {12 | 96 -˜ ((𝕩 ≥ 'a') ∧ 𝕩 ≤ 'z') / 𝕩 - @}
PartialHz ← droneHz⊸×

Weights ← {+˝ (Partials 𝕩) =⌜ ↕12}           # weight of partials 0..11
# Ascending partial‿weight pairs.
Spectrum ← {w ← Weights 𝕩 ⋄ (w > 0) / (↕12) ⋈¨ w}
PartialWeight ← {𝕩 ⊑ Weights 𝕨}              # word PartialWeight partial
TouchesFundamental ← {0 < 𝕩 PartialWeight 1}

# The ten words, category by category, in inventory order.
lexicalWords ← ∾ lexical ⊏ inventory
# Words that never return the line to the drone.
fundamentalFree ← (¬ TouchesFundamental¨ lexicalWords) / lexicalWords

Sounding ← {{𝕩 ⋈ Spectrum 𝕩}¨ 3 ↑ Words Selection 𝕩}
# How many letters of a line sound the fundamental.
Grounding ← {+´ {𝕩 PartialWeight 1}¨ 3 ↑ Words Selection 𝕩}

# ============================================================
# X. FORMATTING
# ============================================================

Num ← {𝕩 < 0 ? '-' ∾ •Fmt -𝕩 ; •Fmt 𝕩}
PadL ← {((0 ⌈ 𝕨 - ≠𝕩) ⥊ ' ') ∾ 𝕩}
PadR ← {𝕩 ∾ (0 ⌈ 𝕨 - ≠𝕩) ⥊ ' '}
PadZ ← {((0 ⌈ 𝕨 - ≠𝕩) ⥊ '0') ∾ 𝕩}

# Gamma to four decimals, from the stored ten-thousandths.
WriteGamma ← {((𝕩 < 0) / "-") ∾ (Num ⌊ (|𝕩) ÷ 10000) ∾ "." ∾ 4 PadZ Num 10000 | |𝕩}

BeforeReform ← {𝕊 y‿m‿d: (y < 1582) ∨ (y = 1582) ∧ (m < 10) ∨ (m = 10) ∧ d < 15}
CalendarMarker ← {BeforeReform 𝕩 ? " J" ; "  "}

monthNames ← "Jan"‿"Feb"‿"Mar"‿"Apr"‿"May"‿"Jun"‿"Jul"‿"Aug"‿"Sep"‿"Oct"‿"Nov"‿"Dec"

# The date column of an eclipse row: "48. 12 Aug 2026    "
PrintDate ← {𝕊 n‿y‿m‿d‿t‿g:
  ∾⟨2 PadL Num n, ". ", 2 PadL Num d, " ", (m - 1) ⊑ monthNames
    " ", Num y, CalendarMarker y‿m‿d, "  "⟩
}
PrintType ← {9 PadR (4 ⊑ 𝕩) ⊑ typeNames}

PrintSpectrum ← {1 ↓ ∾ {𝕊 p‿w: " " ∾ ({𝕩 = 0 ? "silence" ; Num 𝕩} p) ∾ {𝕩 > 1 ? 'x' ∾ Num 𝕩 ; ""} w}¨ 𝕩}

PrintKind ← {
  𝕩 = order ? "permutation " ∾ 7 PadR "order" ;
  "commutation " ∾ 7 PadR 𝕩 ⊑ categories
}
Signed ← {((𝕩 ≥ 0) / "+") ∾ Num 𝕩}

Keep ← (0 < ≠¨)⊸/                             # drop lines that have no poem

# ============================================================
# XI. EDITIONS
# ============================================================

# Each edition is a list of lines, enumerated from the model; no bounds
# are written.

epigraph ← ⟨
  "Nulle archive sans dehors."
  "-- Jacques Derrida, Mal d'archive, Galilee, 1995, page 26"
  "--"
⟩

ManifestationsEdition ← {𝕊:
  epigraph ∾ Keep {t ← Poem 𝕩 ⋄ 0 < ≠t ? (Num 𝕩) ∾ ". " ∾ t ; ""}¨ ordinals
}

SarosEdition ← {𝕊:
  epigraph ∾ Keep {t ← Poem ⊑𝕩 ⋄ 0 < ≠t ? (PrintDate 𝕩) ∾ (PrintType 𝕩) ∾ t ; ""}¨ <˘ sarosTable
}

GlossematicEdition ← {𝕊:
  epigraph ∾ "expression-form / content-form"‿"--" ∾ Keep {
    t ← Poem ⊑𝕩 ⋄ 0 < ≠t ?
    n‿v‿a‿o ← Words Selection ⊑𝕩
    ∾⟨PrintDate 𝕩, "[", o, ": ", n, " / ", v, " / ", a, "]  "
      PrintType 𝕩, "gamma ", WriteGamma 5 ⊑ 𝕩, "  ->  ", t⟩
    ;
    ""
  }¨ <˘ sarosTable
}

MutationEdition ← {𝕊:
  intervals ← {
    ∾⟨8 PadR 𝕩 ⊑ categories, "stride ", 2 PadL Num 𝕩 ⊑ stride
      "  interval ", 3 PadL Num CharacteristicInterval 𝕩, " years"⟩
  }¨ ↕≠categories
  fromLine ← "from " ∾ (Num anchor) ∾ ". " ∾ Poem anchor
  moves ← {𝕊 k‿n2‿y:
    r ← Saros n2
    ∾⟨"  ", PrintKind k, "-> ", PrintDate r, PrintType r
      "gamma ", WriteGamma 5 ⊑ r, "  ", Signed y, "y  ", Poem n2⟩
  }¨ Mutations anchor
  ∾⟨epigraph, "mutation: the chain held, one cell exchanged"‿"--"
    intervals, ⟨"--", fromLine⟩, moves⟩
}

SoundingEdition ← {𝕊:
  wordLines ← {
    ∾⟨13 PadR 𝕩, PrintSpectrum Spectrum 𝕩
      (¬ TouchesFundamental 𝕩) / "   [no fundamental]"⟩
  }¨ lexicalWords
  Part ← {𝕩 ∾ " " ∾ PrintSpectrum Spectrum 𝕩}
  lineLines ← {
    ∾⟨2 PadL Num 𝕩, ". ", 2 PadL Num Grounding 𝕩, "  "
      ¯3 ↓ ∾ (∾⟜" | " Part)¨ 3 ↑ Words Selection 𝕩⟩
  }¨ ordinals
  drone ← "drone A2 " ∾ (Num droneHz) ∾ " Hz; partial = alphabet position mod 12; noun, verb, adverb"
  epigraph ∾ ⟨drone, "--"⟩ ∾ wordLines ∾ ⟨"--"⟩ ∾ lineLines
}

editionNames ← "manifestations"‿"saros"‿"glossematic"‿"mutation"‿"sounding"
editionFns ← ManifestationsEdition‿SarosEdition‿GlossematicEdition‿MutationEdition‿SoundingEdition

# ============================================================
# XII. EDITION CHECKS
# ============================================================

# The generator derives everything from the inventory; these checks hold
# the derived edition to the numbers this artwork asserts of itself.

Count ← {+´ 𝕏¨ ordinals}
Distinct ← {(≠𝕩) = ≠⍷𝕩}

# Every paradigm holds distinct words, every word has its lexicon entry,
# every lexicon entry is a word of the grid.
InventoryValid ← {𝕊:
  ∧´⟨
    ∧´ Distinct¨ inventory
    ∧´ {∨´ lexical Functive¨ <𝕩}¨ lexWords
    ∧´ {¯1 ≠ Register 𝕩}¨ lexicalWords
  ⟩
}

EditionShape ← {𝕊:
  inventory ≡ ⟨
    "apertures"‿"auguries"‿"apparitions"
    "align"‿"thicken"‿"emerge"
    "rhythmically"‿"vertically"‿"recursively"‿"now"
    "suffix"‿"prefix"
  ⟩
}

CardinalityValid ← {𝕊: systemCardinality = 72}

UniquePoems ← {𝕊: t ← Poem¨ ordinals ⋄ (72 = ≠t) ∧ Distinct t}

EclipseCoverage ← {𝕊: (∧ eOrd) ≡ ordinals}

# Selection enumerates ordinals in ascending order and decodes each
# ordinal to the same cell it was encoded from; nothing else decodes.
SelectionValid ← {𝕊:
  ∧´⟨
    (∧ ordinals) ≡ ordinals
    cells ≡ Selection¨ ordinals
    ordinals ≡ Encode¨ Selection¨ ordinals
    ∧´ {0 = ≠Poem 𝕩}¨ ⟨0, 73, 1.5, 'x'⟩
  ⟩
}

NowPrefix ← {("now" ≡ adverb ⊑ 𝕩) ∧ "prefix" ≡ order ⊑ 𝕩}_onCell
NowSuffix ← {("now" ≡ adverb ⊑ 𝕩) ∧ "suffix" ≡ order ⊑ 𝕩}_onCell

MarkedCounts ← {𝕊:
  ∧´⟨
    18 = Count deictic,  54 = Count autonomous
    9 = Count nowPrefix, 9 = Count nowSuffix
    24 = Count tactile,  6 = Count germanicAlignment
    36 = Count bodilyBreak
  ⟩
}

AnchorValid ← {𝕊:
  ∧´⟨
    (Saros anchor) ≡ 48‿2026‿8‿12‿total‿8977
    "now, apertures emerge" ≡ Poem anchor
    ⟨anchor⟩ ≡ PoemsOf "now, apertures emerge"
  ⟩
}

BoundariesValid ← {𝕊:
  ∧´⟨
    "apertures align rhythmically" ≡ Poem 1
    "apparitions emerge now" ≡ Poem 36
    "rhythmically, apertures align" ≡ Poem 37
    "now, apparitions emerge" ≡ Poem 72
  ⟩
}

# The essay's intervals and its anchor commutation, derived not asserted.
MutationValid ← {𝕊:
  nounMoves ← ("apertures" ≡ 1⊸⊑)¨⊸/ noun Commutation 48
  Inverse ← {cat 𝕊 a: ∧´ {𝕊 b‿x‿y: a‿y‿x In cat Commutation b}¨ cat Commutation a}
  ∧´⟨
    stride ≡ 12‿4‿1‿36
    (CharacteristicInterval¨ ↕≠categories) ≡ 216‿72‿18‿649
    ⟨60‿2242, 72‿2459⟩ ≡ {(⊑𝕩) ⋈ SarosYear ⊑𝕩}¨ nounMoves
    40‿44 ≡ ⊑¨ verb Commutation 48
    45‿46‿47 ≡ ⊑¨ adverb Commutation 48
    12‿"prefix"‿"suffix" In Permutation 48
    order‿12‿¯649 In Mutations 48
    # Every mutation registers on the content plane.
    ∧´ {n1 ← 𝕩 ⋄ ∧´ {(n1 = 1 ⊑ 𝕩) ∨ 0 ≠ 2 ⊑ 𝕩}¨ Mutations n1}¨ ordinals
    # Each commutation is its own inverse.
    ∧´ ⥊ lexical Inverse⌜ ordinals
  ⟩
}

# The sounding claims that survive the literal rule, plus the two findings.
SoundingValid ← {𝕊:
  g ← Grounding¨ ordinals
  ∧´⟨
    ⟨2‿1, 3‿1, 11‿1⟩ ≡ Spectrum "now"
    (∧ fundamentalFree) ≡ ∧ (regGermanic = Register¨ lexicalWords) / lexicalWords
    2 = "thicken" PartialWeight 8,       3 = "emerge" PartialWeight 5
    4 = "rhythmically" PartialWeight 1,  2 = "vertically" PartialWeight 1
    1 = "recursively" PartialWeight 1
    5 = ≠Spectrum "align"
    # Every noun opens on the fundamental.
    ∧´ TouchesFundamental¨ noun ⊑ inventory
    ∧´ g ≠ 0
    # The least grounded lines are exactly ones where both body cells sound.
    ∧´ GermanicAlignment¨ (g = ⌊´ g) / ordinals
    # The deictic lines are exactly those whose adverb is unanchored.
    ((Deictic¨ ordinals) / ordinals) ≡ ({¬ TouchesFundamental adverb ⊑ Words Selection 𝕩}¨ ordinals) / ordinals
  ⟩
}

checkLabels ← ⟨
  "inventory", "edition_order", "cardinality", "unique_poems"
  "eclipse_coverage", "selection", "marked_cells", "anchor"
  "boundaries", "mutation", "sounding"
⟩
checkFns ← ⟨
  InventoryValid, EditionShape, CardinalityValid, UniquePoems
  EclipseCoverage, SelectionValid, MarkedCounts, AnchorValid
  BoundariesValid, MutationValid, SoundingValid
⟩

# Validate before printing, as sun.pl does. A check that errors fails.
SelfCheck ← {𝕊:
  held ← {1 ≡ 𝕏⎊0 @}¨ checkFns
  ("sun_check_failed(" ∾ ((⊑ held ⊐ 0) ⊑ checkLabels ∾ <"") ∾ ")") ! ∧´ held
  @
}

# ============================================================
# XIII. ENTRY POINT
# ============================================================

# Validate quietly, print an edition, and give back the 2026 poem.
Main ← {𝕊 name:
  SelfCheck @
  i ← editionNames IndexOf name
  "usage: edition ← one of manifestations, saros, glossematic, mutation, sounding" ! i < ≠editionNames
  •Out¨ i˙◶editionFns @
  anchorManifestation
}

Main edition

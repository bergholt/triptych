# Sun: 72 Poems for the Solar Eclipse of August 12th 2026
# Uiua realization of sun.pl, https://github.com/bergholt/triptych (MIT)
# After https://bergholt.net/sun
#
# Paste this file into https://www.uiua.org/pad or run: uiua run sun.ua
# The last line validates the model and prints the Saros edition.
# Replace PrintSaros with PrintManifestations, PrintGlossematic,
# PrintMutation, or PrintSounding to see the other editions.
# To query the model, replace the last line with e.g. Poem 48,
# FindPoem "now, apertures emerge", MutationDetails 0 48, or Spectrum "now".

# Expression-form: noun, verb, adverb, order.
Categories ← {"noun" "verb" "adverb" "order"}
Nouns ← {"apertures" "auguries" "apparitions"}
Verbs ← {"align" "thicken" "emerge"}
Adverbs ← {"rhythmically" "vertically" "recursively" "now"}
Orders ← {"suffix" "prefix"}
Inventory ← {Nouns Verbs Adverbs Orders}
Words ← /◇⊂ ↙3 Inventory
Cardinalities ← ≡◇⧻ Inventory
Count ← /× Cardinalities
Ordinals ← +1⇡Count
Strides ← [/×⊏1_2 Cardinalities  ⊡2 Cardinalities  1  /×↙3 Cardinalities]
StratumTable ← [
  {"expression" "form" "paradigmatic_syntagmatic_grid"}
  {"expression" "substance" "overtone_field_above_a2"}
  {"content" "form" "saros_126_ordinal_series"}
  {"content" "substance" "solar_eclipse_ephemeris"}
]
Precursor ← [
  {"interpretants" "phases" "conscience"}
  {"flow" "infer" "projects"}
  {"rhythmically" "conclusively" "vertically"}
]

# Encode takes four zero-based indices in category order.
# Decode, Selection and Poem take a one-based ordinal.
Same ← =∩□
IntegerInRange ← ××⊃(=⊸⌊|≥1|≤Count)
ValidOrdinal ← ⨬(IntegerInRange|(0 ◌)) ⊃(↥⊃(≠0 type|≠0⧻△)|∘)
RequireOrdinal ← ⍤"Sun: expected an integer ordinal from 1 through 72" ⊸ValidOrdinal
Decode ← ◿Cardinalities ⌊÷Strides -1 RequireOrdinal
Encode ← +1/+×Strides
Selection ← ≡(⊡⊙°□) ⊙Inventory Decode
SelectedNoun ← °□⊡0
SelectedVerb ← °□⊡1
SelectedAdverb ← °□⊡2
SelectedOrder ← °□⊡3
Suffix ← $"_ _ _" ⊃(SelectedNoun|SelectedVerb|SelectedAdverb)
Prefix ← $"_, _ _" ⊃(SelectedAdverb|SelectedNoun|SelectedVerb)
PoemText ← ⨬(Suffix|Prefix) ⊃(Same "prefix" SelectedOrder|∘)
Poem ← PoemText Selection
Poems ← ⍚Poem Ordinals
FindPoem ← ▽⊙Ordinals =Poems □
Selections ← ⍚Selection Ordinals
FindSelection ← ▽⊙Ordinals =Selections □

# Content-form: ordinal, year, month, day, type code, gamma × 10000.
# The gamma column uses integer units to retain exactly four decimal places.
EclipseTypes ← {"partial" "annular" "hybrid" "total"}
SarosTable ← [
  [ 1 1179  3 10 0 ¯15356]
  [ 2 1197  3 20 0 ¯14880]
  [ 3 1215  3 31 0 ¯14344]
  [ 4 1233  4 11 0 ¯13717]
  [ 5 1251  4 22 0 ¯13041]
  [ 6 1269  5  2 0 ¯12291]
  [ 7 1287  5 14 0 ¯11500]
  [ 8 1305  5 24 0 ¯10658]
  [ 9 1323  6  4 1  ¯9799]
  [10 1341  6 14 1  ¯8922]
  [11 1359  6 26 1  ¯8038]
  [12 1377  7  6 1  ¯7168]
  [13 1395  7 17 1  ¯6318]
  [14 1413  7 27 1  ¯5506]
  [15 1431  8  8 1  ¯4737]
  [16 1449  8 18 1  ¯4030]
  [17 1467  8 29 1  ¯3391]
  [18 1485  9  9 1  ¯2811]
  [19 1503  9 20 1  ¯2314]
  [20 1521  9 30 1  ¯1892]
  [21 1539 10 12 1  ¯1551]
  [22 1557 10 22 1  ¯1266]
  [23 1575 11  2 1  ¯1061]
  [24 1593 11 22 1   ¯906]
  [25 1611 12  4 1   ¯803]
  [26 1629 12 14 1   ¯725]
  [27 1647 12 26 1   ¯675]
  [28 1666  1  5 1   ¯624]
  [29 1684  1 16 1   ¯565]
  [30 1702  1 28 1   ¯484]
  [31 1720  2  8 1   ¯375]
  [32 1738  2 18 1   ¯211]
  [33 1756  3  1 1      6]
  [34 1774  3 12 1    284]
  [35 1792  3 22 1    618]
  [36 1810  4  4 1   1031]
  [37 1828  4 14 2   1498]
  [38 1846  4 25 2   2038]
  [39 1864  5  6 2   2622]
  [40 1882  5 17 3   3269]
  [41 1900  5 28 3   3943]
  [42 1918  6  8 3   4658]
  [43 1936  6 19 3   5389]
  [44 1954  6 30 3   6135]
  [45 1972  7 10 3   6872]
  [46 1990  7 22 3   7597]
  [47 2008  8  1 3   8307]
  [48 2026  8 12 3   8977]
  [49 2044  8 23 3   9613]
  [50 2062  9  3 0  10191]
  [51 2080  9 13 0  10723]
  [52 2098  9 25 0  11184]
  [53 2116 10  6 0  11589]
  [54 2134 10 17 0  11931]
  [55 2152 10 28 0  12213]
  [56 2170 11  8 0  12426]
  [57 2188 11 18 0  12591]
  [58 2206 12  1 0  12711]
  [59 2224 12 11 0  12791]
  [60 2242 12 22 0  12836]
  [61 2261  1  2 0  12873]
  [62 2279  1 13 0  12899]
  [63 2297  1 23 0  12940]
  [64 2315  2  5 0  12991]
  [65 2333  2 15 0  13087]
  [66 2351  2 27 0  13209]
  [67 2369  3  9 0  13392]
  [68 2387  3 20 0  13624]
  [69 2405  3 31 0  13928]
  [70 2423  4 11 0  14282]
  [71 2441  4 21 0  14706]
  [72 2459  5  3 0  15188]
]
Saros ← ⊡⊙SarosTable -1 RequireOrdinal
SarosYear ← ⊡1 Saros
SarosType ← °□⊡⊙EclipseTypes ⊡4 Saros
SarosGamma ← ÷10000 ⊡5 Saros
# Boxed pair: the raw eclipse row (scaled gamma) and its manifestation.
Sign ← {⊃(Saros|Poem)}

# Lexicon: word, register, reference, mode.
Lexicon ← [
  {"apertures"    "latinate" "autonomous" "event"}
  {"auguries"     "latinate" "autonomous" "event"}
  {"apparitions"  "latinate" "autonomous" "event"}
  {"align"        "latinate" "autonomous" "action"}
  {"emerge"       "latinate" "autonomous" "action"}
  {"rhythmically" "latinate" "autonomous" "manner"}
  {"vertically"   "latinate" "autonomous" "manner"}
  {"recursively"  "latinate" "autonomous" "manner"}
  {"thicken"      "germanic" "autonomous" "tactile_density"}
  {"now"          "germanic" "deictic"    "temporal_utterance"}
]
LexiconWords ← ≡⊡0 Lexicon
Metadata ← ⊢▽⊙Lexicon =LexiconWords □
Register ← °□⊡1 Metadata
ManifestationRegisters ← ⍚Register ↙3 Selection
Deictic ← Same "now" SelectedAdverb Selection
Autonomous ← =0 Deictic
Tactile ← Same "thicken" SelectedVerb Selection
BodilyBreak ← ↥⊃(Tactile|Deictic)
GermanicAlignment ← ×⊃(Tactile|Deictic)
Anchor ← 48
AnchorPoem ← Poem Anchor

# MutationTargets takes a zero-based category index and a source ordinal.
# Results are ascending within a category. Order (3) is a permutation.
CategoryIds ← ⇡⧻Categories
CategoryName ← °□⊡⊙Categories
CategoryStride ← ⊡⊙Strides
CategorySize ← ⊡⊙Cardinalities
CategoryIndex ← ⊡⊙Decode
IndexChanges ← ▽⊸(≠0) -⊃(CategoryIndex|⇡CategorySize)
MutationTargets ← +⊃(×⊃(CategoryStride|IndexChanges)|⋅∘)
Displacement ← -⊃(SarosYear|⋅SarosYear)
IntervalYears ← Displacement 1 +1 CategoryStride
CharacteristicInterval ← [⊃(CategoryStride|IntervalYears)]
# Mutation rows are [target, signed years].
MutationYears ← ≡Displacement ⊃(⋅∘|MutationTargets)
Mutation ← ⍉⊟⊃(MutationTargets|MutationYears)
# Boxed detail rows hold the target, old cell, new cell, and signed years.
CellAt ← °□⊡⊙Selection
MutationDetail ← {⊃(⋅⋅∘|CellAt|CellAt ⊃(∘|⋅⋅∘)|Displacement ⋅⊙∘)}
MutationDetails ← ≡MutationDetail ⊃(∘|⋅∘|MutationTargets)

# Expression-substance. A zero partial is a silence. Spectra are [partial, weight]
# rows in ascending partial order. Sounding is always in noun, verb, adverb order.
DroneHz ← 110
PartialHz ← ×DroneHz
Lowercase ← ×⊃(≥@a|≤@z)
LetterPartials ← ◿12 -96 utf₈ ▽⊸Lowercase
Partials ← ⇡12
PartialCounts ← ≡(/+=) Partials ¤ LetterPartials
PartialWeight ← ⊡⊙PartialCounts
Spectrum ← ▽⊸(≡(>0⊡1)) ⍉⊟ Partials PartialCounts
TouchesFundamental ← >0 PartialWeight 1
FundamentalFree ← =0 TouchesFundamental
Sounding ← ⍚Spectrum ↙3 Selection
Grounding ← /+≡◇(PartialWeight 1) ↙3 Selection

# Formatting. Ordinals and days are space-padded, while gamma uses zeroes.
Space ← ⊢" "
Text ← $"_"
PadLeft ← ⬚Space ↙⊃(¯↥⊙⧻|⋅∘)
PadRight ← ⬚Space ↙⊃(↥⊙⧻|⋅∘)
Months ← {"Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"}
Month ← °□⊡⊙Months -1
Calendar ← ⨬(("  " ◌)|(" J" ◌)) ⊃(<15821015 /+× 10000_100_1 ⊏1_2_3|∘)
YearCalendar ← ⊂⊃(Text ⊡1|Calendar)
DateRow ← $"_. _ _ _  " ⊃(PadLeft 2 Text ⊡0|PadLeft 2 Text ⊡3|Month ⊡2|YearCalendar)
Date ← DateRow Saros
GammaSign ← ⨬(("" ◌)|("-" ◌)) ⊃(<0|∘)
GammaMagnitude ← $"_._" ⊃(⌊÷10000|⬚@0↙¯4 Text ◿10000)
GammaText ← ⊂⊃(GammaSign|GammaMagnitude ⌵) ⊡5 Saros
SignedYears ← ⨬($"+_y"|$"-_y") ⊃(<0|⌵)

Epigraph ← &p "Nulle archive sans dehors.\n-- Jacques Derrida, Mal d'archive, Galilee, 1995, page 26\n--"
Separator ← &p "--"

ManifestationLine ← $"_. _" ⊃(∘|Poem)
SarosLine ← ⊂₃⊃(Date|PadRight 9 SarosType|Poem)
SelectionLabel ← $"[_: _ / _ / _]  " ⊃(SelectedOrder|SelectedNoun|SelectedVerb|SelectedAdverb) Selection
GlossematicBody ← $"_gamma _  ->  _" ⊃(PadRight 9 SarosType|GammaText|Poem)
GlossematicLine ← ⊂₃⊃(Date|SelectionLabel|GlossematicBody)

IntervalLine ← $"_stride _  interval _ years" ⊃(PadRight 8 CategoryName|PadLeft 2 Text CategoryStride|PadLeft 3 Text IntervalYears)
MutationKind ← ⊂⊃(⨬(("commutation " ◌)|("permutation " ◌)) ⊃(=3|∘)|PadRight 7 CategoryName)
MutationBody ← $"_gamma _  _  _" ⊃(⊂⊃(Date|PadRight 9 SarosType)|GammaText|SignedYears Displacement Anchor|Poem)
MutationLine ← $"  _-> _" ⊃(MutationKind|⋅MutationBody)
PrintAnchorCategory ← ≡(&p MutationLine) ⊃(∘|MutationTargets ⊙Anchor)
AnchorLine ← $"from _. _" Anchor AnchorPoem

PartialLabel ← ⨬(Text|("silence" ◌)) ⊃(=0|∘)
WeightSuffix ← ⨬(("" ◌)|$"x_") ⊃(>1|∘)
SpectrumToken ← ⊂⊃(PartialLabel ⊡0|WeightSuffix ⊡1)
JoinSpectrum ← /◇$"_ _" ⍚SpectrumToken
SpectrumText ← ⨬(JoinSpectrum|("" ◌)) ⊃(=0⧻|∘) Spectrum
FundamentalLabel ← ⨬(("" ◌)|("   [no fundamental]" ◌)) ⊃(FundamentalFree|∘)
WordSpectrumLine ← ⊂₃⊃(PadRight 13|SpectrumText|FundamentalLabel)
WordSound ← $"_ _" ⊃(∘|SpectrumText)
SoundingWords ← $"_ | _ | _" ⊃(WordSound SelectedNoun|WordSound SelectedVerb|WordSound SelectedAdverb) Selection
SoundingLine ← $"_. _  _" ⊃(PadLeft 2 Text|PadLeft 2 Text Grounding|SoundingWords)

PrintManifestations ← ≡(&p ManifestationLine) Ordinals Epigraph
PrintSaros ← ≡(&p SarosLine) Ordinals Epigraph
PrintGlossematic ← ≡(&p GlossematicLine) Ordinals Separator &p "expression-form / content-form" Epigraph
PrintMutation ← ≡PrintAnchorCategory CategoryIds &p AnchorLine Separator ≡(&p IntervalLine) CategoryIds Separator &p "mutation: the chain held, one cell exchanged" Epigraph
PrintSounding ← ≡(&p SoundingLine) Ordinals Separator ≡◇(&p WordSpectrumLine) Words Separator &p $"drone A2 _ Hz; partial = alphabet position mod 12; noun, verb, adverb" DroneHz Epigraph

# Edition checks, run before any printer.
CheckInventory ← ⍤"Sun: lexicon coverage" Same ⍆Words ⍆LexiconWords
CheckInventoryUniqueness ← ⍤"Sun: duplicate inventory cells" Same Cardinalities ≡◇(⧻◴) Inventory
CheckEditionShape ← ⍤"Sun: edition inventory order" Same Inventory {{"apertures" "auguries" "apparitions"} {"align" "thicken" "emerge"} {"rhythmically" "vertically" "recursively" "now"} {"suffix" "prefix"}}
CheckCardinality ← ⍤"Sun: edition cardinality" =72 Count
CheckUniquePoems ← ⍤"Sun: duplicate manifestations" =Count ⧻◴ Poems
CheckEclipseCoverage ← ⍤"Sun: eclipse coverage" Same Ordinals ≡⊡0 SarosTable

# Enumerate the Cartesian grid independently of Decode.
AllCells ← ≡(⊏1_2_3_0) ↯[Count ⧻Categories] ⇡⊏3_0_1_2 Cardinalities
CheckDecode ← ⍤"Sun: ordinal decoding" Same AllCells ≡Decode Ordinals
CheckEncode ← ⍤"Sun: ordinal encoding" Same Ordinals ≡Encode AllCells
CheckOrdinalBounds ← ⍤"Sun: invalid ordinals accepted" =0 /+≡◇ValidOrdinal {0 73 1.5 "x"}
PrefixNowCount ← /+≡(×⊃(Deictic|=1 CategoryIndex 3)) Ordinals
SuffixNowCount ← /+≡(×⊃(Deictic|=0 CategoryIndex 3)) Ordinals
MarkedCounts ← [/+≡Deictic Ordinals  /+≡Autonomous Ordinals  PrefixNowCount  SuffixNowCount  /+≡Tactile Ordinals  /+≡GermanicAlignment Ordinals  /+≡BodilyBreak Ordinals]
CheckMarked ← ⍤"Sun: marked cell counts" Same 18_54_9_9_24_6_36 MarkedCounts
CheckAnchorDate ← ⍤"Sun: anchor eclipse" Same 2026_8_12_3 ⊏1_2_3_4 Saros Anchor
CheckAnchorText ← ⍤"Sun: anchor manifestation" Same "now, apertures emerge" AnchorPoem
CheckAnchorLookup ← ⍤"Sun: reverse lookup" ×⊃(Same [48] FindPoem AnchorPoem|Same [48] FindSelection Selection Anchor)
CheckBoundaries ← ⍤"Sun: boundary manifestations" Same {"apertures align rhythmically" "apparitions emerge now" "rhythmically, apertures align" "now, apparitions emerge"} ⊏1_36_37_72 ⊂□"" Poems

CheckIntervals ← ⍤"Sun: characteristic intervals" Same [12_216 4_72 1_18 36_649] ≡CharacteristicInterval CategoryIds
CheckNounMutation ← ⍤"Sun: anchor noun commutations" Same [60_2242 72_2459] ⍉⊟⊃(∘|≡SarosYear) MutationTargets 0 Anchor
CheckVerbMutation ← ⍤"Sun: anchor verb commutations" Same 40_44 MutationTargets 1 Anchor
CheckAdverbMutation ← ⍤"Sun: anchor adverb commutations" Same 45_46_47 MutationTargets 2 Anchor
CheckOrderMutation ← ⍤"Sun: anchor permutation" Same [12_¯649] Mutation 3 Anchor
# For a category, source and target, check reversibility and year displacement.
ReturnsToSource ← /↥=⊃(⋅∘|MutationTargets ⊃(∘|⋅⋅∘))
ChangesYear ← ≠0 Displacement ⋅⊙∘
ValidTargets ← /× ≡(×⊃(ReturnsToSource|ChangesYear)) ⊃(∘|⋅∘|MutationTargets)
CheckAllMutations ← ⍤"Sun: mutation reversibility or displacement" /×♭⊞ValidTargets CategoryIds Ordinals

CheckNowSpectrum ← ⍤"Sun: spectrum of now" Same [2_1 3_1 11_1] Spectrum "now"
GermanicWord ← Same "germanic" Register
CheckFreeSpectrum ← ⍤"Sun: Germanic words and free spectra disagree" Same ≡◇GermanicWord Words ≡◇FundamentalFree Words
SoundingWeights ← [PartialWeight 8 "thicken"  PartialWeight 5 "emerge"  PartialWeight 1 "rhythmically"  PartialWeight 1 "vertically"  PartialWeight 1 "recursively"]
CheckWeights ← ⍤"Sun: sounding weights" Same 2_3_4_2_1 SoundingWeights
CheckAlignSpectrum ← ⍤"Sun: spectrum size of align" =5 ⧻Spectrum "align"
CheckNounFundamental ← ⍤"Sun: noun fundamentals" /×≡◇TouchesFundamental Nouns
MinimumGrounding ← /↧≡Grounding Ordinals
LeastGrounded ← =MinimumGrounding Grounding
CheckGrounding ← ⍤"Sun: grounding" ×⊃(>0 MinimumGrounding|/×≥ ≡LeastGrounded Ordinals ≡GermanicAlignment Ordinals)
UnanchoredAdverb ← FundamentalFree SelectedAdverb Selection
CheckUnanchored ← ⍤"Sun: unanchored adverbs disagree with deixis" Same ≡Deictic Ordinals ≡UnanchoredAdverb Ordinals

CheckSchema ← CheckCardinality CheckEditionShape CheckInventoryUniqueness CheckInventory
CheckSelection ← CheckOrdinalBounds CheckEncode CheckDecode CheckEclipseCoverage CheckUniquePoems
CheckManifestations ← CheckBoundaries CheckAnchorLookup CheckAnchorText CheckAnchorDate CheckMarked
CheckMutation ← CheckAllMutations CheckOrderMutation CheckAdverbMutation CheckVerbMutation CheckNounMutation CheckIntervals
CheckSounding ← CheckUnanchored CheckGrounding CheckNounFundamental CheckAlignSpectrum CheckWeights CheckFreeSpectrum CheckNowSpectrum
SelfCheck ← CheckSounding CheckMutation CheckManifestations CheckSelection CheckSchema

PrintSaros SelfCheck

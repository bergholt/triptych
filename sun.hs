{-
========================================================================
SUN
========================================================================

Sun.hs
Sun: 72 Poems for the Solar Eclipse of August 12th 2026
After the glossematic and acoustic architecture of https://bergholt.net/sun
A Haskell realisation of sun.pl (github.com/bergholt/triptych, MIT license).

Haskell 2010 plus base only. One file, no Cabal or Stack project.

RUN    : runghc Sun.hs                      (Saros edition, the default)
         runghc Sun.hs glossematic          (or: manifestations, saros,
                                             mutation, sounding)
BUILD  : ghc -O Sun.hs -o sun && ./sun sounding
QUERY  : ghci Sun.hs, then for example
           poem 48                          -- Just "now, apertures emerge"
           poemsOf "now, apertures emerge"  -- [48]
           selection 48
           commutation Noun 48              -- [(60,..),(72,..)]
           permutation 48                   -- [(12,"prefix","suffix")]
           mutations 48
           [(c, stride c, characteristicInterval c) | c <- categories]
           spectrum "now"                   -- [(2,1),(3,1),(11,1)]
           fundamentalFree                  -- ["thicken","now"]
           sounding 48
           filter deictic ordinals
           selfCheck                        -- Right ()

Translation notes.
  Prolog finds every solution of a relation by backtracking. Haskell's
  list monad does the same thing explicitly: a list comprehension over
  the inventory is the search, and `cells` is the full solution set of
  selection(N, Noun, Verb, Adverb, Order) with N unbound. The other
  direction, a bound ordinal, is `selection`, which decodes by the same
  stride formula that `encode` uses, so the two cannot drift apart;
  selfCheck holds them to each other.

  sun.pl's self_check/0 throws at run time if the edition drifts from the
  numbers the work claims; here the same eleven checks run before any
  edition is printed, and a failure prints sun_check_failed(label) to
  stderr and exits with status 1.

  The words of the poem stay strings so the sounding rule can read their
  letters; the closed vocabularies around them (categories, eclipse
  types, registers) are data types. Gamma is stored as an integer in
  ten-thousandths (-1.5356 is -15356), the precision the Prolog table and
  its printer use, so no floating-point formatting is involved.

  The inventory order is part of the artwork: changing it changes eclipse
  assignments. Everything numerical about the edition (strides, intervals,
  counts, spectra) is derived from the inventory and the Saros table, and
  selfCheck then holds the derived values to the ones the work asserts.
  Astronomical data and the epigraph are retained from the original; the
  checks validate structure, not external accuracy. ASCII output; dates
  use the original Julian/Gregorian catalogue convention.

Two findings the sounding rule yields that the essay does not state:
  'recursively' touches partial 1 once (its final y, 25 mod 12);
  'thicken' never touches partial 1 at all (t h i c k e n = 8 8 9 3 11 5 2).
The words that leave the drone hanging are therefore exactly the two
Germanic cells. selfCheck asserts that equivalence. Under a literal
mod 12 the letter l (12) yields partial 0, printed as a silence.
-}

module Main where

import Data.Char (ord)
import Data.List (find, nub, sort, elemIndex, intercalate)
import Data.Maybe (isNothing, fromMaybe, mapMaybe)
import System.Environment (getArgs)
import System.Exit (exitWith, ExitCode (..))
import System.IO (hPutStrLn, stderr)

-- ============================================================
-- I. GLOSSEMATIC INVENTORY AND STRATA
-- ============================================================

data Plane = Expression | Content deriving (Eq, Show)
data Stratum = Form | Substance deriving (Eq, Show)

-- | The four strata of the work (Hjelmslev, Prolegomena, def. 16-20).
glossematicStratum :: [(Plane, Stratum, String)]
glossematicStratum =
  [ (Expression, Form,      "paradigmatic_syntagmatic_grid")
  , (Expression, Substance, "overtone_field_above_a2")
  , (Content,    Form,      "saros_126_ordinal_series")
  , (Content,    Substance, "solar_eclipse_ephemeris") ]

data Category = Noun | Verb | Adverb | Order deriving (Eq, Show)

-- | The categories in the order sun.pl declares them.
categories :: [Category]
categories = [Noun, Verb, Adverb, Order]

-- | The three paradigms that hold words (order holds syntagms).
lexicalCategories :: [Category]
lexicalCategories = [Noun, Verb, Adverb]

categoryName :: Category -> String
categoryName Noun   = "noun"
categoryName Verb   = "verb"
categoryName Adverb = "adverb"
categoryName Order  = "order"

-- | Paradigmatic invariants: 3 x 3 x 4 = 36 commutable selections.
--   Syntagmatic invariants: 2 orders permute 36 to 72.
--   The position of each word in its list is its index.
invariants :: Category -> [String]
invariants Noun   = ["apertures", "auguries", "apparitions"]
invariants Verb   = ["align", "thicken", "emerge"]
invariants Adverb = ["rhythmically", "vertically", "recursively", "now"]
invariants Order  = ["suffix", "prefix"]

invariant :: Category -> Int -> Maybe String
invariant c i = lookup i (zip [0 ..] (invariants c))

functive :: Category -> String -> Bool
functive c w = w `elem` invariants c

-- | Diachronic precursor (2011): the grid this one regularises.
precursor2011 :: Category -> [String]
precursor2011 Noun   = ["interpretants", "phases", "conscience"]
precursor2011 Verb   = ["flow", "infer", "projects"]
precursor2011 Adverb = ["rhythmically", "conclusively", "vertically"]
precursor2011 Order  = []

-- ============================================================
-- II. EXPRESSION-FORM: CARDINALITY AND STRIDE
-- ============================================================

expressionSchema :: ([String], [String], [String], [String])
expressionSchema =
  (invariants Noun, invariants Verb, invariants Adverb, invariants Order)

cardinality :: Category -> Int
cardinality = length . invariants

systemCardinality :: Int
systemCardinality = product (map cardinality categories)

-- | "The categories are not distinguished by part of speech. They are
--    distinguished by how far a commutation carries you through the cycle."
--   Stride: ordinals moved by one step within a category. Derived.
stride :: Category -> Int
stride Adverb = 1
stride Verb   = cardinality Adverb
stride Noun   = cardinality Adverb * cardinality Verb
stride Order  = cardinality Adverb * cardinality Verb * cardinality Noun

-- ============================================================
-- III. SELECTION (BOTH DIRECTIONS)
-- ============================================================

-- | One cell of the grid: a choice from each paradigm and an order.
data Cell = Cell
  { cellNoun   :: String
  , cellVerb   :: String
  , cellAdverb :: String
  , cellOrder  :: String
  } deriving (Eq, Show)

cellGet :: Cell -> Category -> String
cellGet c Noun   = cellNoun c
cellGet c Verb   = cellVerb c
cellGet c Adverb = cellAdverb c
cellGet c Order  = cellOrder c

-- | A bound ordinal decodes directly.
selection :: Int -> Maybe Cell
selection n
  | n < 1 || n > systemCardinality = Nothing
  | otherwise = do
      let k = n - 1
          (oi, r1) = k  `divMod` stride Order
          (ni, r2) = r1 `divMod` stride Noun
          (vi, ai) = r2 `divMod` stride Verb
      o <- invariant Order oi
      w <- invariant Noun ni
      v <- invariant Verb vi
      a <- invariant Adverb ai
      pure (Cell w v a o)

-- | A cell encodes to its ordinal by the same stride formula, so the
--   mapping cannot drift between directions.
encode :: Cell -> Maybe Int
encode (Cell w v a o) = do
  oi <- elemIndex o (invariants Order)
  ni <- elemIndex w (invariants Noun)
  vi <- elemIndex v (invariants Verb)
  ai <- elemIndex a (invariants Adverb)
  pure (1 + oi * stride Order + ni * stride Noun + vi * stride Verb + ai)

-- | An unbound ordinal enumerates the inventory and encodes, in the order
--   Prolog would find the solutions: order, noun, verb, adverb.
cells :: [(Int, Cell)]
cells =
  [ (n, c)
  | o <- invariants Order, w <- invariants Noun
  , v <- invariants Verb,  a <- invariants Adverb
  , let c = Cell w v a o
  , Just n <- [encode c] ]

ordinals :: [Int]
ordinals = map fst cells

-- ============================================================
-- IV. SYNTAGMATIC FUNCTION AND MANIFESTATION
-- ============================================================

syntagmaticFunction :: Cell -> Maybe [String]
syntagmaticFunction (Cell w v a o) = case o of
  "suffix" -> Just [w, " ", v, " ", a]
  "prefix" -> Just [a, ", ", w, " ", v]
  _        -> Nothing

atomJoin :: [String] -> String
atomJoin = concat

manifestationOf :: Cell -> Maybe String
manifestationOf = fmap atomJoin . syntagmaticFunction

manifestation :: Int -> Maybe String
manifestation n = selection n >>= manifestationOf

poem :: Int -> Maybe String
poem = manifestation

-- | poem(N, Text) with Text bound: the poem read back to its ordinal(s).
poemsOf :: String -> [Int]
poemsOf text = [n | (n, c) <- cells, manifestationOf c == Just text]

-- ============================================================
-- V. CONTENT-FORM: SAROS 126 (1179 J - 2459)
-- ============================================================

data EclipseType = Partial | Annular | Hybrid | Total deriving (Eq, Show)

eclipseTypeName :: EclipseType -> String
eclipseTypeName Partial = "partial"
eclipseTypeName Annular = "annular"
eclipseTypeName Hybrid  = "hybrid"
eclipseTypeName Total   = "total"

-- | One eclipse. Gamma is in ten-thousandths of an Earth radius.
data Eclipse = Eclipse
  { eOrdinal :: Int
  , eYear    :: Int
  , eMonth   :: Int
  , eDay     :: Int
  , eType    :: EclipseType
  , eGamma   :: Int
  } deriving (Eq, Show)

sarosTable :: [Eclipse]
sarosTable =
  [ Eclipse  1 1179  3 10 Partial (-15356)
  , Eclipse  2 1197  3 20 Partial (-14880)
  , Eclipse  3 1215  3 31 Partial (-14344)
  , Eclipse  4 1233  4 11 Partial (-13717)
  , Eclipse  5 1251  4 22 Partial (-13041)
  , Eclipse  6 1269  5  2 Partial (-12291)
  , Eclipse  7 1287  5 14 Partial (-11500)
  , Eclipse  8 1305  5 24 Partial (-10658)
  , Eclipse  9 1323  6  4 Annular  (-9799)
  , Eclipse 10 1341  6 14 Annular  (-8922)
  , Eclipse 11 1359  6 26 Annular  (-8038)
  , Eclipse 12 1377  7  6 Annular  (-7168)
  , Eclipse 13 1395  7 17 Annular  (-6318)
  , Eclipse 14 1413  7 27 Annular  (-5506)
  , Eclipse 15 1431  8  8 Annular  (-4737)
  , Eclipse 16 1449  8 18 Annular  (-4030)
  , Eclipse 17 1467  8 29 Annular  (-3391)
  , Eclipse 18 1485  9  9 Annular  (-2811)
  , Eclipse 19 1503  9 20 Annular  (-2314)
  , Eclipse 20 1521  9 30 Annular  (-1892)
  , Eclipse 21 1539 10 12 Annular  (-1551)
  , Eclipse 22 1557 10 22 Annular  (-1266)
  , Eclipse 23 1575 11  2 Annular  (-1061)
  , Eclipse 24 1593 11 22 Annular   (-906)
  , Eclipse 25 1611 12  4 Annular   (-803)
  , Eclipse 26 1629 12 14 Annular   (-725)
  , Eclipse 27 1647 12 26 Annular   (-675)
  , Eclipse 28 1666  1  5 Annular   (-624)
  , Eclipse 29 1684  1 16 Annular   (-565)
  , Eclipse 30 1702  1 28 Annular   (-484)
  , Eclipse 31 1720  2  8 Annular   (-375)
  , Eclipse 32 1738  2 18 Annular   (-211)
  , Eclipse 33 1756  3  1 Annular        6
  , Eclipse 34 1774  3 12 Annular      284
  , Eclipse 35 1792  3 22 Annular      618
  , Eclipse 36 1810  4  4 Annular     1031
  , Eclipse 37 1828  4 14 Hybrid      1498
  , Eclipse 38 1846  4 25 Hybrid      2038
  , Eclipse 39 1864  5  6 Hybrid      2622
  , Eclipse 40 1882  5 17 Total       3269
  , Eclipse 41 1900  5 28 Total       3943
  , Eclipse 42 1918  6  8 Total       4658
  , Eclipse 43 1936  6 19 Total       5389
  , Eclipse 44 1954  6 30 Total       6135
  , Eclipse 45 1972  7 10 Total       6872
  , Eclipse 46 1990  7 22 Total       7597
  , Eclipse 47 2008  8  1 Total       8307
  , Eclipse 48 2026  8 12 Total       8977
  , Eclipse 49 2044  8 23 Total       9613
  , Eclipse 50 2062  9  3 Partial    10191
  , Eclipse 51 2080  9 13 Partial    10723
  , Eclipse 52 2098  9 25 Partial    11184
  , Eclipse 53 2116 10  6 Partial    11589
  , Eclipse 54 2134 10 17 Partial    11931
  , Eclipse 55 2152 10 28 Partial    12213
  , Eclipse 56 2170 11  8 Partial    12426
  , Eclipse 57 2188 11 18 Partial    12591
  , Eclipse 58 2206 12  1 Partial    12711
  , Eclipse 59 2224 12 11 Partial    12791
  , Eclipse 60 2242 12 22 Partial    12836
  , Eclipse 61 2261  1  2 Partial    12873
  , Eclipse 62 2279  1 13 Partial    12899
  , Eclipse 63 2297  1 23 Partial    12940
  , Eclipse 64 2315  2  5 Partial    12991
  , Eclipse 65 2333  2 15 Partial    13087
  , Eclipse 66 2351  2 27 Partial    13209
  , Eclipse 67 2369  3  9 Partial    13392
  , Eclipse 68 2387  3 20 Partial    13624
  , Eclipse 69 2405  3 31 Partial    13928
  , Eclipse 70 2423  4 11 Partial    14282
  , Eclipse 71 2441  4 21 Partial    14706
  , Eclipse 72 2459  5  3 Partial    15188
  ]

saros :: Int -> Maybe Eclipse
saros n = find ((== n) . eOrdinal) sarosTable

sarosYear :: Int -> Maybe Int
sarosYear = fmap eYear . saros

sarosDate :: Int -> Maybe (Int, Int, Int)
sarosDate = fmap (\e -> (eYear e, eMonth e, eDay e)) . saros

sarosType :: Int -> Maybe EclipseType
sarosType = fmap eType . saros

-- ============================================================
-- VI. SEMIOTIC FUNCTION
-- ============================================================

-- | The solidarity of expression-form (the text) and content-form (an
--   eclipse).
signFunction :: Int -> Maybe (Eclipse, String)
signFunction n = (,) <$> saros n <*> manifestation n

sarosPoem :: Int -> Maybe (Int, Int, Int, EclipseType, String)
sarosPoem n = do
  (e, t) <- signFunction n
  pure (eYear e, eMonth e, eDay e, eType e, t)

-- ============================================================
-- VII. MUTATION: COMMUTATION AND PERMUTATION
-- ============================================================

-- | Hjelmslev (def. 54-56). Hold every category but one and exchange the
--   member of that one. Results: (target ordinal, old member, new member),
--   in ascending ordinal order.
exchanges :: Category -> Int -> [(Int, String, String)]
exchanges cat n1 = case selection n1 of
  Nothing -> []
  Just c1 ->
    [ (n2, cellGet c1 cat, cellGet c2 cat)
    | (n2, c2) <- cells
    , all (\k -> k == cat || cellGet c1 k == cellGet c2 k) categories
    , cellGet c1 cat /= cellGet c2 cat ]

-- | A commutation exchanges one member of one paradigm with the chain held.
commutation :: Category -> Int -> [(Int, String, String)]
commutation Order _ = []
commutation cat n1  = exchanges cat n1

-- | A permutation shifts the chain with the paradigms held.
permutation :: Int -> [(Int, String, String)]
permutation = exchanges Order

data MutationKind = Commutation Category | Permutation deriving (Eq, Show)

-- | A signed displacement in years through the Saros.
displacement :: Int -> Int -> Maybe Int
displacement n1 n2 = (-) <$> sarosYear n2 <*> sarosYear n1

-- | A mutation registers on the content plane as a displacement in years.
mutations :: Int -> [(MutationKind, Int, Int)]
mutations n1 =
  [ (Commutation cat, n2, y)
  | cat <- lexicalCategories, (n2, _, _) <- commutation cat n1
  , Just y <- [displacement n1 n2] ]
  ++
  [ (Permutation, n2, y)
  | (n2, _, _) <- permutation n1, Just y <- [displacement n1 n2] ]

-- | The characteristic interval of a category: the years one minimal step
--   through it carries the reader, measured from the series' first member.
characteristicInterval :: Category -> Maybe Int
characteristicInterval cat = displacement 1 (1 + stride cat)

-- ============================================================
-- VIII. MARKED CELLS: REGISTER, DEIXIS, BODY
-- ============================================================

-- | latinate covers Greek.
data Register = Latinate | Germanic deriving (Eq, Show)
data Reference = Autonomous | Deictic deriving (Eq, Show)
data Mode = Event | Action | Manner | TactileDensity | TemporalUtterance
  deriving (Eq, Show)

-- | word, register, reference, mode
lexiconMeta :: [(String, Register, Reference, Mode)]
lexiconMeta =
  [ ("apertures",    Latinate, Autonomous, Event)
  , ("auguries",     Latinate, Autonomous, Event)
  , ("apparitions",  Latinate, Autonomous, Event)
  , ("align",        Latinate, Autonomous, Action)
  , ("emerge",       Latinate, Autonomous, Action)
  , ("rhythmically", Latinate, Autonomous, Manner)
  , ("vertically",   Latinate, Autonomous, Manner)
  , ("recursively",  Latinate, Autonomous, Manner)
  , ("thicken",      Germanic, Autonomous, TactileDensity)
  , ("now",          Germanic, Deictic,    TemporalUtterance) ]

metaWord :: (String, Register, Reference, Mode) -> String
metaWord (w, _, _, _) = w

register :: String -> Maybe Register
register w = case find ((== w) . metaWord) lexiconMeta of
  Just (_, r, _, _) -> Just r
  Nothing           -> Nothing

manifestationRegisters :: Int -> Maybe [Register]
manifestationRegisters n = do
  c <- selection n
  mapM register [cellNoun c, cellVerb c, cellAdverb c]

onCell :: (Cell -> Bool) -> Int -> Bool
onCell p = maybe False p . selection

-- | 18 require a present body; 54 can be read from anywhere.
deictic, autonomous :: Int -> Bool
deictic    = onCell ((== "now") . cellAdverb)
autonomous = onCell ((/= "now") . cellAdverb)

-- | 24 import tactile density (Old English thiccian).
tactile :: Int -> Bool
tactile = onCell ((== "thicken") . cellVerb)

-- | 36 where the body breaks through measurement (24 + 18 - 6).
bodilyBreak :: Int -> Bool
bodilyBreak = onCell (\c -> cellVerb c == "thicken" || cellAdverb c == "now")

-- | 6 where the two Germanic cells align.
germanicAlignment :: Int -> Bool
germanicAlignment =
  onCell (\c -> cellVerb c == "thicken" && cellAdverb c == "now")

-- | 12 August 2026: "now, apertures emerge"
anchor :: Int
anchor = 48

anchorManifestation :: Maybe String
anchorManifestation = manifestation anchor

-- ============================================================
-- IX. EXPRESSION-SUBSTANCE: THE OVERTONE FIELD ABOVE A2
-- ============================================================

-- Each letter selects a partial of the drone by alphabet position
-- modulo twelve; letters are weighted by recurrence within the word;
-- the line is parsed noun, verb, adverb whatever its syntactic order.

droneHz :: Int
droneHz = 110

letterPartial :: Char -> Maybe Int
letterPartial ch
  | ch >= 'a' && ch <= 'z' = Just ((ord ch - 96) `mod` 12)
  | otherwise              = Nothing

partialHz :: Int -> Int
partialHz p = p * droneHz

-- | Ascending (partial, weight) pairs.
spectrum :: String -> [(Int, Int)]
spectrum w =
  [ (p, k) | p <- [0 .. 11], let k = length (filter (== p) ps), k > 0 ]
  where ps = mapMaybe letterPartial w

partialWeight :: String -> Int -> Int
partialWeight w p = fromMaybe 0 (lookup p (spectrum w))

touchesFundamental :: String -> Bool
touchesFundamental w = partialWeight w 1 > 0

-- | The ten words, category by category, in inventory order.
lexicalWords :: [String]
lexicalWords = concatMap invariants lexicalCategories

-- | Words that never return the line to the drone.
fundamentalFree :: [String]
fundamentalFree = filter (not . touchesFundamental) lexicalWords

sounding :: Int -> Maybe [(String, [(Int, Int)])]
sounding n = do
  c <- selection n
  pure [(w, spectrum w) | w <- [cellNoun c, cellVerb c, cellAdverb c]]

-- | How many letters of a line sound the fundamental.
grounding :: Int -> Maybe Int
grounding n = do
  c <- selection n
  pure (sum [partialWeight w 1 | w <- [cellNoun c, cellVerb c, cellAdverb c]])

-- ============================================================
-- X. FORMATTING
-- ============================================================

padLeft, padRight :: Int -> String -> String
padLeft  w s = replicate (w - length s) ' ' ++ s
padRight w s = s ++ replicate (w - length s) ' '

-- | Gamma to four decimals, from the stored ten-thousandths.
writeGamma :: Int -> String
writeGamma g =
  (if g < 0 then "-" else "") ++ show i ++ "." ++ pad0 (show f)
  where
    (i, f) = abs g `divMod` 10000
    pad0 s = replicate (4 - length s) '0' ++ s

beforeReform :: Int -> Int -> Int -> Bool
beforeReform y m d = y < 1582 || (y == 1582 && (m < 10 || (m == 10 && d < 15)))

calendarMarker :: Int -> Int -> Int -> String
calendarMarker y m d = if beforeReform y m d then " J" else "  "

monthName :: Int -> String
monthName m = fromMaybe "???" (lookup m (zip [1 ..] months))
  where months = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun"
                 , "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]

printDate :: Eclipse -> String
printDate e =
  padLeft 2 (show (eOrdinal e)) ++ ". " ++ padLeft 2 (show (eDay e)) ++ " "
    ++ monthName (eMonth e) ++ " " ++ show (eYear e)
    ++ calendarMarker (eYear e) (eMonth e) (eDay e) ++ "  "

printSpectrum :: [(Int, Int)] -> String
printSpectrum = unwords . map term
  where
    term (p, w) = (if p == 0 then "silence" else show p)
                  ++ (if w > 1 then 'x' : show w else "")

printKind :: MutationKind -> String
printKind (Commutation cat) = "commutation " ++ padRight 7 (categoryName cat)
printKind Permutation       = "permutation " ++ padRight 7 "order"

signed :: Int -> String
signed i = (if i >= 0 then "+" else "") ++ show i

-- ============================================================
-- XI. EDITIONS
-- ============================================================

-- Each edition is a list of lines, enumerated from the model; no bounds
-- are written.

epigraph :: [String]
epigraph =
  [ "Nulle archive sans dehors."
  , "-- Jacques Derrida, Mal d'archive, Galilee, 1995, page 26"
  , "--" ]

manifestationsEdition :: [String]
manifestationsEdition =
  epigraph ++ [show n ++ ". " ++ t | n <- ordinals, Just t <- [manifestation n]]

sarosEdition :: [String]
sarosEdition =
  epigraph ++
  [ printDate e ++ padRight 9 (eclipseTypeName (eType e)) ++ t
  | e <- sarosTable, Just t <- [manifestation (eOrdinal e)] ]

glossematicEdition :: [String]
glossematicEdition =
  epigraph ++ ["expression-form / content-form", "--"] ++
  [ printDate e
      ++ "[" ++ o ++ ": " ++ w ++ " / " ++ v ++ " / " ++ a ++ "]  "
      ++ padRight 9 (eclipseTypeName (eType e))
      ++ "gamma " ++ writeGamma (eGamma e) ++ "  ->  " ++ t
  | e <- sarosTable
  , Just t <- [manifestation (eOrdinal e)]
  , Just (Cell w v a o) <- [selection (eOrdinal e)] ]

mutationEdition :: [String]
mutationEdition =
  epigraph ++ ["mutation: the chain held, one cell exchanged", "--"]
  ++ [ padRight 8 (categoryName cat) ++ "stride " ++ padLeft 2 (show (stride cat))
         ++ "  interval " ++ padLeft 3 (show years) ++ " years"
     | cat <- categories, Just years <- [characteristicInterval cat] ]
  ++ ["--"]
  ++ [ "from " ++ show anchor ++ ". " ++ t | Just t <- [manifestation anchor] ]
  ++ [ "  " ++ printKind kind ++ "-> " ++ printDate e
         ++ padRight 9 (eclipseTypeName (eType e))
         ++ "gamma " ++ writeGamma (eGamma e) ++ "  "
         ++ signed years ++ "y  " ++ t
     | (kind, n2, years) <- mutations anchor
     , Just (e, t) <- [signFunction n2] ]

soundingEdition :: [String]
soundingEdition =
  epigraph
  ++ [ "drone A2 " ++ show droneHz
         ++ " Hz; partial = alphabet position mod 12; noun, verb, adverb"
     , "--" ]
  ++ [ padRight 13 w ++ printSpectrum (spectrum w)
         ++ (if touchesFundamental w then "" else "   [no fundamental]")
     | w <- lexicalWords ]
  ++ ["--"]
  ++ [ padLeft 2 (show n) ++ ". " ++ padLeft 2 (show g) ++ "  "
         ++ part (cellNoun c) ++ " | " ++ part (cellVerb c)
         ++ " | " ++ part (cellAdverb c)
     | (n, c) <- cells, Just g <- [grounding n] ]
  where part w = w ++ " " ++ printSpectrum (spectrum w)

data Edition = Manifestations | Saros | Glossematic | Mutation | Sounding
  deriving (Eq, Show)

editions :: [Edition]
editions = [Manifestations, Saros, Glossematic, Mutation, Sounding]

editionName :: Edition -> String
editionName Manifestations = "manifestations"
editionName Saros          = "saros"
editionName Glossematic    = "glossematic"
editionName Mutation       = "mutation"
editionName Sounding       = "sounding"

editionLines :: Edition -> [String]
editionLines Manifestations = manifestationsEdition
editionLines Saros          = sarosEdition
editionLines Glossematic    = glossematicEdition
editionLines Mutation       = mutationEdition
editionLines Sounding       = soundingEdition

-- ============================================================
-- XII. EDITION CHECKS
-- ============================================================

-- The generator derives everything from the inventory; these checks hold
-- the derived edition to the numbers this artwork asserts of itself.

distinct :: Eq a => [a] -> Bool
distinct xs = length (nub xs) == length xs

countOf :: (Int -> Bool) -> Int
countOf p = length (filter p ordinals)

-- | Every paradigm holds distinct words, every word has its lexicon entry,
--   every lexicon entry is a word of the grid. (Contiguous indices and the
--   fixed set of four categories are guaranteed here by the types.)
inventoryValid :: Bool
inventoryValid =
  all (distinct . invariants) categories
  && all (\m -> any (`functive` metaWord m) lexicalCategories) lexiconMeta
  && all (\w -> any ((== w) . metaWord) lexiconMeta) lexicalWords

editionShape :: Bool
editionShape =
  expressionSchema ==
    ( ["apertures", "auguries", "apparitions"], ["align", "thicken", "emerge"]
    , ["rhythmically", "vertically", "recursively", "now"], ["suffix", "prefix"] )

cardinalityValid :: Bool
cardinalityValid = systemCardinality == 72

uniquePoems :: Bool
uniquePoems = length texts == 72 && distinct texts
  where texts = mapMaybe poem ordinals

eclipseCoverage :: Bool
eclipseCoverage = sort (map eOrdinal sarosTable) == ordinals

-- | Selection enumerates ordinals in ascending order and decodes each
--   ordinal to the same cell it was encoded from; nothing outside 1..72
--   decodes. (Prolog also rejects 1.5 and x; here the type rules them out.)
selectionValid :: Bool
selectionValid =
  sort ordinals == ordinals
  && all (\(n, c) -> selection n == Just c) cells
  && all (\n -> (selection n >>= encode) == Just n) ordinals
  && isNothing (poem 0) && isNothing (poem 73)

markedCounts :: Bool
markedCounts =
  countOf deictic == 18 && countOf autonomous == 54
  && countOf (onCell (\c -> cellAdverb c == "now" && cellOrder c == "prefix")) == 9
  && countOf (onCell (\c -> cellAdverb c == "now" && cellOrder c == "suffix")) == 9
  && countOf tactile == 24 && countOf germanicAlignment == 6
  && countOf bodilyBreak == 36

anchorValid :: Bool
anchorValid =
  saros anchor == Just (Eclipse 48 2026 8 12 Total 8977)
  && manifestation anchor == Just "now, apertures emerge"
  && poemsOf "now, apertures emerge" == [anchor]

boundariesValid :: Bool
boundariesValid =
  poem 1  == Just "apertures align rhythmically"
  && poem 36 == Just "apparitions emerge now"
  && poem 37 == Just "rhythmically, apertures align"
  && poem 72 == Just "now, apparitions emerge"

-- | The essay's intervals and its anchor commutation, derived not asserted.
mutationValid :: Bool
mutationValid =
  stride Adverb == 1  && characteristicInterval Adverb == Just 18
  && stride Verb == 4  && characteristicInterval Verb == Just 72
  && stride Noun == 12 && characteristicInterval Noun == Just 216
  && stride Order == 36 && characteristicInterval Order == Just 649
  && [ (n2, y) | (n2, old, _) <- commutation Noun 48, old == "apertures"
               , Just y <- [sarosYear n2] ] == [(60, 2242), (72, 2459)]
  && [ n2 | (n2, _, _) <- commutation Verb 48 ] == [40, 44]
  && [ n2 | (n2, _, _) <- commutation Adverb 48 ] == [45, 46, 47]
  && (12, "prefix", "suffix") `elem` permutation 48
  && (Permutation, 12, -649) `elem` mutations 48
  -- Every mutation registers on the content plane.
  && and [ n1 == n2 || y /= 0 | n1 <- ordinals, (_, n2, y) <- mutations n1 ]
  -- Each commutation is its own inverse.
  && and [ (a, y, x) `elem` commutation cat b
         | cat <- lexicalCategories, a <- ordinals
         , (b, x, y) <- commutation cat a ]

-- | The sounding claims that survive the literal rule, plus the two findings.
soundingValid :: Bool
soundingValid =
  spectrum "now" == [(2, 1), (3, 1), (11, 1)]
  && sort fundamentalFree
       == sort [w | w <- lexicalWords, register w == Just Germanic]
  && partialWeight "thicken" 8 == 2 && partialWeight "emerge" 5 == 3
  && partialWeight "rhythmically" 1 == 4 && partialWeight "vertically" 1 == 2
  && partialWeight "recursively" 1 == 1
  && length (spectrum "align") == 5
  -- Every noun opens on the fundamental.
  && all touchesFundamental (invariants Noun)
  && all (\n -> grounding n /= Just 0) ordinals
  -- The least grounded lines are exactly ones where both body cells sound.
  && all (\n -> grounding n /= Just least || germanicAlignment n) ordinals
  -- The deictic lines are exactly those whose adverb is unanchored.
  && filter (onCell (not . touchesFundamental . cellAdverb)) ordinals
       == filter deictic ordinals
  where least = minimum (mapMaybe grounding ordinals)

checks :: [(String, Bool)]
checks =
  [ ("inventory", inventoryValid), ("edition_order", editionShape)
  , ("cardinality", cardinalityValid), ("unique_poems", uniquePoems)
  , ("eclipse_coverage", eclipseCoverage), ("selection", selectionValid)
  , ("marked_cells", markedCounts), ("anchor", anchorValid)
  , ("boundaries", boundariesValid), ("mutation", mutationValid)
  , ("sounding", soundingValid) ]

-- | Validate before printing, as sun.pl does.
selfCheck :: Either String ()
selfCheck = case find (not . snd) checks of
  Just (label, _) -> Left ("sun_check_failed(" ++ label ++ ")")
  Nothing         -> Right ()

-- ============================================================
-- XIII. ENTRY POINT
-- ============================================================

-- | Validate quietly, then print an edition (Saros by default).
main :: IO ()
main = do
  args <- getArgs
  case selfCheck of
    Left err -> hPutStrLn stderr err >> exitWith (ExitFailure 1)
    Right () -> case args of
      []     -> run Saros
      [name] | Just ed <- find ((== name) . editionName) editions -> run ed
      _      -> do
        hPutStrLn stderr ("usage: runghc Sun.hs ["
                          ++ intercalate " | " (map editionName editions) ++ "]")
        exitWith (ExitFailure 2)
  where run = mapM_ putStrLn . editionLines

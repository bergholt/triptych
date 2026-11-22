;;; ========================================================================
;;; SUN
;;; ========================================================================
;;;
;;; sun.scm
;;; Sun: 72 Poems for the Solar Eclipse of August 12th 2026
;;; After the glossematic and acoustic architecture of https://bergholt.net/sun
;;; A Scheme realisation of sun.pl (github.com/bergholt/triptych, MIT license).
;;;
;;; Portable Scheme: no imports, no SRFIs, nothing beyond the core of R5RS
;;; and R7RS-small (and exit, to report a failed check). Tested with GNU
;;; Guile 3.0, Gauche 0.9.10 and BiwaScheme 0.8, so it runs in the online
;;; interpreters built on any of them.
;;;
;;; RUN    : guile sun.scm   |   gosh sun.scm   |   any R7RS Scheme
;;; ONLINE : paste the whole file into an online Scheme and run it.
;;; EDITION: set by (define edition 'saros) below: manifestations, saros,
;;;          glossematic, mutation or sounding.
;;;
;;; Translation notes.
;;;   Scheme is where Prolog's relations become lists. A cell of the grid is
;;;   a list of four indices, one per category. A Prolog predicate that fails
;;;   becomes a procedure that returns #f: (selection 0) is #f, as poem(0, _)
;;;   has no solution. The grid with its ordinal unbound is `cells`, the
;;;   inventory enumerated in the order Prolog finds the solutions; poems-of
;;;   runs a poem backwards to its ordinal by searching it.
;;;
;;;   The other direction, a bound ordinal, is `selection`, which decodes by
;;;   the same stride formula that `encode` uses, so the two cannot drift
;;;   apart; the checks hold them to each other.
;;;
;;;   Nothing numerical is written into the generator. Cardinalities are the
;;;   lengths of the inventory lists, strides are multiplied from them,
;;;   intervals are read from the Saros table, spectra are counted from the
;;;   letters. The eleven checks of sun.pl's self_check then hold the derived
;;;   values to the numbers the work asserts, before anything is printed. A
;;;   failing check prints sun_check_failed(label) and exits with status 1.
;;;
;;;   Gamma is stored as an integer in ten-thousandths (-1.5356 is -15356),
;;;   the precision the Prolog table and printer use, so no floating-point
;;;   formatting is involved.
;;;
;;;   The inventory order is part of the artwork: changing it changes eclipse
;;;   assignments. Astronomical data and the epigraph are retained from the
;;;   original; the checks validate structure, not external accuracy. ASCII
;;;   output; dates use the original Julian/Gregorian catalogue convention.
;;;
;;; Two findings the sounding rule yields that the essay does not state:
;;;   'recursively' touches partial 1 once (its final y, 25 mod 12);
;;;   'thicken' never touches partial 1 at all (t h i c k e n = 8 8 9 3 11 5 2).
;;; The words that leave the drone hanging are therefore exactly the two
;;; Germanic cells. The sounding check asserts that equivalence. Under a
;;; literal mod 12 the letter l (12) yields partial 0, printed as a silence.

;;; The edition printed: manifestations, saros, glossematic, mutation, sounding
(define edition 'saros)

;;; ============================================================
;;; LIST UTILITIES (defined here, so the file needs no library)
;;; ============================================================

(define (keep pred lst)
  (cond ((null? lst) '())
        ((pred (car lst)) (cons (car lst) (keep pred (cdr lst))))
        (else (keep pred (cdr lst)))))

;; The recursive utilities are written with if rather than and/or: some
;; interpreters expand and/or so that a recursive call in them is evaluated
;; twice, which makes the recursion exponential.
(define (all? pred lst)
  (cond ((null? lst) #t)
        ((pred (car lst)) (all? pred (cdr lst)))
        (else #f)))

(define (some? pred lst)
  (cond ((null? lst) #f)
        ((pred (car lst)) #t)
        (else (some? pred (cdr lst)))))

(define (count-of pred lst) (length (keep pred lst)))

;; 0, 1, ..., n-1
(define (range n)
  (let loop ((i (- n 1)) (acc '()))
    (if (< i 0) acc (loop (- i 1) (cons i acc)))))

;; The position of x in lst, counted from 0, or #f
(define (position x lst)
  (let loop ((lst lst) (i 0))
    (cond ((null? lst) #f)
          ((equal? (car lst) x) i)
          (else (loop (cdr lst) (+ i 1))))))

(define (append-map f lst) (apply append (map f lst)))

(define (distinct? lst)
  (cond ((null? lst) #t)
        ((member (car lst) (cdr lst)) #f)
        (else (distinct? (cdr lst)))))

;; Insertion sort by a less-than
(define (sort-by less? lst)
  (define (insert x sorted)
    (cond ((null? sorted) (list x))
          ((less? x (car sorted)) (cons x sorted))
          (else (cons (car sorted) (insert x (cdr sorted))))))
  (let loop ((lst lst) (acc '()))
    (if (null? lst) acc (loop (cdr lst) (insert (car lst) acc)))))

(define (join strings separator)
  (cond ((null? strings) "")
        ((null? (cdr strings)) (car strings))
        (else (string-append (car strings) separator
                             (join (cdr strings) separator)))))

;;; ============================================================
;;; I. GLOSSEMATIC INVENTORY AND STRATA
;;; ============================================================

;; The four strata of the work (Hjelmslev, Prolegomena, def. 16-20).
(define glossematic-strata
  '((expression form paradigmatic-syntagmatic-grid)
    (expression substance overtone-field-above-a2)
    (content form saros-126-ordinal-series)
    (content substance solar-eclipse-ephemeris)))

;; The categories, in the order sun.pl declares them.
(define categories '(noun verb adverb order))
;; The paradigms that hold words (order holds syntagms).
(define lexical '(noun verb adverb))

;; Paradigmatic invariants: 3 x 3 x 4 = 36 commutable selections.
;; Syntagmatic invariants: 2 orders permute 36 to 72.
;; The position of each word in its list is its index.
(define inventory
  '((noun   "apertures" "auguries" "apparitions")
    (verb   "align" "thicken" "emerge")
    (adverb "rhythmically" "vertically" "recursively" "now")
    (order  "suffix" "prefix")))

(define (invariants cat) (cdr (assq cat inventory)))
(define (invariant cat index) (list-ref (invariants cat) index))
(define (functive? cat word) (if (member word (invariants cat)) #t #f))

;; Diachronic precursor (2011): the grid this one regularises.
(define precursor-2011
  '((noun   "interpretants" "phases" "conscience")
    (verb   "flow" "infer" "projects")
    (adverb "rhythmically" "conclusively" "vertically")))

;;; ============================================================
;;; II. EXPRESSION-FORM: CARDINALITY AND STRIDE
;;; ============================================================

(define (cardinality cat) (length (invariants cat)))

(define system-cardinality (apply * (map cardinality categories)))

;; "The categories are not distinguished by part of speech. They are
;;  distinguished by how far a commutation carries you through the cycle."
;; Stride: ordinals moved by one step within a category. Derived.
(define (stride cat)
  (case cat
    ((adverb) 1)
    ((verb)   (cardinality 'adverb))
    ((noun)   (* (cardinality 'adverb) (cardinality 'verb)))
    ((order)  (* (cardinality 'adverb) (cardinality 'verb) (cardinality 'noun)))))

;;; ============================================================
;;; III. SELECTION (BOTH DIRECTIONS)
;;; ============================================================

;; A cell is a list of four indices, in category order.
(define (cell-index cell cat) (list-ref cell (position cat categories)))
(define (cell-word cell cat) (invariant cat (cell-index cell cat)))

;; A bound ordinal decodes directly; outside the grid there is no cell.
(define (selection n)
  (if (and (integer? n) (<= 1 n system-cardinality))
      (let* ((k  (- n 1))
             (oi (quotient k (stride 'order)))
             (r1 (remainder k (stride 'order)))
             (ni (quotient r1 (stride 'noun)))
             (r2 (remainder r1 (stride 'noun)))
             (vi (quotient r2 (stride 'verb)))
             (ai (remainder r2 (stride 'verb))))
        (list ni vi ai oi))
      #f))

;; A cell encodes by the same strides, so the mapping cannot drift
;; between directions.
(define (encode cell)
  (+ 1 (apply + (map (lambda (cat) (* (cell-index cell cat) (stride cat)))
                     categories))))

;; An unbound ordinal enumerates the inventory and encodes, in the order
;; Prolog would find the solutions: order, noun, verb, adverb.
;; Each entry is (ordinal . cell).
(define cells
  (append-map
   (lambda (oi)
     (append-map
      (lambda (ni)
        (append-map
         (lambda (vi)
           (map (lambda (ai)
                  (let ((cell (list ni vi ai oi)))
                    (cons (encode cell) cell)))
                (range (cardinality 'adverb))))
         (range (cardinality 'verb))))
      (range (cardinality 'noun))))
   (range (cardinality 'order))))

(define ordinals (map car cells))

;;; ============================================================
;;; IV. SYNTAGMATIC FUNCTION AND MANIFESTATION
;;; ============================================================

(define (syntagmatic-function cell)
  (let ((o (cell-word cell 'order))
        (n (cell-word cell 'noun))
        (v (cell-word cell 'verb))
        (a (cell-word cell 'adverb)))
    (cond ((string=? o "suffix") (list n " " v " " a))
          ((string=? o "prefix") (list a ", " n " " v))
          (else #f))))

(define (manifestation-of cell)
  (let ((parts (syntagmatic-function cell)))
    (and parts (apply string-append parts))))

;; The poem of an ordinal, or #f where there is none.
(define (manifestation n)
  (let ((cell (selection n)))
    (and cell (manifestation-of cell))))

(define poem manifestation)

;; poem(N, Text) with Text bound: the poem read back to its ordinal(s).
(define (poems-of text)
  (map car (keep (lambda (entry) (equal? (manifestation-of (cdr entry)) text))
                 cells)))

;;; ============================================================
;;; V. CONTENT-FORM: SAROS 126 (1179 J - 2459)
;;; ============================================================

;; ordinal, year, month, day, type, gamma (ten-thousandths)
(define saros-table
  '(( 1 1179  3 10 partial -15356)
    ( 2 1197  3 20 partial -14880)
    ( 3 1215  3 31 partial -14344)
    ( 4 1233  4 11 partial -13717)
    ( 5 1251  4 22 partial -13041)
    ( 6 1269  5  2 partial -12291)
    ( 7 1287  5 14 partial -11500)
    ( 8 1305  5 24 partial -10658)
    ( 9 1323  6  4 annular  -9799)
    (10 1341  6 14 annular  -8922)
    (11 1359  6 26 annular  -8038)
    (12 1377  7  6 annular  -7168)
    (13 1395  7 17 annular  -6318)
    (14 1413  7 27 annular  -5506)
    (15 1431  8  8 annular  -4737)
    (16 1449  8 18 annular  -4030)
    (17 1467  8 29 annular  -3391)
    (18 1485  9  9 annular  -2811)
    (19 1503  9 20 annular  -2314)
    (20 1521  9 30 annular  -1892)
    (21 1539 10 12 annular  -1551)
    (22 1557 10 22 annular  -1266)
    (23 1575 11  2 annular  -1061)
    (24 1593 11 22 annular   -906)
    (25 1611 12  4 annular   -803)
    (26 1629 12 14 annular   -725)
    (27 1647 12 26 annular   -675)
    (28 1666  1  5 annular   -624)
    (29 1684  1 16 annular   -565)
    (30 1702  1 28 annular   -484)
    (31 1720  2  8 annular   -375)
    (32 1738  2 18 annular   -211)
    (33 1756  3  1 annular      6)
    (34 1774  3 12 annular    284)
    (35 1792  3 22 annular    618)
    (36 1810  4  4 annular   1031)
    (37 1828  4 14 hybrid    1498)
    (38 1846  4 25 hybrid    2038)
    (39 1864  5  6 hybrid    2622)
    (40 1882  5 17 total     3269)
    (41 1900  5 28 total     3943)
    (42 1918  6  8 total     4658)
    (43 1936  6 19 total     5389)
    (44 1954  6 30 total     6135)
    (45 1972  7 10 total     6872)
    (46 1990  7 22 total     7597)
    (47 2008  8  1 total     8307)
    (48 2026  8 12 total     8977)
    (49 2044  8 23 total     9613)
    (50 2062  9  3 partial  10191)
    (51 2080  9 13 partial  10723)
    (52 2098  9 25 partial  11184)
    (53 2116 10  6 partial  11589)
    (54 2134 10 17 partial  11931)
    (55 2152 10 28 partial  12213)
    (56 2170 11  8 partial  12426)
    (57 2188 11 18 partial  12591)
    (58 2206 12  1 partial  12711)
    (59 2224 12 11 partial  12791)
    (60 2242 12 22 partial  12836)
    (61 2261  1  2 partial  12873)
    (62 2279  1 13 partial  12899)
    (63 2297  1 23 partial  12940)
    (64 2315  2  5 partial  12991)
    (65 2333  2 15 partial  13087)
    (66 2351  2 27 partial  13209)
    (67 2369  3  9 partial  13392)
    (68 2387  3 20 partial  13624)
    (69 2405  3 31 partial  13928)
    (70 2423  4 11 partial  14282)
    (71 2441  4 21 partial  14706)
    (72 2459  5  3 partial  15188)))

(define (eclipse-ordinal e) (list-ref e 0))
(define (eclipse-year e)    (list-ref e 1))
(define (eclipse-month e)   (list-ref e 2))
(define (eclipse-day e)     (list-ref e 3))
(define (eclipse-type e)    (list-ref e 4))
(define (eclipse-gamma e)   (list-ref e 5))

;; The eclipse of an ordinal, or #f.
(define (saros n) (assv n saros-table))
(define (saros-year n) (eclipse-year (saros n)))

;;; ============================================================
;;; VI. SEMIOTIC FUNCTION
;;; ============================================================

;; The solidarity of expression-form (the text) and content-form (an
;; eclipse): (eclipse . text), or #f.
(define (sign-function n)
  (let ((e (saros n)) (t (poem n)))
    (and e t (cons e t))))

;;; ============================================================
;;; VII. MUTATION: COMMUTATION AND PERMUTATION
;;; ============================================================

;; Hjelmslev (def. 54-56). Hold every category but one and exchange the
;; member of that one. Results: (target-ordinal old-member new-member), in
;; ascending ordinal order.
(define (exchanges cat n1)
  (let ((c1 (selection n1)))
    (if (not c1)
        '()
        (map (lambda (entry)
               (list (car entry) (cell-word c1 cat) (cell-word (cdr entry) cat)))
             (keep (lambda (entry)
                     (let ((c2 (cdr entry)))
                       (and (all? (lambda (k)
                                    (or (eq? k cat)
                                        (string=? (cell-word c1 k) (cell-word c2 k))))
                                  categories)
                            (not (string=? (cell-word c1 cat) (cell-word c2 cat))))))
                   cells)))))

;; A commutation exchanges one member of one paradigm with the chain held.
(define (commutation cat n1) (if (eq? cat 'order) '() (exchanges cat n1)))
;; A permutation shifts the chain with the paradigms held.
(define (permutation n1) (exchanges 'order n1))

;; A signed displacement in years through the Saros.
(define (displacement n1 n2) (- (saros-year n2) (saros-year n1)))

;; A mutation registers on the content plane as a displacement in years:
;; (kind target years), kind being (commutation cat) or (permutation).
(define (mutations n1)
  (append
   (append-map (lambda (cat)
                 (map (lambda (move)
                        (list (list 'commutation cat) (car move)
                              (displacement n1 (car move))))
                      (commutation cat n1)))
               lexical)
   (map (lambda (move)
          (list (list 'permutation) (car move) (displacement n1 (car move))))
        (permutation n1))))

;; The characteristic interval of a category: the years one minimal step
;; through it carries the reader, measured from the series' first member.
(define (characteristic-interval cat) (displacement 1 (+ 1 (stride cat))))

;;; ============================================================
;;; VIII. MARKED CELLS: REGISTER, DEIXIS, BODY
;;; ============================================================

;; word, register (latinate covers Greek), reference, mode
(define lexicon-meta
  '(("apertures"    latinate autonomous event)
    ("auguries"     latinate autonomous event)
    ("apparitions"  latinate autonomous event)
    ("align"        latinate autonomous action)
    ("emerge"       latinate autonomous action)
    ("rhythmically" latinate autonomous manner)
    ("vertically"   latinate autonomous manner)
    ("recursively"  latinate autonomous manner)
    ("thicken"      germanic autonomous tactile-density)
    ("now"          germanic deictic    temporal-utterance)))

(define (register word)
  (let ((entry (assoc word lexicon-meta)))
    (and entry (cadr entry))))

;; A property of the words of the cell an ordinal selects; #f outside.
(define (on-cell pred)
  (lambda (n)
    (let ((cell (selection n)))
      (and cell (pred cell)))))

(define (word-is cat word)
  (lambda (cell) (string=? (cell-word cell cat) word)))

;; 18 require a present body; 54 can be read from anywhere.
(define deictic?    (on-cell (word-is 'adverb "now")))
(define autonomous? (on-cell (lambda (cell) (not ((word-is 'adverb "now") cell)))))
;; 24 import tactile density (Old English thiccian).
(define tactile?    (on-cell (word-is 'verb "thicken")))
;; 36 where the body breaks through measurement (24 + 18 - 6).
(define bodily-break?
  (on-cell (lambda (cell) (or ((word-is 'verb "thicken") cell)
                              ((word-is 'adverb "now") cell)))))
;; 6 where the two Germanic cells align.
(define germanic-alignment?
  (on-cell (lambda (cell) (and ((word-is 'verb "thicken") cell)
                               ((word-is 'adverb "now") cell)))))

;; 12 August 2026: "now, apertures emerge"
(define anchor 48)

;;; ============================================================
;;; IX. EXPRESSION-SUBSTANCE: THE OVERTONE FIELD ABOVE A2
;;; ============================================================

;; Each letter selects a partial of the drone by alphabet position
;; modulo twelve; letters are weighted by recurrence within the word;
;; the line is parsed noun, verb, adverb whatever its syntactic order.

(define drone-hz 110)

;; The partial of a letter, or #f for anything that is not a..z.
(define (letter-partial ch)
  (let ((position (+ 1 (- (char->integer ch) (char->integer #\a)))))
    (and (<= 1 position 26) (modulo position 12))))

(define (partial-hz partial) (* partial drone-hz))

;; Ascending (partial . weight) pairs.
(define (spectrum word)
  (let ((partials (keep (lambda (p) p)
                        (map (lambda (i) (letter-partial (string-ref word i)))
                             (range (string-length word))))))
    (keep (lambda (pair) (> (cdr pair) 0))
          (map (lambda (p) (cons p (count-of (lambda (q) (= p q)) partials)))
               (range 12)))))

(define (partial-weight word partial)
  (let ((pair (assv partial (spectrum word))))
    (if pair (cdr pair) 0)))

(define (touches-fundamental? word) (> (partial-weight word 1) 0))

;; The ten words, category by category, in inventory order.
(define lexical-words (append-map invariants lexical))

;; Words that never return the line to the drone.
(define fundamental-free
  (keep (lambda (w) (not (touches-fundamental? w))) lexical-words))

;; The cell's three words: noun, verb, adverb.
(define (lexical-words-of cell)
  (map (lambda (cat) (cell-word cell cat)) lexical))

(define (sounding n)
  (let ((cell (selection n)))
    (and cell (map (lambda (w) (cons w (spectrum w))) (lexical-words-of cell)))))

;; How many letters of a line sound the fundamental.
(define (grounding n)
  (let ((cell (selection n)))
    (and cell (apply + (map (lambda (w) (partial-weight w 1))
                            (lexical-words-of cell))))))

;;; ============================================================
;;; X. FORMATTING
;;; ============================================================

(define (spaces k) (if (> k 0) (make-string k #\space) ""))
(define (pad-left s width) (string-append (spaces (- width (string-length s))) s))
(define (pad-right s width) (string-append s (spaces (- width (string-length s)))))
(define (num n) (number->string n))

;; Gamma to four decimals, from the stored ten-thousandths.
(define (write-gamma g)
  (let* ((mag (abs g))
         (frac (num (remainder mag 10000))))
    (string-append (if (< g 0) "-" "") (num (quotient mag 10000)) "."
                   (make-string (- 4 (string-length frac)) #\0) frac)))

(define (before-reform? y m d)
  (or (< y 1582) (and (= y 1582) (or (< m 10) (and (= m 10) (< d 15))))))

(define month-names
  '("Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"))

;; The date column of an eclipse row: "48. 12 Aug 2026    "
(define (print-date e)
  (let ((y (eclipse-year e)) (m (eclipse-month e)) (d (eclipse-day e)))
    (string-append (pad-left (num (eclipse-ordinal e)) 2) ". "
                   (pad-left (num d) 2) " " (list-ref month-names (- m 1)) " "
                   (num y) (if (before-reform? y m d) " J" "  ") "  ")))

(define (print-type e) (pad-right (symbol->string (eclipse-type e)) 9))

;; "1 4 5x2 ...": partial 0 is a silence.
(define (print-spectrum spec)
  (join (map (lambda (pair)
               (string-append (if (= (car pair) 0) "silence" (num (car pair)))
                              (if (> (cdr pair) 1)
                                  (string-append "x" (num (cdr pair)))
                                  "")))
             spec)
        " "))

(define (print-kind kind)
  (if (eq? (car kind) 'commutation)
      (string-append "commutation " (pad-right (symbol->string (cadr kind)) 7))
      (string-append "permutation " (pad-right "order" 7))))

(define (signed i) (string-append (if (>= i 0) "+" "") (num i)))

(define (line s) (display s) (newline))

;;; ============================================================
;;; XI. EDITIONS
;;; ============================================================

;; Each edition is a list of lines, enumerated from the model; no bounds
;; are written.

(define epigraph
  '("Nulle archive sans dehors."
    "-- Jacques Derrida, Mal d'archive, Galilee, 1995, page 26"
    "--"))

(define (manifestations-edition)
  (append epigraph
          (map (lambda (n) (string-append (num n) ". " (poem n)))
               (keep poem ordinals))))

(define (saros-edition)
  (append epigraph
          (map (lambda (e)
                 (string-append (print-date e) (print-type e)
                                (poem (eclipse-ordinal e))))
               (keep (lambda (e) (poem (eclipse-ordinal e))) saros-table))))

(define (glossematic-edition)
  (append epigraph
          '("expression-form / content-form" "--")
          (map (lambda (e)
                 (let ((cell (selection (eclipse-ordinal e))))
                   (string-append
                    (print-date e)
                    "[" (cell-word cell 'order) ": " (cell-word cell 'noun)
                    " / " (cell-word cell 'verb) " / " (cell-word cell 'adverb) "]  "
                    (print-type e) "gamma " (write-gamma (eclipse-gamma e))
                    "  ->  " (poem (eclipse-ordinal e)))))
               (keep (lambda (e) (poem (eclipse-ordinal e))) saros-table))))

(define (mutation-edition)
  (append
   epigraph
   '("mutation: the chain held, one cell exchanged" "--")
   (map (lambda (cat)
          (string-append (pad-right (symbol->string cat) 8)
                         "stride " (pad-left (num (stride cat)) 2)
                         "  interval " (pad-left (num (characteristic-interval cat)) 3)
                         " years"))
        categories)
   (list "--" (string-append "from " (num anchor) ". " (poem anchor)))
   (map (lambda (m)
          (let* ((kind (car m)) (n2 (cadr m)) (years (caddr m))
                 (sign (sign-function n2)) (e (car sign)))
            (string-append "  " (print-kind kind) "-> " (print-date e)
                           (print-type e) "gamma " (write-gamma (eclipse-gamma e))
                           "  " (signed years) "y  " (cdr sign))))
        (mutations anchor))))

(define (sounding-edition)
  (define (part w) (string-append w " " (print-spectrum (spectrum w))))
  (append
   epigraph
   (list (string-append "drone A2 " (num drone-hz)
                        " Hz; partial = alphabet position mod 12; noun, verb, adverb")
         "--")
   (map (lambda (w)
          (string-append (pad-right w 13) (print-spectrum (spectrum w))
                         (if (touches-fundamental? w) "" "   [no fundamental]")))
        lexical-words)
   (list "--")
   (map (lambda (entry)
          (let ((n (car entry)) (cell (cdr entry)))
            (string-append (pad-left (num n) 2) ". "
                           (pad-left (num (grounding n)) 2) "  "
                           (join (map part (lexical-words-of cell)) " | "))))
        cells)))

(define editions
  (list (cons 'manifestations manifestations-edition)
        (cons 'saros saros-edition)
        (cons 'glossematic glossematic-edition)
        (cons 'mutation mutation-edition)
        (cons 'sounding sounding-edition)))

;;; ============================================================
;;; XII. EDITION CHECKS
;;; ============================================================

;; The generator derives everything from the inventory; these checks hold
;; the derived edition to the numbers this artwork asserts of itself.

;; Every paradigm holds distinct words, every lexicon entry is a word of
;; the grid, every word of the grid has its lexicon entry.
(define (inventory-valid)
  (and (all? (lambda (cat) (distinct? (invariants cat))) categories)
       (all? (lambda (entry)
               (some? (lambda (cat) (functive? cat (car entry))) lexical))
             lexicon-meta)
       (all? (lambda (w) (if (assoc w lexicon-meta) #t #f)) lexical-words)))

(define (edition-shape)
  (equal? (map invariants categories)
          '(("apertures" "auguries" "apparitions")
            ("align" "thicken" "emerge")
            ("rhythmically" "vertically" "recursively" "now")
            ("suffix" "prefix"))))

(define (cardinality-valid) (= system-cardinality 72))

;; 72 poems, all different.
(define (unique-poems)
  (let ((texts (keep (lambda (t) t) (map poem ordinals))))
    (and (= (length texts) 72) (distinct? texts))))

;; The sorted ordinals of the Saros table are the ordinals of the grid.
(define (eclipse-coverage)
  (equal? (sort-by < (map eclipse-ordinal saros-table)) ordinals))

;; Selection enumerates ordinals in ascending order and decodes each
;; ordinal to the same cell it was encoded from; nothing else decodes.
(define (selection-valid)
  (and (equal? (sort-by < ordinals) ordinals)
       (all? (lambda (entry) (equal? (selection (car entry)) (cdr entry))) cells)
       (all? (lambda (entry) (= (encode (cdr entry)) (car entry))) cells)
       (not (poem 0)) (not (poem 73)) (not (poem 1.5)) (not (poem 'x))))

(define (marked-counts)
  (and (= (count-of deictic? ordinals) 18)
       (= (count-of autonomous? ordinals) 54)
       (= (count-of (on-cell (lambda (cell) (and ((word-is 'adverb "now") cell)
                                                 ((word-is 'order "prefix") cell))))
                    ordinals) 9)
       (= (count-of (on-cell (lambda (cell) (and ((word-is 'adverb "now") cell)
                                                 ((word-is 'order "suffix") cell))))
                    ordinals) 9)
       (= (count-of tactile? ordinals) 24)
       (= (count-of germanic-alignment? ordinals) 6)
       (= (count-of bodily-break? ordinals) 36)))

(define (anchor-valid)
  (and (equal? (saros anchor) '(48 2026 8 12 total 8977))
       (equal? (poem anchor) "now, apertures emerge")
       (equal? (poems-of "now, apertures emerge") (list anchor))))

(define (boundaries-valid)
  (and (equal? (poem 1) "apertures align rhythmically")
       (equal? (poem 36) "apparitions emerge now")
       (equal? (poem 37) "rhythmically, apertures align")
       (equal? (poem 72) "now, apparitions emerge")))

;; The essay's intervals and its anchor commutation, derived not asserted.
(define (mutation-valid)
  (and (equal? (map stride '(adverb verb noun order)) '(1 4 12 36))
       (equal? (map characteristic-interval '(adverb verb noun order))
               '(18 72 216 649))
       (equal? (map (lambda (move) (list (car move) (saros-year (car move))))
                    (keep (lambda (move) (string=? (cadr move) "apertures"))
                          (commutation 'noun 48)))
               '((60 2242) (72 2459)))
       (equal? (map car (commutation 'verb 48)) '(40 44))
       (equal? (map car (commutation 'adverb 48)) '(45 46 47))
       (if (member '(12 "prefix" "suffix") (permutation 48)) #t #f)
       (if (member '((permutation) 12 -649) (mutations 48)) #t #f)
       ;; Every mutation registers on the content plane.
       (all? (lambda (n1)
               (all? (lambda (m) (or (= n1 (cadr m)) (not (= 0 (caddr m)))))
                     (mutations n1)))
             ordinals)
       ;; Each commutation is its own inverse.
       (all? (lambda (cat)
               (all? (lambda (a)
                       (all? (lambda (move)
                               (if (member (list a (caddr move) (cadr move))
                                           (commutation cat (car move)))
                                   #t #f))
                             (commutation cat a)))
                     ordinals))
             lexical)))

;; The sounding claims that survive the literal rule, plus the two findings.
(define (sounding-valid)
  (let* ((groundings (map grounding ordinals))
         (least (apply min groundings)))
    (and (equal? (spectrum "now") '((2 . 1) (3 . 1) (11 . 1)))
         (equal? (sort-by string<? fundamental-free)
                 (sort-by string<? (keep (lambda (w) (eq? (register w) 'germanic))
                                         lexical-words)))
         (= (partial-weight "thicken" 8) 2)
         (= (partial-weight "emerge" 5) 3)
         (= (partial-weight "rhythmically" 1) 4)
         (= (partial-weight "vertically" 1) 2)
         (= (partial-weight "recursively" 1) 1)
         (= (length (spectrum "align")) 5)
         ;; Every noun opens on the fundamental.
         (all? touches-fundamental? (invariants 'noun))
         (all? (lambda (g) (> g 0)) groundings)
         ;; The least grounded lines are exactly ones where both body cells sound.
         (all? germanic-alignment?
               (keep (lambda (n) (= (grounding n) least)) ordinals))
         ;; The deictic lines are exactly those whose adverb is unanchored.
         (equal? (keep (on-cell (lambda (cell)
                                  (not (touches-fundamental? (cell-word cell 'adverb)))))
                       ordinals)
                 (keep deictic? ordinals)))))

(define checks
  (list (cons "inventory" inventory-valid)
        (cons "edition_order" edition-shape)
        (cons "cardinality" cardinality-valid)
        (cons "unique_poems" unique-poems)
        (cons "eclipse_coverage" eclipse-coverage)
        (cons "selection" selection-valid)
        (cons "marked_cells" marked-counts)
        (cons "anchor" anchor-valid)
        (cons "boundaries" boundaries-valid)
        (cons "mutation" mutation-valid)
        (cons "sounding" sounding-valid)))

;; The label of the first check that does not hold, or #f.
(define (self-check)
  (let loop ((checks checks))
    (cond ((null? checks) #f)
          (((cdar checks)) (loop (cdr checks)))
          (else (caar checks)))))

;;; ============================================================
;;; XIII. ENTRY POINT
;;; ============================================================

;; Validate quietly, then print the edition.
(let ((failed (self-check))
      (chosen (assq edition editions)))
  (cond (failed
         (line (string-append "sun_check_failed(" failed ")"))
         (exit 1))
        ((not chosen)
         (line "edition: one of manifestations, saros, glossematic, mutation, sounding")
         (exit 2))
        (else (for-each line ((cdr chosen))))))

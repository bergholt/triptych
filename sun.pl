/*
========================================================================
SUN
========================================================================

sun.pl
Sun: 72 Poems for the Solar Eclipse of August 12th 2026
After the glossematic and acoustic architecture of https://bergholt.net/sun

Portable Edinburgh/ISO-style Prolog. No libraries, no dialect builtins:
list utilities and a stable sort are defined locally.

ONLINE : paste this entire file into OneCompiler or JDoodle (Prolog), Run.
SWISH  : remove the final initialization directive; enter main. as the goal.
SWI    : swipl -q -s sun.pl -t halt
GNU    : gprolog --consult-file sun.pl --entry-goal halt

Queries (omit ?- in SWISH's goal box):
  poem(N, Text).                     poem(N, 'now, apertures emerge').
  selection(N, Noun, Verb, Adverb, Order).
  deictic(N).  tactile(N).  bodily_break(N).  germanic_alignment(N).
  commutation(noun, 48, N2, Old, New).   permutation(48, N2, O1, O2).
  mutation(Kind, 48, N2, Years).         characteristic_interval(Cat, S, Y).
  spectrum(now, S).  fundamental_free(W).  sounding(48, Spectra).
  self_check.
  print_saros_edition.  print_glossematic_edition.  print_manifestations.
  print_mutation_edition.  print_sounding_edition.

The inventory order is part of the artwork: changing it changes eclipse
assignments. Everything numerical about the edition (strides, intervals,
counts, spectra) is derived from the inventory and the Saros table, and
self_check then holds the derived values to the ones the work asserts.
Astronomical data and the epigraph are retained from the original; the
checks validate structure, not external accuracy. ASCII source; dates use
the original Julian/Gregorian catalogue convention.

Two findings the sounding rule yields that the essay does not state:
  'recursively' touches partial 1 once (its final y, 25 mod 12);
  'thicken' never touches partial 1 at all (t h i c k e n = 8 8 9 3 11 5 2).
The words that leave the drone hanging are therefore exactly the two
Germanic cells. self_check asserts that equivalence. Under a literal
mod 12 the letter l (12) yields partial 0, printed as a silence.
*/

% ============================================================
% I. GLOSSEMATIC INVENTORY AND STRATA
% ============================================================

plane(expression).
plane(content).
stratum(form).
stratum(substance).

% The four strata of the work (Hjelmslev, Prolegomena, def. 16-20):
glossematic_stratum(expression, form,      paradigmatic_syntagmatic_grid).
glossematic_stratum(expression, substance, overtone_field_above_a2).
glossematic_stratum(content,    form,      saros_126_ordinal_series).
glossematic_stratum(content,    substance, solar_eclipse_ephemeris).

category(noun).
category(verb).
category(adverb).
category(order).

% Paradigmatic invariants: 3 x 3 x 4 = 36 commutable selections.
invariant(noun,   0, apertures).
invariant(noun,   1, auguries).
invariant(noun,   2, apparitions).
invariant(verb,   0, align).
invariant(verb,   1, thicken).
invariant(verb,   2, emerge).
invariant(adverb, 0, rhythmically).
invariant(adverb, 1, vertically).
invariant(adverb, 2, recursively).
invariant(adverb, 3, now).
% Syntagmatic invariants: 2 orders permute 36 to 72.
invariant(order,  0, suffix).
invariant(order,  1, prefix).

functive(Category, Value) :- invariant(Category, _, Value).

% Diachronic precursor (2011): the grid this one regularises.
precursor_2011(noun,   [interpretants, phases, conscience]).
precursor_2011(verb,   [flow, infer, projects]).
precursor_2011(adverb, [rhythmically, conclusively, vertically]).

% ============================================================
% II. EXPRESSION-FORM: CARDINALITY AND STRIDE
% ============================================================

collect(Category, Values) :-
    findall(Index-Value, invariant(Category, Index, Value), Pairs),
    keysort(Pairs, Sorted), pair_values(Sorted, Values).
pair_values([], []).
pair_values([_-V|Rest], [V|Vs]) :- pair_values(Rest, Vs).

expression_schema(Nouns, Verbs, Adverbs, Orders) :-
    collect(noun, Nouns), collect(verb, Verbs),
    collect(adverb, Adverbs), collect(order, Orders).

cardinality(Category, Count) :- collect(Category, Vs), length(Vs, Count).
system_cardinality(Count) :-
    cardinality(noun, N), cardinality(verb, V),
    cardinality(adverb, A), cardinality(order, O), Count is N*V*A*O.

% "The categories are not distinguished by part of speech. They are
%  distinguished by how far a commutation carries you through the cycle."
% Stride: ordinals moved by one step within a category. Derived.
stride(adverb, 1).
stride(verb,   S) :- cardinality(adverb, A), S is A.
stride(noun,   S) :- cardinality(adverb, A), cardinality(verb, V), S is A*V.
stride(order,  S) :- cardinality(adverb, A), cardinality(verb, V),
                     cardinality(noun, N), S is A*V*N.

% ============================================================
% III. SELECTION (RELATIONAL, BIDIRECTIONAL)
% ============================================================

% A bound ordinal decodes directly. An unbound ordinal, or a query by
% words, enumerates the inventory and encodes; both paths share one
% formula, so the mapping cannot drift between directions.
selection(Ordinal, Noun, Verb, Adverb, Order) :-
    stride(order, OS), stride(noun, NS), stride(verb, VS),
    (   integer(Ordinal)
    ->  system_cardinality(Count), Ordinal >= 1, Ordinal =< Count,
        K is Ordinal-1,
        OI is K // OS,  R1 is K mod OS,
        NI is R1 // NS, R2 is R1 mod NS,
        VI is R2 // VS, AI is R2 mod VS,
        invariant(order, OI, Order), invariant(noun, NI, Noun),
        invariant(verb, VI, Verb), invariant(adverb, AI, Adverb)
    ;   var(Ordinal),
        invariant(order, OI, Order), invariant(noun, NI, Noun),
        invariant(verb, VI, Verb), invariant(adverb, AI, Adverb),
        Ordinal is 1 + OI*OS + NI*NS + VI*VS + AI
    ).

ordinal(Ordinal) :- selection(Ordinal, _, _, _, _).

% ============================================================
% IV. SYNTAGMATIC FUNCTION AND MANIFESTATION
% ============================================================

syntagmatic_function(suffix, N, V, A, [N, ' ', V, ' ', A]).
syntagmatic_function(prefix, N, V, A, [A, ', ', N, ' ', V]).

manifestation(Ordinal, Text) :-
    selection(Ordinal, N, V, A, O),
    syntagmatic_function(O, N, V, A, Parts), atom_join(Parts, Text).
poem(Ordinal, Text) :- manifestation(Ordinal, Text).

atom_join([], '').
atom_join([X|Xs], Atom) :- atom_join(Xs, Rest), atom_concat(X, Rest, Atom).

% ============================================================
% V. CONTENT-FORM: SAROS 126 (1179 J - 2459)
% ============================================================

saros( 1, 1179,  3, 10, partial, -1.5356).
saros( 2, 1197,  3, 20, partial, -1.4880).
saros( 3, 1215,  3, 31, partial, -1.4344).
saros( 4, 1233,  4, 11, partial, -1.3717).
saros( 5, 1251,  4, 22, partial, -1.3041).
saros( 6, 1269,  5,  2, partial, -1.2291).
saros( 7, 1287,  5, 14, partial, -1.1500).
saros( 8, 1305,  5, 24, partial, -1.0658).
saros( 9, 1323,  6,  4, annular, -0.9799).
saros(10, 1341,  6, 14, annular, -0.8922).
saros(11, 1359,  6, 26, annular, -0.8038).
saros(12, 1377,  7,  6, annular, -0.7168).
saros(13, 1395,  7, 17, annular, -0.6318).
saros(14, 1413,  7, 27, annular, -0.5506).
saros(15, 1431,  8,  8, annular, -0.4737).
saros(16, 1449,  8, 18, annular, -0.4030).
saros(17, 1467,  8, 29, annular, -0.3391).
saros(18, 1485,  9,  9, annular, -0.2811).
saros(19, 1503,  9, 20, annular, -0.2314).
saros(20, 1521,  9, 30, annular, -0.1892).
saros(21, 1539, 10, 12, annular, -0.1551).
saros(22, 1557, 10, 22, annular, -0.1266).
saros(23, 1575, 11,  2, annular, -0.1061).
saros(24, 1593, 11, 22, annular, -0.0906).
saros(25, 1611, 12,  4, annular, -0.0803).
saros(26, 1629, 12, 14, annular, -0.0725).
saros(27, 1647, 12, 26, annular, -0.0675).
saros(28, 1666,  1,  5, annular, -0.0624).
saros(29, 1684,  1, 16, annular, -0.0565).
saros(30, 1702,  1, 28, annular, -0.0484).
saros(31, 1720,  2,  8, annular, -0.0375).
saros(32, 1738,  2, 18, annular, -0.0211).
saros(33, 1756,  3,  1, annular,  0.0006).
saros(34, 1774,  3, 12, annular,  0.0284).
saros(35, 1792,  3, 22, annular,  0.0618).
saros(36, 1810,  4,  4, annular,  0.1031).
saros(37, 1828,  4, 14, hybrid,   0.1498).
saros(38, 1846,  4, 25, hybrid,   0.2038).
saros(39, 1864,  5,  6, hybrid,   0.2622).
saros(40, 1882,  5, 17, total,    0.3269).
saros(41, 1900,  5, 28, total,    0.3943).
saros(42, 1918,  6,  8, total,    0.4658).
saros(43, 1936,  6, 19, total,    0.5389).
saros(44, 1954,  6, 30, total,    0.6135).
saros(45, 1972,  7, 10, total,    0.6872).
saros(46, 1990,  7, 22, total,    0.7597).
saros(47, 2008,  8,  1, total,    0.8307).
saros(48, 2026,  8, 12, total,    0.8977).
saros(49, 2044,  8, 23, total,    0.9613).
saros(50, 2062,  9,  3, partial,  1.0191).
saros(51, 2080,  9, 13, partial,  1.0723).
saros(52, 2098,  9, 25, partial,  1.1184).
saros(53, 2116, 10,  6, partial,  1.1589).
saros(54, 2134, 10, 17, partial,  1.1931).
saros(55, 2152, 10, 28, partial,  1.2213).
saros(56, 2170, 11,  8, partial,  1.2426).
saros(57, 2188, 11, 18, partial,  1.2591).
saros(58, 2206, 12,  1, partial,  1.2711).
saros(59, 2224, 12, 11, partial,  1.2791).
saros(60, 2242, 12, 22, partial,  1.2836).
saros(61, 2261,  1,  2, partial,  1.2873).
saros(62, 2279,  1, 13, partial,  1.2899).
saros(63, 2297,  1, 23, partial,  1.2940).
saros(64, 2315,  2,  5, partial,  1.2991).
saros(65, 2333,  2, 15, partial,  1.3087).
saros(66, 2351,  2, 27, partial,  1.3209).
saros(67, 2369,  3,  9, partial,  1.3392).
saros(68, 2387,  3, 20, partial,  1.3624).
saros(69, 2405,  3, 31, partial,  1.3928).
saros(70, 2423,  4, 11, partial,  1.4282).
saros(71, 2441,  4, 21, partial,  1.4706).
saros(72, 2459,  5,  3, partial,  1.5188).

saros_year(N, Y)       :- saros(N, Y, _, _, _, _).
saros_date(N, Y, M, D) :- saros(N, Y, M, D, _, _).
saros_type(N, T)       :- saros(N, _, _, _, T, _).

% ============================================================
% VI. SEMIOTIC FUNCTION
% ============================================================

% The solidarity of expression-form (Text) and content-form (an eclipse).
sign_function(N, Y, M, D, Type, Gamma, Text) :-
    saros(N, Y, M, D, Type, Gamma), manifestation(N, Text).
saros_poem(N, Y, M, D, Type, Text) :-
    sign_function(N, Y, M, D, Type, _, Text).

% ============================================================
% VII. MUTATION: COMMUTATION AND PERMUTATION
% ============================================================

% Hjelmslev (def. 54-56). A commutation exchanges one member of one
% paradigm with the chain held; a permutation shifts the chain with the
% paradigms held. Both are written as two selections sharing variables,
% so the test is the unification itself.
commutation(noun, N1, N2, Old, New) :-
    selection(N1, Old, V, A, O), selection(N2, New, V, A, O), Old \== New.
commutation(verb, N1, N2, Old, New) :-
    selection(N1, N, Old, A, O), selection(N2, N, New, A, O), Old \== New.
commutation(adverb, N1, N2, Old, New) :-
    selection(N1, N, V, Old, O), selection(N2, N, V, New, O), Old \== New.
permutation(N1, N2, Old, New) :-
    selection(N1, N, V, A, Old), selection(N2, N, V, A, New), Old \== New.

% A mutation registers on the content plane as a signed displacement
% in years through the Saros.
mutation(commutation(Cat), N1, N2, Years) :-
    commutation(Cat, N1, N2, _, _), displacement(N1, N2, Years).
mutation(permutation, N1, N2, Years) :-
    permutation(N1, N2, _, _), displacement(N1, N2, Years).
displacement(N1, N2, Years) :-
    saros_year(N1, Y1), saros_year(N2, Y2), Years is Y2-Y1.

% The characteristic interval of a category: the years one minimal step
% through it carries the reader, measured from the series' first member.
characteristic_interval(Cat, Stride, Years) :-
    category(Cat), stride(Cat, Stride),
    Next is 1+Stride, displacement(1, Next, Years).

% ============================================================
% VIII. MARKED CELLS: REGISTER, DEIXIS, BODY
% ============================================================

% word, register (latinate covers Greek), reference, mode
lexicon_meta(apertures,    latinate, autonomous, event).
lexicon_meta(auguries,     latinate, autonomous, event).
lexicon_meta(apparitions,  latinate, autonomous, event).
lexicon_meta(align,        latinate, autonomous, action).
lexicon_meta(emerge,       latinate, autonomous, action).
lexicon_meta(rhythmically, latinate, autonomous, manner).
lexicon_meta(vertically,   latinate, autonomous, manner).
lexicon_meta(recursively,  latinate, autonomous, manner).
lexicon_meta(thicken,      germanic, autonomous, tactile_density).
lexicon_meta(now,          germanic, deictic,    temporal_utterance).

register(Word, Register) :- lexicon_meta(Word, Register, _, _).
manifestation_registers(N, [NR, VR, AR]) :-
    selection(N, Noun, Verb, Adverb, _),
    register(Noun, NR), register(Verb, VR), register(Adverb, AR).

% 18 require a present body; 54 can be read from anywhere.
deictic(N)    :- selection(N, _, _, now, _).
autonomous(N) :- selection(N, _, _, A, _), A \== now.
% 24 import tactile density (Old English thiccian).
tactile(N)    :- selection(N, _, thicken, _, _).
% 36 where the body breaks through measurement (24 + 18 - 6).
bodily_break(N) :-
    selection(N, _, V, A, _), ( V == thicken -> true ; A == now ).
% 6 where the two Germanic cells align.
germanic_alignment(N) :- selection(N, _, thicken, now, _).

% 12 August 2026: "now, apertures emerge"
anchor(48).
anchor_manifestation(Text) :- anchor(N), manifestation(N, Text).

% ============================================================
% IX. EXPRESSION-SUBSTANCE: THE OVERTONE FIELD ABOVE A2
% ============================================================

% Each letter selects a partial of the drone by alphabet position
% modulo twelve; letters are weighted by recurrence within the word;
% the line is parsed noun, verb, adverb whatever its syntactic order.
drone_hz(110).
letter_partial(Char, Partial) :-
    char_code(Char, Code), Code >= 97, Code =< 122,   % a..z
    Partial is (Code - 96) mod 12.
partial_hz(Partial, Hz) :- drone_hz(F), Hz is Partial*F.

% spectrum(Word, Spectrum): ascending Partial-Weight pairs.
spectrum(Word, Spectrum) :-
    atom_chars(Word, Chars),
    findall(P, (member_of(C, Chars), letter_partial(C, P)), Ps),
    stable_sort(Ps, Sorted), run_lengths(Sorted, Spectrum).
run_lengths([], []).
run_lengths([P|Ps], [P-W|Rest]) :-
    take_run(P, Ps, 1, W, Tail), run_lengths(Tail, Rest).
take_run(P, [Q|Ps], W0, W, Tail) :-
    P =:= Q, !, W1 is W0+1, take_run(P, Ps, W1, W, Tail).
take_run(_, Tail, W, W, Tail).

partial_weight(Word, Partial, Weight) :-
    spectrum(Word, S),
    ( member_of(Partial-Weight, S) -> true ; Weight = 0 ).
touches_fundamental(Word) :- partial_weight(Word, 1, W), W > 0.
% Words that never return the line to the drone.
fundamental_free(Word) :-
    category(Cat), Cat \== order, functive(Cat, Word),
    \+ touches_fundamental(Word).

sounding(N, [Noun-NS, Verb-VS, Adverb-AS]) :-
    selection(N, Noun, Verb, Adverb, _),
    spectrum(Noun, NS), spectrum(Verb, VS), spectrum(Adverb, AS).
% How many letters of a line sound the fundamental.
grounding(N, Count) :-
    selection(N, Noun, Verb, Adverb, _),
    partial_weight(Noun, 1, A), partial_weight(Verb, 1, B),
    partial_weight(Adverb, 1, C), Count is A+B+C.

% ============================================================
% X. PRINTERS
% ============================================================

epigraph :-
    write('Nulle archive sans dehors.'), nl,
    write('-- Jacques Derrida, Mal d''archive, Galilee, 1995, page 26'), nl,
    write('--'), nl.

% Failure-driven loops enumerate from the model; no bounds are written.
print_manifestations :-
    epigraph,
    ( manifestation(N, Text), write(N), write('. '), write(Text), nl, fail
    ; true ).

print_saros_edition :-
    epigraph,
    ( sign_function(N, Y, M, D, Type, _, Text),
      print_date(N, Y, M, D), pad_right(Type, 9), write(Text), nl, fail
    ; true ).

print_glossematic_edition :-
    epigraph, write('expression-form / content-form'), nl, write('--'), nl,
    ( sign_function(N, Y, M, D, Type, Gamma, Text),
      selection(N, Noun, Verb, Adverb, Order),
      print_date(N, Y, M, D),
      write('['), write(Order), write(': '), write(Noun), write(' / '),
      write(Verb), write(' / '), write(Adverb), write(']  '),
      pad_right(Type, 9), write('gamma '), write_gamma(Gamma),
      write('  ->  '), write(Text), nl, fail
    ; true ).

print_mutation_edition :-
    epigraph, write('mutation: the chain held, one cell exchanged'), nl,
    write('--'), nl,
    ( characteristic_interval(Cat, Stride, Years),
      pad_right(Cat, 8), write('stride '), pad_left(Stride, 2),
      write('  interval '), pad_left(Years, 3), write(' years'), nl, fail
    ; true ),
    write('--'), nl,
    anchor(A), manifestation(A, AText),
    write('from '), write(A), write('. '), write(AText), nl,
    ( mutation(Kind, A, N2, Years),
      sign_function(N2, Y, M, D, Type, Gamma, Text),
      write('  '), print_kind(Kind), write('-> '),
      print_date(N2, Y, M, D), pad_right(Type, 9),
      write('gamma '), write_gamma(Gamma), write('  '),
      ( Years >= 0 -> write('+') ; true ), write(Years), write('y  '),
      write(Text), nl, fail
    ; true ).
print_kind(commutation(Cat)) :- write('commutation '), pad_right(Cat, 7).
print_kind(permutation)      :- write('permutation '), pad_right(order, 7).

print_sounding_edition :-
    epigraph, drone_hz(F), write('drone A2 '), write(F),
    write(' Hz; partial = alphabet position mod 12; noun, verb, adverb'), nl,
    write('--'), nl,
    ( category(Cat), Cat \== order, functive(Cat, Word), spectrum(Word, S),
      pad_right(Word, 13), print_spectrum(S),
      ( touches_fundamental(Word) -> true ; write('   [no fundamental]') ),
      nl, fail
    ; true ),
    write('--'), nl,
    ( sounding(N, [Noun-NS, Verb-VS, Adverb-AS]), grounding(N, G),
      pad_left(N, 2), write('. '), pad_left(G, 2), write('  '),
      write(Noun), write(' '), print_spectrum(NS), write(' | '),
      write(Verb), write(' '), print_spectrum(VS), write(' | '),
      write(Adverb), write(' '), print_spectrum(AS), nl, fail
    ; true ).
print_spectrum([]).
print_spectrum([P-W|Rest]) :-
    ( P =:= 0 -> write('silence') ; write(P) ),
    ( W > 1 -> write('x'), write(W) ; true ),
    ( Rest == [] -> true ; write(' ') ), print_spectrum(Rest).

print_date(N, Y, M, D) :-
    month_name(M, Month), calendar_marker(Y, M, D, Calendar),
    pad_left(N, 2), write('. '), pad_left(D, 2), write(' '),
    write(Month), write(' '), write(Y), write(Calendar), write('  ').

% ============================================================
% XI. FORMATTING AND LOCAL UTILITIES
% ============================================================

pad_left(Value, Width) :-
    term_to_atom_clean(Value, Atom), atom_length(Atom, Len),
    Padding is Width-Len, emit_spaces(Padding), write(Atom).
pad_right(Value, Width) :-
    term_to_atom_clean(Value, Atom), atom_length(Atom, Len),
    write(Atom), Padding is Width-Len, emit_spaces(Padding).
emit_spaces(N) :-
    ( N =< 0 -> true ; write(' '), Next is N-1, emit_spaces(Next) ).
term_to_atom_clean(Value, Atom) :-
    ( atom(Value) -> Atom = Value
    ; number(Value), number_codes(Value, Codes), atom_codes(Atom, Codes) ).

% Gamma to four decimals, independent of the dialect's float printing.
write_gamma(G) :-
    Scaled is round(abs(G)*10000), Int is Scaled // 10000, Frac is Scaled mod 10000,
    ( G < 0 -> write('-') ; true ), write(Int), write('.'),
    ( Frac < 10 -> write('000') ; Frac < 100 -> write('00')
    ; Frac < 1000 -> write('0') ; true ), write(Frac).

calendar_marker(Y, M, D, Marker) :-
    ( before_reform(Y, M, D) -> Marker = ' J' ; Marker = '  ' ).
before_reform(Y, M, D) :-
    ( Y < 1582 -> true
    ; Y =:= 1582, ( M < 10 -> true ; M =:= 10, D < 15 ) ).

month_name( 1, 'Jan').  month_name( 2, 'Feb').  month_name( 3, 'Mar').
month_name( 4, 'Apr').  month_name( 5, 'May').  month_name( 6, 'Jun').
month_name( 7, 'Jul').  month_name( 8, 'Aug').  month_name( 9, 'Sep').
month_name(10, 'Oct').  month_name(11, 'Nov').  month_name(12, 'Dec').

member_of(X, [X|_]).
member_of(X, [_|T]) :- member_of(X, T).
% Stable sort keeping duplicates (ISO keysort on X-X pairs).
stable_sort(List, Sorted) :-
    pair_self(List, Pairs), keysort(Pairs, SortedPairs),
    pair_values(SortedPairs, Sorted).
pair_self([], []).
pair_self([X|Xs], [X-X|Ps]) :- pair_self(Xs, Ps).
min_of([X|Xs], Min) :- min_loop(Xs, X, Min).
min_loop([], Min, Min).
min_loop([X|Xs], Acc, Min) :-
    ( X < Acc -> min_loop(Xs, X, Min) ; min_loop(Xs, Acc, Min) ).

% ============================================================
% XII. EDITION CHECKS
% ============================================================

% The generator derives everything from the inventory; these checks hold
% the derived edition to the numbers this artwork asserts of itself.
check(Goal, Label) :-
    ( call(Goal) -> true ; throw(error(sun_check_failed(Label), self_check/0)) ).

inventory_valid :-
    findall(C, category(C), Cs), sort(Cs, [adverb,noun,order,verb]),
    \+ ( invariant(C, _, _), \+ category(C) ),
    \+ ( category(C), \+ category_valid(C) ),
    \+ ( lexicon_meta(W, _, _, _), \+ functive(_, W) ),
    \+ ( functive(C, W), C \== order, \+ lexicon_meta(W, _, _, _) ).
category_valid(C) :-
    findall(I-V, invariant(C, I, V), Pairs), keysort(Pairs, Sorted),
    contiguous(Sorted, 0), pair_values(Sorted, Values),
    sort(Values, Unique), length(Values, Count), length(Unique, Count).
contiguous([], _).
contiguous([Index-Value|Rest], Expected) :-
    integer(Index), Index =:= Expected, atom(Value),
    Next is Expected+1, contiguous(Rest, Next).
edition_shape :-
    expression_schema([apertures,auguries,apparitions],
      [align,thicken,emerge], [rhythmically,vertically,recursively,now],
      [suffix,prefix]).
unique_poems :-
    findall(Text, poem(_, Text), Texts), length(Texts, 72),
    sort(Texts, Unique), length(Unique, 72).
eclipse_coverage :-
    findall(N, saros(N, _, _, _, _, _), Actual), stable_sort(Actual, Sorted),
    findall(N, ordinal(N), Expected), Sorted == Expected.
% selection enumerates ordinals in ascending order and decodes each
% ordinal to the same cell it was encoded from.
selection_valid :-
    findall(N, ordinal(N), Ns), stable_sort(Ns, Ns),
    \+ ( selection(N, Noun, Verb, Adverb, Order),
         \+ ( integer(N), selection(N, Noun, Verb, Adverb, Order) ) ),
    \+ poem(0, _), \+ poem(73, _), \+ poem(1.5, _), \+ poem(x, _).
marked_counts :-
    findall(N, deictic(N), Ds), length(Ds, 18),
    findall(N, autonomous(N), Us), length(Us, 54),
    findall(N, selection(N, _, _, now, prefix), Ps), length(Ps, 9),
    findall(N, selection(N, _, _, now, suffix), Ss), length(Ss, 9),
    findall(N, tactile(N), Ts), length(Ts, 24),
    findall(N, germanic_alignment(N), Gs), length(Gs, 6),
    findall(N, bodily_break(N), Bs), length(Bs, 36),
    sort(Bs, UBs), length(UBs, 36).
anchor_valid :-
    anchor(N), saros(N, 2026, 8, 12, total, _),
    manifestation(N, 'now, apertures emerge'),
    poem(N2, 'now, apertures emerge'), N2 == N.
boundaries_valid :-
    poem(1, 'apertures align rhythmically'),
    poem(36, 'apparitions emerge now'),
    poem(37, 'rhythmically, apertures align'),
    poem(72, 'now, apparitions emerge').
% The essay's intervals and its anchor commutation, derived not asserted.
mutation_valid :-
    characteristic_interval(adverb, 1, 18),
    characteristic_interval(verb, 4, 72),
    characteristic_interval(noun, 12, 216),
    characteristic_interval(order, 36, 649),
    findall(N2-Y, (commutation(noun, 48, N2, apertures, _), saros_year(N2, Y)),
            Pairs), stable_sort(Pairs, [60-2242, 72-2459]),
    findall(N2, commutation(verb, 48, N2, _, _), Vs), stable_sort(Vs, [40, 44]),
    findall(N2, commutation(adverb, 48, N2, _, _), As), stable_sort(As, [45,46,47]),
    permutation(48, 12, prefix, suffix), mutation(permutation, 48, 12, -649),
    % Every mutation registers on the content plane.
    \+ ( mutation(_, N1, N2, Years), N1 \== N2, Years =:= 0 ),
    % Each commutation is its own inverse.
    \+ ( commutation(Cat, A, B, X, Y), \+ commutation(Cat, B, A, Y, X) ).
% The sounding claims that survive the literal rule, plus the two findings.
sounding_valid :-
    spectrum(now, [2-1, 3-1, 11-1]),
    findall(W, fundamental_free(W), Free), stable_sort(Free, F1),
    findall(W, register(W, germanic), Germ), stable_sort(Germ, G1), F1 == G1,
    partial_weight(thicken, 8, 2), partial_weight(emerge, 5, 3),
    partial_weight(rhythmically, 1, 4), partial_weight(vertically, 1, 2),
    partial_weight(recursively, 1, 1),
    spectrum(align, S), length(S, 5),
    % Every noun opens on the fundamental.
    \+ ( functive(noun, Noun), \+ touches_fundamental(Noun) ),
    findall(N, grounding(N, 0), []),
    % The least grounded lines are exactly ones where both body cells sound.
    findall(G, grounding(_, G), Gs), min_of(Gs, Min),
    \+ ( grounding(N, Min), \+ germanic_alignment(N) ),
    % The deictic lines are exactly those whose adverb is unanchored.
    findall(N, (selection(N, _, _, A, _), \+ touches_fundamental(A)), Un),
    findall(N, deictic(N), Ds), stable_sort(Un, U1), stable_sort(Ds, D1), U1 == D1.

self_check :-
    check(inventory_valid, inventory), check(edition_shape, edition_order),
    check(system_cardinality(72), cardinality), check(unique_poems, unique_poems),
    check(eclipse_coverage, eclipse_coverage), check(selection_valid, selection),
    check(marked_counts, marked_cells), check(anchor_valid, anchor),
    check(boundaries_valid, boundaries), check(mutation_valid, mutation),
    check(sounding_valid, sounding).

% ============================================================
% XIII. ENTRY POINT
% ============================================================

% Validate quietly, then print the edition. Remove only the directive
% below for interactive SWISH use. Change the printer to select an edition.
main :- self_check, print_saros_edition.

:- initialization(main).

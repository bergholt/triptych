/*
========================================================================
THE GLOSSEMATIC SUN
========================================================================

This program constructs a precise crossroads between programming,
astronomy, and structural linguistics. Grounded in Louis Hjelmslev's
glossematics, it treats Prolog itself as a semiotic apparatus: predicates
define an expression-plane of linguistic invariants, while Saros Series 126
provides a content-plane of historical solar eclipses.

The seventy-two poems are not written one by one, but inferred from a
closed combinatorial system of nouns, verbs, adverbs, and syntactic orders.
Through ordinal identity, each manifestation is coupled to one eclipse.
The result is a literate, generative matrix in which code, poem, and archive
coincide: language becomes queryable structure, and astronomy becomes a
formal index of poetic manifestation.
========================================================================
*/

% sun_glossematic_onecompiler.pl
% Sun: 72 Poems for the Solar Eclipse
% Kasper Bergholt, 2026
%
% OneCompiler / GNU Prolog compatible version.

% ============================================================
% I. GLOSSEMATIC INVENTORY
% ============================================================

plane(expression).
plane(content).

stratum(form).
stratum(substance).

category(noun).
category(verb).
category(adverb).
category(order).

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

invariant(order,  0, suffix).
invariant(order,  1, prefix).

functive(Category, Value) :-
    invariant(Category, _, Value).

% ============================================================
% II. EXPRESSION-FORM
% ============================================================

expression_schema(Nouns, Verbs, Adverbs, Orders) :-
    collect(noun, Nouns),
    collect(verb, Verbs),
    collect(adverb, Adverbs),
    collect(order, Orders).

collect(Category, Values) :-
    collect_loop(Category, 0, Values).

collect_loop(Category, Index, [Value|Rest]) :-
    invariant(Category, Index, Value),
    !,
    Next is Index + 1,
    collect_loop(Category, Next, Rest).
collect_loop(_, _, []).

cardinality(Category, Count) :-
    collect(Category, Values),
    length(Values, Count).

system_cardinality(Count) :-
    cardinality(noun, N),
    cardinality(verb, V),
    cardinality(adverb, A),
    cardinality(order, O),
    Count is N * V * A * O.

% ============================================================
% III. SELECTION
% ============================================================

selection(Ordinal, Noun, Verb, Adverb, Order) :-
    integer(Ordinal),
    Ordinal >= 1,
    Ordinal =< 72,
    expression_schema(Nouns, Verbs, Adverbs, _Orders),
    (
        Ordinal =< 36
    ->
        K is Ordinal - 1,
        Order = suffix
    ;
        K is Ordinal - 37,
        Order = prefix
    ),
    decode_selection(K, Nouns, Verbs, Adverbs, Noun, Verb, Adverb).

decode_selection(K, Nouns, Verbs, Adverbs, Noun, Verb, Adverb) :-
    length(Adverbs, AdverbCount),
    length(Verbs, VerbCount),
    NounStride is VerbCount * AdverbCount,
    NounIndex is K // NounStride,
    Remainder is K mod NounStride,
    VerbIndex is Remainder // AdverbCount,
    AdverbIndex is Remainder mod AdverbCount,
    nth0(NounIndex, Nouns, Noun),
    nth0(VerbIndex, Verbs, Verb),
    nth0(AdverbIndex, Adverbs, Adverb).

% ============================================================
% IV. FUNCTION AND MANIFESTATION
% ============================================================

syntagmatic_function(suffix, Noun, Verb, Adverb, [Noun, ' ', Verb, ' ', Adverb]).
syntagmatic_function(prefix, Noun, Verb, Adverb, [Adverb, ', ', Noun, ' ', Verb]).

manifestation(Ordinal, Text) :-
    selection(Ordinal, Noun, Verb, Adverb, Order),
    syntagmatic_function(Order, Noun, Verb, Adverb, Parts),
    atom_join(Parts, Text).

poem(Ordinal, Text) :-
    manifestation(Ordinal, Text).

atom_join([X], X) :-
    !.
atom_join([X|Xs], Atom) :-
    atom_join(Xs, Rest),
    atom_concat(X, Rest, Atom).

% ============================================================
% V. CONTENT-FORM: SAROS 126
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

saros_year(Ordinal, Year) :-
    saros(Ordinal, Year, _, _, _, _).

saros_date(Ordinal, Year, Month, Day) :-
    saros(Ordinal, Year, Month, Day, _, _).

saros_type(Ordinal, Type) :-
    saros(Ordinal, _, _, _, Type, _).

% ============================================================
% VI. SEMIOTIC FUNCTION
% ============================================================

sign_function(Ordinal, Year, Month, Day, Type, Gamma, Text) :-
    saros(Ordinal, Year, Month, Day, Type, Gamma),
    manifestation(Ordinal, Text).

saros_poem(Ordinal, Year, Month, Day, Type, Text) :-
    sign_function(Ordinal, Year, Month, Day, Type, _Gamma, Text).

% ============================================================
% VII. MARKED CELLS
% ============================================================

deictic(Ordinal) :-
    selection(Ordinal, _, _, now, _).

register(apertures,    latinate).
register(auguries,     latinate).
register(apparitions,  latinate).
register(align,        latinate).
register(emerge,       latinate).
register(rhythmically, latinate).
register(vertically,   latinate).
register(recursively,  latinate).
register(thicken,      germanic).
register(now,          germanic).

manifestation_registers(Ordinal, Registers) :-
    selection(Ordinal, Noun, Verb, Adverb, _Order),
    register(Noun, NounRegister),
    register(Verb, VerbRegister),
    register(Adverb, AdverbRegister),
    Registers = [NounRegister, VerbRegister, AdverbRegister].

bodily_break(Ordinal) :-
    selection(Ordinal, _, thicken, _, _).
bodily_break(Ordinal) :-
    selection(Ordinal, _, _, now, _).

anchor(48).

anchor_manifestation(Text) :-
    anchor(Ordinal),
    manifestation(Ordinal, Text).

% ============================================================
% VIII. PRINTERS
% ============================================================

epigraph :-
    write('Nulle archive sans dehors.'), nl,
    write('-- Jacques Derrida, Mal d''archive, Galilee, 1995, page 26'), nl,
    write('--'), nl.

print_manifestations :-
    epigraph,
    print_manifestation_loop(1).

print_manifestation_loop(N) :-
    N > 72,
    !.
print_manifestation_loop(N) :-
    manifestation(N, Text),
    write(N),
    write('. '),
    write(Text),
    nl,
    N1 is N + 1,
    print_manifestation_loop(N1).

print_saros_edition :-
    epigraph,
    print_saros_loop(1).

print_saros_loop(N) :-
    N > 72,
    !.
print_saros_loop(N) :-
    sign_function(N, Year, Month, Day, Type, _Gamma, Text),
    month_name(Month, MonthName),
    calendar_marker(Year, Month, Day, Calendar),
    pad_left(N, 2),
    write('. '),
    pad_left(Day, 2),
    write(' '),
    write(MonthName),
    write(' '),
    write(Year),
    write(Calendar),
    write('  '),
    pad_right(Type, 9),
    write(Text),
    nl,
    N1 is N + 1,
    print_saros_loop(N1).

print_glossematic_edition :-
    epigraph,
    write('expression-form / content-form'), nl,
    write('--'), nl,
    print_glossematic_loop(1).

print_glossematic_loop(N) :-
    N > 72,
    !.
print_glossematic_loop(N) :-
    selection(N, Noun, Verb, Adverb, Order),
    sign_function(N, Year, Month, Day, Type, Gamma, Text),
    month_name(Month, MonthName),
    calendar_marker(Year, Month, Day, Calendar),
    pad_left(N, 2),
    write('. '),
    write('['),
    write(Order),
    write(': '),
    write(Noun),
    write(' / '),
    write(Verb),
    write(' / '),
    write(Adverb),
    write(']  '),
    pad_left(Day, 2),
    write(' '),
    write(MonthName),
    write(' '),
    write(Year),
    write(Calendar),
    write('  '),
    pad_right(Type, 9),
    write('gamma '),
    write(Gamma),
    write('  ->  '),
    write(Text),
    nl,
    N1 is N + 1,
    print_glossematic_loop(N1).

% ============================================================
% IX. FORMATTING
% ============================================================

pad_left(Value, Width) :-
    term_to_atom_clean(Value, Atom),
    atom_length(Atom, Length),
    Padding is Width - Length,
    emit_spaces(Padding),
    write(Atom).

pad_right(Value, Width) :-
    term_to_atom_clean(Value, Atom),
    atom_length(Atom, Length),
    write(Atom),
    Padding is Width - Length,
    emit_spaces(Padding).

emit_spaces(N) :-
    N =< 0,
    !.
emit_spaces(N) :-
    write(' '),
    N1 is N - 1,
    emit_spaces(N1).

term_to_atom_clean(Value, Value) :-
    atom(Value),
    !.
term_to_atom_clean(Value, Atom) :-
    integer(Value),
    !,
    number_codes(Value, Codes),
    atom_codes(Atom, Codes).
term_to_atom_clean(Value, Atom) :-
    float(Value),
    !,
    number_codes(Value, Codes),
    atom_codes(Atom, Codes).

calendar_marker(Y, M, D, ' J') :-
    before_reform(Y, M, D),
    !.
calendar_marker(_, _, _, '  ').

before_reform(Y, _, _) :-
    Y < 1582,
    !.
before_reform(1582, M, _) :-
    M < 10,
    !.
before_reform(1582, 10, D) :-
    D < 15.

month_name( 1, 'Jan').
month_name( 2, 'Feb').
month_name( 3, 'Mar').
month_name( 4, 'Apr').
month_name( 5, 'May').
month_name( 6, 'Jun').
month_name( 7, 'Jul').
month_name( 8, 'Aug').
month_name( 9, 'Sep').
month_name(10, 'Oct').
month_name(11, 'Nov').
month_name(12, 'Dec').

% ============================================================
% X. ENTRY POINT
% ============================================================

main :-
    print_saros_edition.

:- initialization(main).

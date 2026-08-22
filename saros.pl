% =====================================================================
% Sun| A Prolog Realization
% 3 nouns x 3 verbs x 4 adverbs x 2 syntactic orders = 72
% One variant for each eclipse in Saros 126 (1179-2459).
% Github source: https://github.com/bergholt/triptych - MIT license.
% =====================================================================

% --- Paradigm: noun ---

noun(apertures).
noun(apparitions).
noun(auguries).

% --- Paradigm: verb ---

verb(align).
verb(thicken).
verb(emerge).

% --- Paradigm: adverb ---

adverb(rhythmically).
adverb(vertically).
adverb(recursively).
adverb(now).

% --- Combination rule ---

variant(O, N, V, A) :-
    member(O, [0, 1]),
    noun(N),
    verb(V),
    adverb(A).

% --- Enumeration ---

run :-
    findall((O,N,V,A), variant(O,N,V,A), List),
    print_list(List, 1).

print_list([], _).
print_list([H|T], I) :-
    format('~d. ', [I]),
    print_variant(H),
    nl,
    NextI is I + 1,
    print_list(T, NextI).

print_variant((0, N, V, A)) :-
    format('~w ~w ~w', [N, V, A]).
print_variant((1, N, V, A)) :-
    format('~w, ~w ~w', [A, N, V]).

:- initialization(run).

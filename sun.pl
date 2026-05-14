% Sun — a Prolog realization of:
% https://bergholt.net/sun
%
% 3 nouns × 3 verbs × 4 adverbs × 2 syntactic orders = 72
% One variant for each eclipse in Saros 126 (1179–2459).

noun(apertures).
noun(auguries).
noun(apparitions).

verb(align).
verb(thicken).
verb(emerge).

adverb(rhythmically).
adverb(vertically).
adverb(recursively).
adverb(now).

variant(O, N, V, A) :-
    member(O, [0, 1]),
    noun(N),
    verb(V),
    adverb(A).

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

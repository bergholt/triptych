% =====================================================================
% A Prolog Realization of:
% https://bergholt.net/sun
%
% 3 nouns x 3 verbs x 4 adverbs x 2 syntactic orders = 72
% One variant for each eclipse in Saros 126 (1179-2459).
%
% Github source: https://github.com/bergholt/triptych - MIT license.
% Feel free to use for your own projects.
% =====================================================================

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

order(0).
order(1).

variant(O,N,V,A) :-
    order(O),
    noun(N),
    verb(V),
    adverb(A).

variant_text(0,N,V,A) :-
    write(N),
    write(' '),
    write(V),
    write(' '),
    write(A).

variant_text(1,N,V,A) :-
    write(A),
    write(', '),
    write(N),
    write(' '),
    write(V).

numbered_variant(I,O,N,V,A) :-
    findall((O0,N0,V0,A0), variant(O0,N0,V0,A0), Xs),
    nth1(I, Xs, (O,N,V,A)).

print_variant(I,O,N,V,A) :-
    write(I),
    write('. '),
    variant_text(O,N,V,A),
    nl.

print_variants :-
    numbered_variant(I,O,N,V,A),
    print_variant(I,O,N,V,A),
    fail.

print_variants.

count_variants(N) :-
    findall((O,Nn,V,A), variant(O,Nn,V,A), Xs),
    length(Xs, N).

run :-
    print_variants.

:- initialization(run).

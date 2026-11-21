% Sun | A Mercury realization
% 3 nouns x 3 verbs x 4 adverbs x 2 syntactic orders = 72.
% One variant for each eclipse in Saros 126 (1179-2459).
% Original Prolog source: https://github.com/bergholt/triptych (MIT license).
% and click Run. No input is needed.

:- module main.
:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module int.
:- import_module list.
:- import_module string.

:- type syntactic_order
    --->    adverb_last
    ;       adverb_first.

main(!IO) :-
    list.foldl2(print_order, [adverb_last, adverb_first], 1, _, !IO).

:- pred print_order(syntactic_order::in, int::in, int::out,
    io::di, io::uo) is det.

print_order(Order, !Number, !IO) :-
    Nouns = ["apertures", "apparitions", "auguries"],
    list.foldl2(print_noun(Order), Nouns, !Number, !IO).

:- pred print_noun(syntactic_order::in, string::in, int::in, int::out,
    io::di, io::uo) is det.

print_noun(Order, Noun, !Number, !IO) :-
    Verbs = ["align", "thicken", "emerge"],
    list.foldl2(print_verb(Order, Noun), Verbs, !Number, !IO).

:- pred print_verb(syntactic_order::in, string::in, string::in,
    int::in, int::out, io::di, io::uo) is det.

print_verb(Order, Noun, Verb, !Number, !IO) :-
    Adverbs = ["rhythmically", "vertically", "recursively", "now"],
    list.foldl2(print_variant(Order, Noun, Verb), Adverbs, !Number, !IO).

:- pred print_variant(syntactic_order::in, string::in, string::in,
    string::in, int::in, int::out, io::di, io::uo) is det.

print_variant(Order, Noun, Verb, Adverb, !Number, !IO) :-
    (
        Order = adverb_last,
        io.format("%d. %s %s %s\n",
            [i(!.Number), s(Noun), s(Verb), s(Adverb)], !IO)
    ;
        Order = adverb_first,
        io.format("%d. %s, %s %s\n",
            [i(!.Number), s(Adverb), s(Noun), s(Verb)], !IO)
    ),
    !:Number = !.Number + 1.

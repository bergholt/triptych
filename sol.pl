% --- navneord ---

navneord(apertures).
navneord(apparitions).
navneord(auguries).
 
% --- udsagnsord ---
 
udsagnsord(align).
udsagnsord(thicken).
udsagnsord(emerge).
 
% --- biord ---
 
biord(rhythmically).
biord(vertically).
biord(recursively).
biord(now).
 
% --- transmutation ---
 
variant(O, N, V, A) :-
    member(O, [0, 1]),
    navneord(N),
    udsagnsord(V),
    biord(A).
 
% --- poesis ---
 
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

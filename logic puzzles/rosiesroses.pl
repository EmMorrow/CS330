% Problem #1, "It's a tie", Dell Logic Puzzles, October 1999
% Each man (mr so-and-so) got a tie from a relative.
rose(cottage_beauty).
rose(golden_sunset).
rose(mountain_bloom).
rose(pink_paradise).
rose(sweet_dreams).

customer(hugh).
customer(ida).
customer(jeremy).
customer(leroy).
customer(stella).

item(balloons).
item(candles).
item(chocolates).
item(place_cards).
item(streamers).

event(anniversary).
event(charity_auction).
event(retirement).
event(senior_prom).
event(wedding).

solve :-
    rose(HughRose), rose(IdaRose), rose(JeremyRose), rose(LeroyRose), rose(StellaRose),
    all_different([HughRose, IdaRose, JeremyRose, LeroyRose, StellaRose]),
    %This predicate first chooses some ties.
    %It will choose the same tie for everybody, then repeatedly backtrack
    %choosing different ties, until the all_different predicate is satisfied.
    %It then does the same thing for relatives.
    %There is a more efficent way of doing this, but this is the simplest.
    item(HughItem), item(IdaItem), item(JeremyItem), item(LeroyItem), item(StellaItem),
    all_different([HughItem, IdaItem, JeremyItem, LeroyItem, StellaItem]),

    event(HughEvent), event(IdaEvent), event(JeremyEvent), event(LeroyEvent), event(StellaEvent),
    all_different([HughEvent, IdaEvent, JeremyEvent, LeroyEvent, StellaEvent]),

    %each list is a triple [mr, tie, relative]
    %Notice we specify the mr, this is arbitrary we could have specified the tie
    %as long as we cover all three dimentions
    Triples = [ [hugh, HughRose, HughItem, HughEvent],
                [ida, IdaRose, IdaItem, IdaEvent],
                [jeremy, JeremyRose, JeremyItem, JeremyEvent],
                [leroy, LeroyRose, LeroyItem, LeroyEvent],
                [stella, StellaRose, StellaItem, StellaEvent] ],

    % 1. The tie with the grinning leprechauns wasn't a present from a daughter.
    %The underscore, _, is a variable that could unify with anything, and you don't care what.
    \+ member([stella, _, _,wedding], Triples),
    \+ member([hugh, _, _,charity_auction], Triples),
    \+ member([hugh, _, _, wedding], Triples),
    \+ member([jeremy, mountain_bloom, _,_], Triples),


    % 6. Mr. Hurley received his flamboyant tie from his sister.
    member([jeremy, _, _,senior_prom], Triples),
    member([stella, cottage_beauty, _,_], Triples),
    member([hugh, pink_paradise, _,_], Triples),
    member([_, _, streamers, anniversary], Triples),
    member([_, _, balloons, wedding], Triples),
    member([_, sweet_dreams, chocolates,_], Triples),
    member([leroy, _, _,retirement], Triples),
    member([_, _, candles, senior_prom], Triples),

    tell(hugh, HughRose, HughItem, HughEvent),
    tell(ida, IdaRose, IdaItem, IdaEvent),
    tell(jeremy, JeremyRose, JeremyItem, JeremyEvent),
    tell(leroy, LeroyRose, LeroyItem, LeroyEvent),
    tell(stella, StellaRose, StellaItem, StellaEvent).


% Succeeds if all elements of the argument list are bound and different.
% Fails if any elements are unbound or equal to some other element.
all_different([H | T]) :- member(H, T), !, fail.
all_different([_ | T]) :- all_different(T).
all_different([_]).

tell(X, Y, Z, L) :-
    write(X), write(' got the '), write(Y),
    write(' rose and '), write(Z), write(' for the '), write(L), write('.'), nl.

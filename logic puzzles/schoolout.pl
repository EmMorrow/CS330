
teacher(ms_appleton).
teacher(ms_gross).
teacher(mr_knight).
teacher(mr_mcevoy).
teacher(ms_parnell).

subject(english).
subject(gym).
subject(history).
subject(math).
subject(science).

state(california).
state(florida).
state(maine).
state(oregon).
state(virginia).

activity(antiquing).
activity(camping).
activity(sightseeing).
activity(spelunking).
activity(water_skiing).

solve :-
    subject(AppletonSubject), subject(GrossSubject), subject(KnightSubject), subject(McevoySubject), subject(ParnellSubject),
    all_different([AppletonSubject, GrossSubject, KnightSubject, McevoySubject, ParnellSubject]),

    state(AppletonState), state(GrossState), state(KnightState), state(McevoyState), state(ParnellState),
    all_different([AppletonState, GrossState, KnightState, McevoyState, ParnellState]),

    activity(AppletonActivity), activity(GrossActivity), activity(KnightActivity), activity(McevoyActivity), activity(ParnellActivity),
    all_different([AppletonActivity, GrossActivity, KnightActivity, McevoyActivity, ParnellActivity]),

    Triples = [ [ms_appleton, AppletonSubject, AppletonState, AppletonActivity],
                [ms_gross, GrossSubject, GrossState, GrossActivity],
                [mr_knight, KnightSubject, KnightState, KnightActivity],
                [mr_mcevoy, McevoySubject, McevoyState, McevoyActivity],
                [ms_parnell, ParnellSubject, ParnellState, ParnellActivity] ],


    \+ member([_, gym, maine,_], Triples),
    \+ member([_, _, maine,sightseeing], Triples),
    \+ member([ms_gross, _, _,camping], Triples),

    ( (member([ms_appleton, _, _, camping], Triples)) ;

      (member([ms_gross, _, _, camping], Triples)) ),

  	( (member([ms_appleton, _, _, antiquing], Triples)) ;

      (member([ms_gross, _, _, antiquing], Triples)) ),

    member([ms_parnell, _, _,spelunking], Triples),

    ( (member([ms_gross, math, _, _], Triples)) ;

      (member([ms_gross, sciene, _, _], Triples)) ),

      % if msgross is antiquing then she's going to florida, othewise msgross is going to california
    ( (member([ms_gross, _, _, antiquing], Triples) -> member([ms_gross, _, florida, _], Triples)) ;

      (member([ms_gross, _, california, _], Triples)) ),

    ( (member([_, science, florida, water_skiing], Triples)) ;

      (member([_, science, california, water_skiing], Triples)) ),

    ( (member([mr_mcevoy, history, maine, _], Triples)) ;

      (member([mr_mcevoy, history, oregon, _], Triples)) ),

    ( (member([ms_appleton, english, virginia, _], Triples)) ;

      (member([ms_parnell, _, virginia, _], Triples)) ),


    tell(ms_appleton, AppletonSubject, AppletonState, AppletonActivity),
    tell(ms_gross, GrossSubject, GrossState, GrossActivity),
    tell(mr_knight, KnightSubject, KnightState, KnightActivity),
    tell(mr_mcevoy, McevoySubject, McevoyState, McevoyActivity),
    tell(ms_parnell, ParnellSubject, ParnellState, ParnellActivity).

all_different([H | T]) :- member(H, T), !, fail.
all_different([_ | T]) :- all_different(T).
all_different([_]).

tell(X, Y, Z, L) :-
    write(X), write(' is teaching '), write(Y),
    write(' and going to '), write(Z), write(' to go '), write(L), write('.'), nl.

% SWI-Prolog
% Advent of Code 2022 -- Day 5
% Jayden Dumouchel -- jdumouch@ualberta.ca

main :-
    read_file_to_lines('input.txt', Lines),
    parse_graph(Lines, Tail, State),
    execute_instructions(single, Tail, State, FinalState1),
    execute_instructions(bulk, Tail, State, FinalState2),
    collect_tops(FinalState1, Tops1),
    collect_tops(FinalState2, Tops2),
    write(Tops1), nl,
    write(Tops2), nl,
    halt.


% -------------------------------------------
% read_file_to_lines(+Filename, -Lines) 
%
% Takes an input filepath and reads contents into a list of lines as strings.
% -------------------------------------------
read_file_to_lines(Filename, Lines) :-
    read_file_to_codes(Filename, Chars, []),
    split_string(Chars, '\n', none, Lines).


% Executes instruction lines and returns the final state
execute_instructions(_, [], State, State).
execute_instructions(Mode, [Head|Lines], State, FinalState) :-
    parse_instruction(Head, Qty, Src, Tar), !,
    move_crates(Mode, State, Qty, Src, Tar, UpdatedState),
    execute_instructions(Mode, Lines, UpdatedState, FinalState).
execute_instructions(_, [Head|_], State, State) :- 
    \+ parse_instruction(Head, _, _, _).


% Collects the top of each stack into a list
collect_tops(State, Tops) :- collect_tops(State, [], Tops).
collect_tops([], Tops, Tops).
collect_tops([[Top|_]|Tail], Acc, Tops) :-
    append(Acc, [Top], NewAcc), 
    collect_tops(Tail, NewAcc, Tops).


% Parses input's initial state into a 2D list with heads being the top of a pile
parse_graph(Lines, Tail, State) :-
    init_state_list(Lines, Acc),
    parse_graph(Lines, Tail, Acc, State).
parse_graph([Head|Tail], Remaining, Acc, State) :-
    % Read until the indicies line
    \+ sub_atom(Head, 1, 1, _, '1'), !,
    add_line_to_state(Head, Acc, NewAcc),
    parse_graph(Tail, Remaining, NewAcc, State).
% Skip indicies line and the newline following, return state
parse_graph([_,_|Tail], Tail, State, State).


% Parses instruction line of form 'Move `Qty` from `Source` to `Target`'
parse_instruction(Line, Qty, Source, Target) :-
    split_string(Line, ' ', '', Tokens),
    Tokens = [_, QtyStr, _, SourceStr, _, TargetStr],
    number_codes(Qty, QtyStr),
    number_codes(Source, SourceStr),
    number_codes(Target, TargetStr).


move_crates(_, State, 0, _, _, State).
% Move crates one by one from target to source, reversing their order.
move_crates(single, State, Qty, Source, Target, FinalState) :-
    nth1(Source, State, SrcBucket),
    nth1(Target, State, TarBucket),
    SrcBucket = [SrcHead | SrcTail],
    NewTar = [SrcHead | TarBucket],
    swap_nth1(Target, State, NewTar, UpdatedState1),
    swap_nth1(Source, UpdatedState1, SrcTail, UpdatedState2),
    NewQty is Qty-1,
    move_crates(single, UpdatedState2, NewQty, Source, Target, FinalState). 
% Moves stacks of crates to new pile, retaining their order
move_crates(bulk, State, Qty, Source, Target, FinalState) :-
    % Grab relevant buckets from state
    nth1(Source, State, SrcBucket),
    nth1(Target, State, TarBucket),
    % Build a new list of which containers were grabbed
    length(Grabbed, Qty),
    append(Grabbed, SrcTail, SrcBucket),        % Populate Grabbed
    append(Grabbed, TarBucket, NewTarBucket),   % Build new TarBucket
    % Insert back into State
    swap_nth1(Target, State, NewTarBucket, UpdatedState1),
    swap_nth1(Source, UpdatedState1, SrcTail, FinalState).

% Find the line with indicies and build a sized state list
init_state_list([Head|_], State) :-
    % only match lines with a '1' as second char
    sub_atom(Head, 1, 1, _, '1'), !,
    % find last index to build sized list
    string_length(Head, Len),
    LastPos is Len-2,
    sub_atom(Head, LastPos, 1, _, LastAtom),
    atom_number(LastAtom, LastNum),
    % build list and fill it with empty lists
    length(State, LastNum),
    findall([], member(_, State), State).
% Skip irrelevant lines
init_state_list([_|Tail], State) :-
    init_state_list(Tail, State).


% Adds a line from the initial state graph into the State by reading 4 chars
% in at a time.
add_line_to_state(Line, Current, Output) :-
    string_chars(Line, LineList),
    add_line_to_state(LineList, 1, Current, Output).
add_line_to_state([_,CrateChar,_|Tail], N, Current, Output) :-
    % Skip spaces (air above stack)
    CrateChar == ' ',
    Tail = [_|StrippedTail],
    succ(N, NextN),
    add_line_to_state(StrippedTail, NextN, Current, Output). 
add_line_to_state([_,CrateChar,_|Tail], N, Current, Output) :-
    % Convert from char to atom (for ease of use)
    atom_chars(Crate, [CrateChar]),
    % Grab the relevant bucket and push the Crate to the tail
    nth1(N, Current, Bucket),
    append(Bucket, [Crate], NewBucket),
    swap_nth1(N, Current, NewBucket, NextState),
    % Procede to next 3 characters, skipping one
    (Tail = [_|StrippedTail] ; StrippedTail = []),
    succ(N, NextN),
    add_line_to_state(StrippedTail, NextN, NextState, Output). 
add_line_to_state(_, _, Out, Out).


% Swaps the `N`th element in `List` with `Elem`.
swap_nth1(N, List, Elem, NewList) :-
    % Init output list
    length(List, ListLen),
    length(NewList, ListLen),
    % Assertions
    N > 0, N =< ListLen,
    % Init Head and Tail
    HeadLen is N-1, TailLen is ListLen - N,
    length(Head, HeadLen), length(Tail, TailLen),
    append(Head, [_|Tail], List),
    % Insert Elem between them
    append(Head, [Elem|Tail], NewList).

% SWI-Prolog
% Advent of Code 2022 -- Day 4
% Jayden Dumouchel -- jdumouch@ualberta.ca

main :-
    read_file_to_lines('input.txt', Lines),
    count_pairs(Lines, is_fully_contained, Contained),
    count_pairs(Lines, is_overlapped, Overlapping),
    write(Contained), nl,
    write(Overlapping), nl,
    halt.


% -------------------------------------------
% read_file_to_lines(+Filename, -Lines) 
%
% Takes an input filepath and reads contents into a list of lines as strings.
% -------------------------------------------
read_file_to_lines(Filename, Lines) :-
    read_file_to_codes(Filename, Chars, []),
    split_string(Chars, '\n', none, Lines).

% -------------------------------------------
% count_pairs(+Lines, +Filter, -Count)
%
% Counts number of pairs within Lines that match Filter predicate.
% A malformed or empty line will terminate the count.
% -------------------------------------------
count_pairs(Lines, Filter, Count) :- count_pairs(Lines, Filter, 0, Count).
count_pairs([], _, Count, Count).
count_pairs([Head|_], _, Count, Count) :- \+ parse_pair(Head, _, _).
count_pairs([Head|Tail], Filter, Acc, Count) :-
    parse_pair(Head, A, B),
    (call(Filter, A, B) ->
        NewAcc is Acc + 1 ;
        NewAcc is Acc),
    count_pairs(Tail, Filter, NewAcc, Count), !.

% Parses string of form e.g. '5-9,4-10' into list [[5,9], [4, 10]]
parse_pair(Line, [MinA, MaxA], [MinB, MaxB]) :-
    % Split the pair in two
    split_string(Line, ',', none, Ranges),
    Ranges = [RangeA, RangeB | _],
    % Split each range into their Min and Max strings
    split_string(RangeA, '-', none, CharsA),
    split_string(RangeB, '-', none, CharsB),
    CharsA = [MinCharA, MaxCharA | _],
    CharsB = [MinCharB, MaxCharB | _],
    % Convert all number strings to numbers types
    atom_number(MinCharA, MinA), atom_number(MaxCharA, MaxA),
    atom_number(MinCharB, MinB), atom_number(MaxCharB, MaxB).

% Returns true if all values of one range are contained in the other
is_fully_contained([MinA, MaxA], [MinB, MaxB]) :-
    ( MinA >= MinB, MaxA =< MaxB ) ;
    ( MinB >= MinA, MaxB =< MaxA ).

% Returns true if the passed ranges overlap
is_overlapped([MinA, MaxA], [MinB, MaxB]) :-
    ( MinA =< MaxB, MaxA >= MinB ).



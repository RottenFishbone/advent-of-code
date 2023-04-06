% SWI-Prolog
% Advent of Code 2022 -- Day 1
% Jayden Dumouchel -- jdumouch@ualberta.ca

main :- 
    % Reads an input file into a list of lines
    read_file_to_lines('input.txt', Lines),
    collect_sums(Lines, Sums),
    sort(Sums, AscendingSums),
    reverse(AscendingSums, DescendingSums),
    DescendingSums = [S1, S2, S3 |_],
    TopThree is S1 + S2 + S3,
    % Print the results and exit
    write(S1), nl, 
    write(TopThree), nl, halt.

% -------------------------------------------
% read_file_to_lines(+Filename, -Lines) 
%
% Takes an input filepath and reads contents into a list of lines as strings.
% -------------------------------------------
read_file_to_lines(Filename, Lines) :-
    read_file_to_codes(Filename, Chars, []),
    split_string(Chars, '\n', '', Lines).

% -------------------------------------------
% sum_to_nl(+Input, -Tail, -Sum)
%
% Calculates a sum from the head of Input to the first newline.
% Input is a list of strings, ending with a newline character.
% Tail is the remaining list of strings, after the newline.
% Sum is the value of the summation.
% -------------------------------------------
sum_to_nl(Input, Tail, Sum) :-
    sum_to_nl(Input, Tail, 0, Sum).
sum_to_nl([], [], Sum, Sum).                    % End of list
sum_to_nl([Head|Tail], Tail, Sum, Sum) :-       % Break on non-numeric  
    \+ atom_number(Head, _).
sum_to_nl([Head|Tail], Remaining, Acc, Sum) :-
    atom_number(Head, Head_Num),
    New_Acc is Head_Num+Acc,
    sum_to_nl(Tail, Remaining, New_Acc, Sum), !.

% -------------------------------------------
% find_max(+Input, -Max)
% 
% Finds the maximum sum of lines without a break from an input list.
% -------------------------------------------
find_max(Input, Max) :- find_max(Input, 0, Max).    
find_max([], Max, Max).
find_max(Input, RunningMax, Max) :-
    sum_to_nl(Input, Tail, Sum),
    (RunningMax > Sum -> 
        find_max(Tail, RunningMax, Max) ;
        find_max(Tail, Sum, Max)).

% -------------------------------------------
% collect_sums(+Input, -Sums)
%
% Collects each `sum_to_nl` into a list.
% -------------------------------------------
collect_sums(Input, Sums) :- collect_sums(Input, [], Sums).
collect_sums([], Sums, Sums).
collect_sums(Input, Acc, Sums) :- 
    sum_to_nl(Input, Tail, Indv_Sum),
    collect_sums(Tail, [Indv_Sum|Acc], Sums).



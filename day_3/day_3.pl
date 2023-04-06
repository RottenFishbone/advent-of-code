% SWI-Prolog
% Advent of Code 2022 -- Day 3
% Jayden Dumouchel -- jdumouch@ualberta.ca

main :-
    read_file_to_lines('input.txt', Lines),
    total_priority(Lines, Total_Priority),
    group_priorities(Lines, Group_Priority),
    write(Total_Priority), nl,
    write(Group_Priority), nl,
    halt.

% -------------------------------------------
% read_file_to_lines(+Filename, -Lines) 
%
% Takes an input filepath and reads contents into a list of lines as strings.
% -------------------------------------------
read_file_to_lines(Filename, Lines) :-
    read_file_to_codes(Filename, Chars, []),
    split_string(Chars, '\n', '', Lines).


% -------------------------------------------
% group_priorities(+List, -Priority) 
%
% Groups lines into 3, finds the intersecting character's priority and
% sums all of them together.
% -------------------------------------------
group_priorities(List, Priority) :- group_priorities(List, 0, Priority).
group_priorities([A,B,C|Tail], Acc, Priority) :-
    string_chars(A, A_Chars),
    string_chars(B, B_Chars),
    string_chars(C, C_Chars),
    intersection(A_Chars, B_Chars, AB_Intersect),
    intersection(C_Chars, AB_Intersect, Intersect),
    nth1(1, Intersect, First),
    item_priority(First, First_Priority),
    New_Acc is Acc + First_Priority,
    group_priorities(Tail, New_Acc, Priority), !.
group_priorities(_, Priority, Priority).
   

% -------------------------------------------
% total_priority(+Lines, -Priority)
%
% Sums the sack priority of each line passed as a list.
% -------------------------------------------
total_priority(Lines, Priority) :-
    maplist(sack_priority, Lines, Priorities),
    foldl(plus, Priorities, 0, Priority).

% -------------------------------------------
% sack_priority(+Line, -Priority)
%
% Calculates the overlap in half of a Line's characters
% lowercase characters are worth their alphabetical position, uppercase
% are double.
% -------------------------------------------
sack_priority(Line, Priority) :-
    string_chars(Line, Chars),
    length(Chars, Length),
    Half is Length/2,
    length(First, Half),
    length(Second, Half),
    append(First, Second, Chars),
    intersection(First, Second, Items),
    list_to_set(Items, ItemSet),
    maplist(item_priority, ItemSet, Priorities),
    foldl(plus, Priorities, 0, Priority).

% Finds item's priority based on alphabetical ordering
item_priority(Item, Priority) :-
    char_code(Item, Code),
    Code < 91, Code > 64,
    Priority is Code-38.
item_priority(Item, Priority) :-
    char_code(Item, Code),
    Code < 123, Code > 96,
    Priority is Code-96.
item_priority(_, 0).



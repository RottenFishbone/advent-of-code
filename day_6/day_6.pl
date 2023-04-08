% SWI-Prolog
% Advent of Code 2022 -- Day 6
% Jayden Dumouchel -- jdumouch@ualberta.ca
:- use_module(library(clpfd)).

main :- 
    % Read file into char code list
    read_file_to_lines("input.txt", Lines),
    Lines = [Line|_],
    string_codes(Line, Codes),
    
    % Create window of first 4 elements
    length(PacketWindow, 4),
    append(PacketWindow, PacketTail, Codes),
    distinct_window_id(PacketWindow, PacketTail, 4, PId),

    % Create window of first 14 elements
    length(MessageWindow, 14),
    append(MessageWindow, MessageTail, Codes),
    distinct_window_id(MessageWindow, MessageTail, 14, MId),

    % Print the ID of first all-distinct window for each
    write(PId), nl,
    write(MId), nl,
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
% distinct_window_id(+Window, +List, +StartId, -Id)
%
% Moves a window (sized as the initial Window passed) across List to find
% the Index of the last character in a window where all elements are unique.
% e.g.
% List = [a,s,d,a,b,g],
% Window = [a,s,d,a],
% distinct_window_id(Window, List, 4, Id) => Id = 5.
% -------------------------------------------
distinct_window_id(Window, _, Id, Id) :- all_distinct(Window).
distinct_window_id(Window, [Head|Tail], StartPos, Id) :-
    Window = [_|WindowTail],
    append(WindowTail, [Head], NewWindow),
    succ(StartPos, NextPos),
    distinct_window_id(NewWindow, Tail, NextPos, Id).

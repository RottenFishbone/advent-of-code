% SWI-Prolog
% Advent of Code 2022 -- Day 2
% Jayden Dumouchel -- jdumouch@ualberta.ca

main :-
    read_file_to_lines('input.txt', Lines),
    sum_scores(1, Lines, Pt1),
    sum_scores(2, Lines, Pt2),
    write(Pt1), nl,
    write(Pt2), nl,
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
% score_round(+Mode, +Opp, +You, -Score)
%
% Determines the score earned from round determined by Opp {A, B, C} and 
% You/Outcome {X, Y, Z}. Mode {1, 2} changes method of score calculation.
% -------------------------------------------
score_round(1, Opp, You, Score) :-
    choice_score(You, Choice_Score),
    game_score(Opp, You, Game_Score),
    Score is Choice_Score + Game_Score.
score_round(2, Opp, Outcome, Score) :-
    outcome_score(Outcome, Game_Score),
    game_score(Opp, You, Game_Score),
    choice_score(You, Choice_Score),
    Score is Choice_Score + Game_Score.

% -------------------------------------------
% sum_scores(+Mode, +Rounds, -Score)
%
% Determines the total score from playing all rounds using the given
% calculation mode to calculate.
%
% Rounds are a list of 3 character strings of form 'A X', where A can be one
% of {A, B, C} and X can be {X, Y, Z}
% -------------------------------------------
sum_scores(Mode, Rounds, Score) :- sum_scores(Mode, Rounds, 0, Score).
sum_scores(_, [], Score, Score).
sum_scores(Mode, [Head|RoundsTail], Acc, Score) :-
    decompose_line(Head, A, B),
    score_round(Mode, A, B, Round_Score),
    NewAcc is Acc + Round_Score,
    sum_scores(Mode, RoundsTail, NewAcc, Score), !.
sum_scores(_, _, Score, Score).

% Decomposes input string into two char variables
decompose_line(Line, A, B) :-
    string_codes(Line, [A_Code, _, B_Code]),
    char_code(A, A_Code), char_code(B, B_Code).

% Map the score earned from playing a rock, paper or scissors
choice_score('X', 1).
choice_score('Y', 2).
choice_score('Z', 3).

% RPS score table where A/X = Rock, B/Y = Paper ..
game_score('A', 'X', 3).
game_score('A', 'Y', 6).
game_score('A', 'Z', 0).

game_score('B', 'X', 0).
game_score('B', 'Y', 3).
game_score('B', 'Z', 6).

game_score('C', 'X', 6).
game_score('C', 'Y', 0).
game_score('C', 'Z', 3).

% Map letters to their outcome's score
outcome_score('X', 0).
outcome_score('Y', 3).
outcome_score('Z', 6).

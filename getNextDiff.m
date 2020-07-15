function [next_Difficulty,hardbit,next_target,targbit ]= getNextDiff( DiffSeri,STseri,T,N)
%UNTITLED6 此处显示有关此函数的摘要
%   此处显示详细说明
% // Karbowanec, Masari, Bitcoin Gold, and Bitcoin Cash have contributed.
% // Do not use "if solvetime < 0 then solvetime = 1" which allows a catastrophic exploit.


% // The above is for small coin protection. 
% // Use N=1.4xN if coin is medium size. 
% // Use N=2xN if the coin is large. 

% // If new coin, just "give away" first N blocks at low difficulty:
% // if ( height -1 < N ) { next_difficulty = 100; return; }

% // To get an average solvetime to within +/- ~0.1%, use an adjustment factor.
% // For N>80, just use 1.000.
adjust = 0.998;

LWMA=0;
avgDifficulty=0;

% // Loop through N most recent blocks.
% // height-1 = most recently solved block
for i=1:N
    solvetime = STseri(i);
    if (solvetime >   7*T )
        solvetime =   7*T;
    end
%     if (solvetime <  -6*T)
%         solvetime =  -6*T;
%     end
    
    % //  The divisor N*(N+1)/2 = sum(j=1 to N) normalizes it to an LWMA average.
    LWMA =LWMA+ solvetime * i  / (N*(N+1)/2);
    avgDifficulty = avgDifficulty +DiffSeri(i)/N;
    % //       if using difficulty instead of target:
    % //       harmonic_mean_D += 1/difficulty[i]/N;
end
% // Keep t reasonable, just in case
if ( LWMA  < T/8 )
    LWMA  = T/8;
end

next_Difficulty = avgDifficulty  / LWMA  *T;
hardbit=log(next_Difficulty)/log(2);
next_target=2^(256-13)/next_Difficulty;
targbit=log(next_target)/log(2);

end


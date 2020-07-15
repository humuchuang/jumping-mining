function [next_Difficulty,hardbit,next_target,targbit ]= getNextDiff_BTG( DiffSeri,STseri,T,N)

adjust = 0.998;
t=0;
sum_target=0;
K = (N+1)/2 * 0.998 * T
dnorm = 10
% // Loop through N most recent blocks.
% // height-1 = most recently solved block
for i=1:N
    solvetime = STseri(i);
    if (solvetime >   6*T )
        solvetime =   6*T;
    end
    
    % //  The divisor N*(N+1)/2 = sum(j=1 to N) normalizes it to an avgtime average.
    t =t+i*solvetime;
    sum_target =sum_target+ 2^(256-13)/DiffSeri(i)/(K*N*N) ;
%     avgDifficulty = avgDifficulty +DiffSeri(i)/N;
    % //       if using difficulty instead of target:
    % //       harmonic_mean_D += 1/difficulty[i]/N;
end
% // Keep t reasonable, just in case
if ( t  < N * K / dnorm )
    t  =N * K / dnorm;
end

next_target=t  * sum_target;
next_Difficulty=2^(256-13)/next_target;
hardbit=log(next_Difficulty)/log(2);
targbit=log(next_target)/log(2);
%* adjust;

end


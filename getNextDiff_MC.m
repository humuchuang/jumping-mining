function [next_Difficulty,hardbit,next_target,targbit ]= getNextDiff_MC( DiffSeri,STseri,T,N)
% DiffSeri 最近N个block的难度
% STseri 最近N个block的solvetime
% T=120秒，目标出块时间
% N=15,45，60 回望窗口大小
adjust = 1;
sum_time=0;
sum_target=0;
sum_last10_time=0;
sum_last10_target=0;
sum_last5_time=0;
sum_last5_target=0;
% // Loop through N most recent blocks.
% // height-1 = most recently solved block
for i=1:N
    solvetime = STseri(i);
    if (solvetime >   8*T )
        solvetime =   8*T;
    end
    % //  The divisor N*(N+1)/2 = sum(j=1 to N) normalizes it to an LWMA average.
    sum_time =sum_time+ solvetime * i;
    target=getTarget(DiffSeri(i));
    sum_target =sum_target+ target;
    if (i >= N-10+1)
        sum_last10_time =sum_last10_time+ solvetime;
        sum_last10_target =sum_last10_target+ target;
    end
     if (i >= N-5+1)
        sum_last5_time =sum_last5_time+ solvetime;
        sum_last5_target =sum_last5_target+ target;
    end
    
end
% Keep t reasonable in case strange solvetimes occurred.
%if (sum_time < N * N * T / 20)
%    sum_time = N * N * T / 20;
%end
if (sum_time < N * N * T / 20)
    sum_time = N * N * T / 20;
end

next_target = 2 * (sum_time / (N * (N + 1))) * (sum_target / N) * adjust / T;
% if next_target>2^(256-13)
%     next_target=2^(256-13);
% end
avg_last5_target = sum_last5_target / 5;
avg_last10_target = sum_last10_target /10;
if sum_last5_time <= 90
    
    if (next_target > avg_last5_target  / 4)
        next_target = avg_last5_target /4;
    end
elseif sum_last10_time <= 5 * 60
    if (next_target > avg_last10_target  /2)
        next_target = avg_last10_target /2;
    end
elseif sum_last10_time <= 10 * 60
    
    if (next_target > avg_last10_target*2 /3)
        next_target = avg_last10_target*2 /3;
    end
end

% in case difficulty drops too soon compared to the last block, especially
% when the effect of the last rule wears off in the new block
% DAA will switch to normal LWMA and cause dramatically diff drops
last_target=getTarget(DiffSeri(end)); %上个块的难度
if (next_target > last_target * 13 / 10)
     next_target = last_target * 13 / 10;
end

pow_limit=2^(256-32);
if (next_target > pow_limit)
    next_target=pow_limit;
end

next_Difficulty=getTarget(next_target);
hardbit=log2(next_Difficulty);
targbit=log2(next_target);

end


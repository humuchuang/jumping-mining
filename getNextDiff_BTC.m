function [next_Difficulty,hardbit,next_target,targbit ]= getNextDiff_BTC( DiffSeri,STseri,T,N)
     
    bnNew = 2^(256-32)/DiffSeri(end-1);
    bnPowLimit = 2^(256-32);
    if mod(N,2016) == 0
        nPowTargetSpacing = 10 * 60;
        nActualTimespan = sum(STseri(end-2015:end));
        
        bnAvg=2^(256-32)/DiffSeri(end-1); %Æ½¾ùtargetÖµ
        %for i=1:2016
        %    bnAvg=bnAvg+2^(256-32)/DiffSeri(end-i+1)/2016;
        %end


        if nActualTimespan > 8064 * nPowTargetSpacing
           nActualTimespan = 8064* nPowTargetSpacing;
        elseif nActualTimespan < 504  * nPowTargetSpacing
           nActualTimespan = 504  * nPowTargetSpacing;
        end
        bnNew=bnAvg;
        bnNew = bnNew*nActualTimespan/ (nPowTargetSpacing*2016);

        if (bnNew > bnPowLimit)
            bnNew =bnPowLimit;  %target
        end
    end


    next_Difficulty = bnPowLimit  / bnNew;
    hardbit=log(next_Difficulty)/log(2);
    next_target=bnPowLimit/next_Difficulty;
    targbit=log(next_target)/log(2);


end


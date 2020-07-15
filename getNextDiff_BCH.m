function [next_Difficulty,hardbit,next_target,targbit ]= getNextDiff_BCH( DiffSeri,STseri,T,N)
    nPowTargetSpacing = 10 * 60;
    nActualTimespan = sum(STseri(end-143:end));
    bnPowLimit = 2^(256-32);
    bnAvg=0; %Æ½¾ùtargetÖµ
    for i=1:144
        bnAvg=bnAvg+2^(256-32)/DiffSeri(end-i+1)/144;
    end


    if nActualTimespan > 288 * nPowTargetSpacing
       nActualTimespan = 288 * nPowTargetSpacing;
    elseif nActualTimespan < 72 * nPowTargetSpacing
       nActualTimespan = 72 * nPowTargetSpacing;
    end
    bnNew=bnAvg;
    bnNew = bnNew*nActualTimespan/ (nPowTargetSpacing*144);

    if (bnNew > bnPowLimit)
        bnNew =bnPowLimit;  %target
    end


    next_Difficulty = bnPowLimit  / bnNew;
    hardbit=log(next_Difficulty)/log(2);
    next_target=bnPowLimit/next_Difficulty;
    targbit=log(next_target)/log(2);


end


clear
Lz=2^40;  %leading zeros
BaseD=4;  %基准难度
T=60*10;    %默认出块时间
HRworker=BaseD*Lz/T;   %矿工算力
HRAttackerMulti=1;       %攻击者算力倍数
HRAttacker=HRAttackerMulti*HRworker;
AttackIn=0.95;  %攻击者进入倍数
AttackOut=1.45; %攻击者退出倍数

N=144;    % floor(45*(600/T)^0.3);(n,1);  %
n=144*200;  %总模拟的block数，如果想要画图清晰，n控制在2000左右
RndSeri=rand(n,1);    %随机数序列
Dseri=zeros(n,1);     %难度序列
STseri=zeros(n,1);    %出块时间序列
 
HRSeri=zeros(n,1);    %算力序列
AttackSeri=zeros(n,1); %记录攻击序列（若攻击者从某个块i开始到块j结束在挖矿，则AttackSeri(i to j)=1,否则为0）  
HRnow=HRworker;       %当前算力值
Attackposition=0;     %当前攻击者状态，正在挖矿则为1，否则为0；
ifattack=1;           %是否进行攻击的开关。 为1则攻击者激活，否则这次测试永远不介入。
for i=1:n
    if i<=N
        Dseri(i)=BaseD;
        STseri(i)= randNum2SolveTimeFunc( HRnow,RndSeri(i),Dseri(i));
        AttackSeri(i)=Attackposition;
        HRSeri(i)=HRnow;
        continue
    end
    if ifattack
        if i>N
            if Dseri(i-1)<AttackIn*BaseD && Attackposition==0
                Attackposition=1;
                HRnow=HRAttacker+HRworker;
            elseif Dseri(i-1)>AttackOut*BaseD && Attackposition==1
                Attackposition=0;
                HRnow=HRworker;
            end
        end
    end
  % [next_Difficulty,hardbit,next_target,targbit ]= getNextDiff_old( Dseri(i-N:i-1),STseri(i-N:i-1),T,N);
    [next_Difficulty,hardbit,next_target,targbit ]= getNextDiff_BCH( Dseri(i-N:i-1),STseri(i-N:i-1),T,N);
    %[next_Difficulty,hardbit,next_target,targbit ]= getNextDiff_MC( Dseri(i-N:i-1),STseri(i-N:i-1),T,N);
    %     [next_Difficulty,hardbit] = getNextDiff( Dseri(i-N:i-1),STseri(i-N:i-1),T,N);
    %     [next_Difficulty,hardbit] = getNextDiff_EMA( Dseri(i-N:i-1),STseri(i-N:i-1),T,N);
    %     [next_Difficulty,hardbit] = getNextDiff_oldtarget( Dseri(i-N:i-1),STseri(i-N:i-1),T,N);
    %     [next_Difficulty,hardbit] = getNextDiff_old(Dseri(i-N:i-1),STseri(i-N:i-1),T,N);
    Dseri(i)=next_Difficulty;
    STseri(i)= randNum2SolveTimeFunc( HRnow,RndSeri(i),Dseri(i));
    HRSeri(i)=HRnow;
    AttackSeri(i)=Attackposition;
end
%%
figure(1)
plot(Dseri)
title('难度')
figure(2)
bar(STseri)
title('solvetime')
figure(3)
bar(AttackSeri)
title('AttackSeri')
figure(4)
plotyy(1:n,Dseri,1:n,log(HRSeri))
legend('Difficulty','log(Total HashRate)')
title(['Attack at D=',num2str(AttackIn),', Stop at D=',num2str(AttackOut),',Multiplier=',num2str(HRAttackerMulti)])

%%

STafterAttack=STseri(N+1:end);
AttackSeriAfter=AttackSeri(N+1:end);
WorkerCostTime=sum(STafterAttack);
AttackerCostTime=sum(STafterAttack(logical(AttackSeriAfter)));
notAttackSeri=1-AttackSeriAfter;     %未被攻击的block
WorkerGetBlock=sum(notAttackSeri)+sum(AttackSeriAfter)/(1+HRAttackerMulti); %未被攻击block总数+被攻击block数*诚实矿工获取比例
AttackerGetBlock=sum(AttackSeriAfter)*HRAttackerMulti/(1+HRAttackerMulti);% 被攻击block数*攻击者获取比例

WorkerSTperBlock=WorkerCostTime/WorkerGetBlock        %矿工出块平均时间
AttackerSTperBlock=AttackerCostTime/AttackerGetBlock     %攻击者出块平均时间
% tmp=[mean(STseri),std(STseri),max(Dseri/BaseD),min(Dseri/BaseD),...
%     sum(AttackSeriAfter)/n,WorkerSTperBlock,AttackerSTperBlock...
%     WorkerSTperBlock*HRworker/(AttackerSTperBlock*HRAttacker)];

WorkerEffi=1/WorkerSTperBlock   %矿工效率：单位时间出块量/诚实矿工总算力
AttackerEffi=1/AttackerSTperBlock/HRAttackerMulti %攻击者效率：单位时间出块量/攻击者总算力

stolenrate=AttackerEffi/WorkerEffi-1
%=(WorkerSTperBlock*HRworker/(AttackerSTperBlock*HRAttacker)-1)

disp(sprintf('The Avg time taken by the attacker to mine a block：%0.1fs，taken by the honest miner：%0.1fs ',...
    AttackerSTperBlock,WorkerSTperBlock))
disp(sprintf('Mining efficiency of the attacker：%f，the honest miner：%f ',...
    AttackerEffi,WorkerEffi))

disp(' ')



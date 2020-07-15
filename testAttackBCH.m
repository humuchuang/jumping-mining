clear
Lz=2^40;  %leading zeros
BaseD=4;  %��׼�Ѷ�
T=60*10;    %Ĭ�ϳ���ʱ��
HRworker=BaseD*Lz/T;   %������
HRAttackerMulti=1;       %��������������
HRAttacker=HRAttackerMulti*HRworker;
AttackIn=0.95;  %�����߽��뱶��
AttackOut=1.45; %�������˳�����

N=144;    % floor(45*(600/T)^0.3);(n,1);  %
n=144*200;  %��ģ���block���������Ҫ��ͼ������n������2000����
RndSeri=rand(n,1);    %���������
Dseri=zeros(n,1);     %�Ѷ�����
STseri=zeros(n,1);    %����ʱ������
 
HRSeri=zeros(n,1);    %��������
AttackSeri=zeros(n,1); %��¼�������У��������ߴ�ĳ����i��ʼ����j�������ڿ���AttackSeri(i to j)=1,����Ϊ0��  
HRnow=HRworker;       %��ǰ����ֵ
Attackposition=0;     %��ǰ������״̬�������ڿ���Ϊ1������Ϊ0��
ifattack=1;           %�Ƿ���й����Ŀ��ء� Ϊ1�򹥻��߼��������β�����Զ�����롣
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
title('�Ѷ�')
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
notAttackSeri=1-AttackSeriAfter;     %δ��������block
WorkerGetBlock=sum(notAttackSeri)+sum(AttackSeriAfter)/(1+HRAttackerMulti); %δ������block����+������block��*��ʵ�󹤻�ȡ����
AttackerGetBlock=sum(AttackSeriAfter)*HRAttackerMulti/(1+HRAttackerMulti);% ������block��*�����߻�ȡ����

WorkerSTperBlock=WorkerCostTime/WorkerGetBlock        %�󹤳���ƽ��ʱ��
AttackerSTperBlock=AttackerCostTime/AttackerGetBlock     %�����߳���ƽ��ʱ��
% tmp=[mean(STseri),std(STseri),max(Dseri/BaseD),min(Dseri/BaseD),...
%     sum(AttackSeriAfter)/n,WorkerSTperBlock,AttackerSTperBlock...
%     WorkerSTperBlock*HRworker/(AttackerSTperBlock*HRAttacker)];

WorkerEffi=1/WorkerSTperBlock   %��Ч�ʣ���λʱ�������/��ʵ��������
AttackerEffi=1/AttackerSTperBlock/HRAttackerMulti %������Ч�ʣ���λʱ�������/������������

stolenrate=AttackerEffi/WorkerEffi-1
%=(WorkerSTperBlock*HRworker/(AttackerSTperBlock*HRAttacker)-1)

disp(sprintf('The Avg time taken by the attacker to mine a block��%0.1fs��taken by the honest miner��%0.1fs ',...
    AttackerSTperBlock,WorkerSTperBlock))
disp(sprintf('Mining efficiency of the attacker��%f��the honest miner��%f ',...
    AttackerEffi,WorkerEffi))

disp(' ')



function [ ST ] = randNum2SolveTimeFunc( HR,randNum,difficulty)%,Lz)
%UNTITLED4 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
if randNum<0||randNum>1
    error('randNum Ҫ��0-1֮��')
end
Lz = 2^40
p=1/(difficulty*Lz);
% ST=-log(1-randNum)/p/HR;      %Zawy's Version 
ST=ceil(log(1-randNum)/log(1-p))/HR;  %my version 
end


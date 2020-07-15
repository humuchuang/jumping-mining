function [ ST ] = randNum2SolveTimeFunc( HR,randNum,difficulty)%,Lz)
%UNTITLED4 此处显示有关此函数的摘要
%   此处显示详细说明
if randNum<0||randNum>1
    error('randNum 要在0-1之间')
end
Lz = 2^40
p=1/(difficulty*Lz);
% ST=-log(1-randNum)/p/HR;      %Zawy's Version 
ST=ceil(log(1-randNum)/log(1-p))/HR;  %my version 
end


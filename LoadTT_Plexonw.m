function [T,WV] = LoadTT_Plexonw(a,b,c)
% MClust Loading engine wrapper
% [T,WV] = LoadSE_NeuralynxNT(a,b,c)

%  finished on Aug. 2014 by Anil Bollimunta

if nargin == 1
    [T,WV] = LoadTT_Plexon(a);
elseif nargin == 3
    [T,WV] = LoadTT_Plexon(a,b,c);
elseif nargin == 2
    % New "get" construction"
    if strcmp(a, 'get')
        switch (b)
            case 'ChannelValidity'
                T = [true true true true]; return;
            case 'ExpectedExtension'
                T = '.plx'; return;
            otherwise
                error('Unknown get condition.');
        end
    else
        error('2 argins requires "get" as the first argument.');
    end
end

end

function [T,WV] = LoadTT_Plexon(datafile,R,flag)

if nargin == 1
    R=[];flag=5;
end
t=[];
for ch = 1:4
    temp = [];wemp = zeros(0,32);
    unit = 0;
    while 1
        [~, ~, ts, wave] = plx_waves_v(datafile, ch,unit);
        if ts ~= -1
            temp = [temp;ts];
            wemp = [wemp;wave];
            unit = unit + 1;
        else
            break
        end
    end
    t = temp;
    wv(:,ch,:) = wemp;
end

%% Clean up
[~, EVts, STR] = plx_event_ts(datafile,257);

% Events
trial_count_indx = find(STR == 11002);
STR(trial_count_indx + 1) = STR(trial_count_indx + 1) + 10000;

nStart = sum(STR == 1001); Start = EVts(STR == 1001);
nStop  = sum(STR == 1009); Stop =  EVts(STR == 1009);
if Start(1) > Stop(1)
    Start(1)=[];
    nStart = nStart - 1;
end
if nStart ~= nStop
    if nStart == nStop +1
        display('nStart = nStop + 1')
    else
        display(['what  now ?' datafile])
    end
end
% Noise
for tr = 1:nStart
    if tr ~= 1
        ind = t < Start(tr) & t > Stop(tr-1);
        t(ind)=[];
        wv(ind,:,:)=[];
    else
        ind = t < Start(tr);
        t(ind)=[];
        wv(ind,:,:)=[];
    end
end
%%
switch flag
    case 1
        [~,I,~] = intersect(ts,R);
        T = t(I);
        WV = wv(I,:,:);
    case 2
        T = t(R);
        WV = wv(R,:,:);
    case 3
        I = t >= R(1) & t <= R(2);
        T = t(I);
        WV = wv(I,:,:);
    case 4
        T = t(R(1):R(2));
        WV = wv(R(1):R(2),:,:);
    case 5
        T = t;
        WV = wv;
end
end
        

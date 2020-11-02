%% Draw Firing Rate Plot
fprintf('Simulating now...')

blue=[0 152 255]./255; %color for neuro group 1
red=[255 72 72]./255;  %color for neuro group 2

repeat=20;% run multiple times for each coherence level
threshold=15; %Hz
c_dot_Box=[0 1 2 10 50 100]./100; % select 6 differenct
RT=ones(repeat,length(c_dot_Box)).*NaN; % record the correctness
Correct=ones(repeat,length(c_dot_Box)).*NaN; %
show_c_dot=[0 2 50 100]./100;pp=0;

figure
for i=1:length(c_dot_Box)
    c_dot =c_dot_Box(i);
    if ismember(c_dot,show_c_dot)
        pp=pp+1;
        subplot(2,2,pp)
        hold on
    end
    for j=1:repeat
        [t,v,r1,r2]=Model(c_dot,1);
        pass1= any(r1>threshold);
        pass2= any(r2>threshold);
        inx1=t(r1>threshold);
        inx2=t(r2>threshold);
        if pass1 && pass2
            rt1=inx1(1);
            rt2=inx2(1);
            RT(j,i)=min(rt1,rt2);
            Correct(j,i)=(rt1<=rt2)*1;
        elseif pass1 && ~pass2
            rt1=inx1(1);
            RT(j,i)=rt1;
            Correct(j,i)=1;
        elseif ~pass1 && pass2
            rt2=inx2(1);
            RT(j,i)=rt2;
            Correct(j,i)=0;
        else
            RT(j,i)=2;
            Correct(j,i)=0;
        end
        if ismember(c_dot,show_c_dot)
            plot(t,r1,'Color',blue,'LineWidth',0.8);
            plot(t,r2,'Color',red,'LineWidth',0.8);
        end
    end
    if ismember(c_dot,show_c_dot)
        plot([0 t(end)],[threshold threshold],'k','LineWidth',1)
        title(['c`=',num2str(c_dot*100),'%'])
        xticks(0:0.5:2);
        xticklabels((0:0.5:2).*1000)
        if i==1
            text(0,18,'Threshold','FontSize',12)
        end
        ylabel('Firing rate (Hz)');xlabel('Time (ms)');
        ax=gca;ax.LineWidth=1;ax.FontSize=14;ax.FontName='TimesNewRoman';
        ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
    end
end
set(gcf,'unit','normalized','Position',[0 0 0.6 1].*0.9)
% saveas(gca,'Fig1.jpg')

%% Correctness
fprintf('Doing Model fit now...')

mean_Correct=mean(Correct);
figure
subplot(1,2,1)

% fit the correctness with WieBull function
% Set up fittype and options.
[xData, yData] = prepareCurveData( c_dot_Box, mean_Correct);
ft = fittype( '1-0.5.*exp(-x./a);', 'independent', 'x', 'dependent', 'y' );% beta ÊÇ´Î·½
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = rand;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
hold on
log_c_dot=log(c_dot_Box);
X=[1:1:10,20:10:100]./100;logX=log(X);
fitY=fitresult(X);

% plot the result
plot(logX,fitY,'-k','LineWidth',1.2);
scatter(log_c_dot, yData,30,'ok','filled')
ylabel('%Correct');xlabel('Coherence level(%)');
ylim([0.35 1]);yticks(0.5:0.1:1);yticklabels((0.5:0.1:1).*100);
xticks(logX);xticklabels({'1','','','','','','','','','10','','','','','','','','','100'})
ax=gca;ax.FontSize=14;ax.LineWidth=1;ax.FontName='TimesNewRoman';
ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
set(gcf,'unit','normalized','Position',[0 0 0.6 0.5].*0.7)
legend('hide')

%% Reaction Time

mean_RT=mean(RT);
mean_RT_correct=ones(size(mean_RT)).*NaN;
mean_RT_wrong=ones(size(mean_RT)).*NaN;
for k=1:size(RT,2)
    correct=Correct(:,k);
    mean_RT_correct(k)=mean(RT(correct==1,k));
    mean_RT_wrong(k)=mean(RT(correct==0,k));
end

% plot Reaction time
subplot(1,2,2)
hold on
scatter(log_c_dot,mean_RT_wrong,30,'ok')
scatter(log_c_dot,mean_RT_correct,30,'ok','filled')
plot(log_c_dot,mean_RT_correct,'-k','LineWidth',1)
plot(log_c_dot,mean_RT_wrong,'--k','LineWidth',1)
xticks(logX);xticklabels({'1','','','','','','','','','10','','','','','','','','','100'})
ylabel('Reaction time (ms)');xlabel('Coherence level(%)');
yticks(0:0.5:2);yticklabels((0:0.5:2).*1000)
ax=gca;ax.LineWidth=1;ax.FontName='TimesNewRoman';
ax.FontSize=14;ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
set(gcf,'unit','normalized','Position',[0 0 0.6 0.5].*0.7)
% saveas(gca,'Fig2.jpg')


%% Draw 4 different phase plot
c_dot_Box=[0 2 50 100]./100;
stimulus_Box=[0 1 1 1];% only the first plot is without stimulus
figure
for j=1:4
    % c_dot & stimulus
    c_dot = c_dot_Box(j);
    stimulus=stimulus_Box(j);
    
    % initial parameter used in the model
    a = 270;
    b = 108;
    d = 0.154;
    gama = 0.641;
    taoS = 0.1;
    JN11 = 0.2609;
    JN22 = JN11;
    JN12 = 0.0497;
    JN21 = JN12;
    JAext = 5.2*10^(-4);
    I0 = 0.3255;
    miu0 = 30*stimulus;
    taoAMPA = 0.002;
    sigmanoise = 0.02;
    
    % parameter for noise and injections
    I1 = JAext * miu0 * (1+c_dot);
    I2 = JAext * miu0 * (1-c_dot);
    
    % formula used to calculate firing rate
    x1 = @(S1,S2) JN11.*S1 - JN12.*S2 + I0 + I1;
    x2 = @(S1,S2) JN22.*S2 - JN21.*S1 + I0 + I2;
    H = @(x)(a.*x-b) ./ (1-exp(-d.*(a.*x-b)));
    H1 = @(S1,S2) H(x1(S1, S2));
    H2 = @(S1,S2) H(x2(S1, S2));
    
    % ode fuction
    dS1 = @(S1,S2) -S1./taoS + (1-S1).*gama.*H1(S1,S2);
    dS2 = @(S1,S2) -S2./taoS + (1-S2).*gama.*H2(S1,S2);
    
    % phaseplane (numerical solutions)
    scale = 1200;
    ss_box = 0: 1/scale: 1;
    
    % nullclines numerical solutions
    Nullcline1 = ones(size(ss_box));
    Nullcline2 = ones(size(ss_box));
    for i = 1:length(ss_box)
        G1 = @(x)dS1(ss_box(i),x);
        Nullcline1(i) = fzero(G1,rand());
        clc;
    end
    for i = 1:length(ss_box)
        G2 = @(x)dS2(x,ss_box(i));
        Nullcline2(i) = fzero(G2,rand());
        clc;fprintf('Darw phase plot now...')
    end
    
    % phase plot
    subplot(2,2,j)
    hold on;
    
    % quiver of the field
    xx=0:0.1:0.8;
    [x1mesh,x2mesh]=meshgrid(xx,xx);
    ds1dt=dS1(x1mesh,x2mesh);
    ds2dt=dS2(x1mesh,x2mesh);
    quiver(x2mesh,x1mesh,ds2dt,ds1dt,2,'LineWidth',0.5,'Color',[0.5 0.5 0.5]);
    
    % phase plot
    upper=1;bottom=0;
    yy1 = ss_box(Nullcline1<=upper & Nullcline1>=bottom);
    xx1 = Nullcline1(Nullcline1<=upper & Nullcline1>=bottom);
    xx2 = ss_box(Nullcline2<=upper & Nullcline2>=bottom);
    yy2 = Nullcline2(Nullcline2<=upper & Nullcline2>=bottom);
    
    blue=[0 152 255]./255; %color for neuro group 1
    red=[255 72 72]./255;  %color for neuro group 2
    plot(xx1, yy1, 'LineWidth',2, 'Color', blue);
    plot(xx2, yy2, 'LineWidth',2, 'Color', red);
    text(0.67,0.22,'dS_2/dt=0','FontSize',12,'Color',blue)
    text(0.07,0.89,'dS_1/dt=0','FontSize',12,'Color',red)
    
    % steady points
    [CrossX,CrossY]=conjunction(xx1,yy1,xx2,yy2);% use fuction conjuction()
    for s=1:length(CrossX)
        if mod(s,2)
            scatter(CrossX(s),CrossY(s),30,'ok','filled')
        else
            scatter(CrossX(s),CrossY(s),30,'ok','MarkerFaceColor',[0.5 0.5 0.5])
        end
    end
    
    % rout of S1 & S2
    if j==2
        wrong=0;correct=0;threshold=15;
        while ~correct
            [t,v_correct,r1,r2]=Model(c_dot,1);
            pass1= any(r1>threshold);
            pass2= any(r2>threshold);
            correct=(pass1 & ~pass2);
        end
        plot(v_correct(:, 2), v_correct(:, 1), '-k','LineWidth',1);
        while ~wrong
            [t,v_wrong,r1,r2]=Model(c_dot,1);
            pass1= any(r1>threshold);
            pass2= any(r2>threshold);
            wrong=(~pass1 & pass2);
        end
        plot(v_wrong(:, 2), v_wrong(:, 1), '--k','LineWidth',1);
    elseif j>2
        [t,v,r1,r2]=Model(c_dot,1);
        plot(v(:, 2), v(:, 1), '-k','LineWidth',1);
        
    end
    axis equal;
    xlim([bottom upper]);ylim([bottom upper]);
    xlabel('S2');ylabel('S1');
    ax=gca;ax.LineWidth=1;ax.FontSize=12;ax.FontName='TimesNewRoman';
    ax.FontWeight='bold';ax.Box='off';ax.TickDir = 'out';
    if j>1
        title(['coherence level = ' num2str(c_dot*100) '%'])
    else
        title('without stimulus')
    end
end
clc;fprintf('Finished!')
set(gcf,'unit','normalized','Position',[0 0 0.6 1].*0.9)
% saveas(gca,'Fig3.jpg')
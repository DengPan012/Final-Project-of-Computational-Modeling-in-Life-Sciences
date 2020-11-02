%% Brief Intro
% this is the main part of our model
% part 1 can do simulation of the model with different coherence level
% part 2 can draw phase plot
% you can run Simulation.m & Phase plot
%% Initiation
clear;clc;close all
%% Part 1 run simulation
Simulation % run Simulation.m
% Note! if there's any error in the Simulation part, it is resulted from 
% the failure of using Weibull function to fit the correct rate
% Just run again, and it will be fine!
%% Part 2 draw phase plot
PhasePlot % run PhasePlot.m
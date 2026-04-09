%% BumbleBee Manipulator - Simscape Integrated Workspace
clear; clc; close all;

% 1. Import the Rigid Body Tree directly from your Simscape model
robot = importrobot('ROBOTIC_ARM_size', 'DataFormat', 'column');

% 2. Verify the imported bodies
disp('Imported Bodies:');
disp(robot.BodyNames);

% ... (Proceed directly to Section 3: Monte Carlo Simulation) ...
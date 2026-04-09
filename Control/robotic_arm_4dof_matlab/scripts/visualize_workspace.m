%% BumbleBee Manipulator - Corrected Kinematics Workspace
clear; clc; close all;

% 1. Define Link Lengths (mm)
h_mount = 126.835;
l_base  = 141.878;
l_1     = 120.000;
l_2     = 117.360;
l_grip  = 91.000;

% 2. Initialize the Rigid Body Tree
robot = rigidBodyTree('DataFormat', 'column');

% --- Base Mount & Base Joint ---
bodyBase = rigidBody('base_link');
jntBase = rigidBodyJoint('jnt_base', 'revolute');
jntBase.JointAxis = [0 0 1]; % Revolute about Z (Yaw)
% Translate UP by the static mount height
setFixedTransform(jntBase, trvec2tform([0, 0, h_mount])); 
bodyBase.Joint = jntBase;
addBody(robot, bodyBase, 'base');

% --- Link 1 (Shoulder) ---
body1 = rigidBody('link1');
jnt1 = rigidBodyJoint('jnt1', 'revolute');
jnt1.JointAxis = [1 0 0]; % Revolute about X (Pitch)
% Translate UP by the base link length
setFixedTransform(jnt1, trvec2tform([0, 0, l_base]));
body1.Joint = jnt1;
addBody(robot, body1, 'base_link');

% --- Link 2 (Elbow) ---
body2 = rigidBody('link2');
jnt2 = rigidBodyJoint('jnt2', 'revolute');
jnt2.JointAxis = [1 0 0]; % Revolute about X (Pitch)
% Translate UP by Link 1 length
setFixedTransform(jnt2, trvec2tform([0, 0, l_1]));
body2.Joint = jnt2;
addBody(robot, body2, 'link1');

% --- Gripper (Wrist) ---
bodyGrip = rigidBody('gripper');
jntGrip = rigidBodyJoint('jnt_grip', 'revolute');
jntGrip.JointAxis = [1 0 0]; % Revolute about X (Pitch)
% Translate UP by Link 2 length
setFixedTransform(jntGrip, trvec2tform([0, 0, l_2]));
bodyGrip.Joint = jntGrip;
addBody(robot, bodyGrip, 'link2');

% --- End Effector (Fingertips) ---
% We need a fixed point at the end of the 91mm gripper to track
bodyEnd = rigidBody('end_effector');
jntEnd = rigidBodyJoint('jnt_end', 'fixed');
% Translate UP by the Gripper length
setFixedTransform(jntEnd, trvec2tform([0, 0, l_grip]));
bodyEnd.Joint = jntEnd;
addBody(robot, bodyEnd, 'gripper');

% 3. Monte Carlo Simulation for Reachable Workspace
num_points = 20000; 
workspace_points = zeros(num_points, 3);

% Joint limits (in radians) - Adjust these if your servos hit the frame!
q_lim = [-pi, pi;  % Base Z Yaw limits
         -pi/2, pi/2;  % Link 1 X Pitch limits
         -pi/2, pi/2;  % Link 2 X Pitch limits
         -pi/2, pi/2]; % Gripper X Pitch limits

disp('Calculating workspace...');
for i = 1:num_points
    % Generate random joint configuration within limits
    q_rand = q_lim(:,1) + (q_lim(:,2) - q_lim(:,1)) .* rand(4,1);
    
    % Calculate Forward Kinematics to the FINGERTIPS
    tform = getTransform(robot, q_rand, 'end_effector');
    
    % Extract X, Y, Z translation
    workspace_points(i, :) = tform(1:3, 4)';
end

% 4. Visualization
figure('Name', 'BumbleBee Workspace', 'Color', 'w');

% Define the home configuration (bent)
q_home = [pi/2; pi/4; pi/6; pi/6];

% Plot the robot
show(robot, q_home, 'PreservePlot', false, 'Frames', 'on');
hold on;

% Add floating for ONLY the End Effector
tform_ee = getTransform(robot, q_home, 'end_effector');
pos_ee = tform_ee(1:3, 4);
text(pos_ee(1) + 20, pos_ee(2), pos_ee(3), 'End Effector', ...
    'FontSize', 9, 'FontWeight', 'bold', 'BackgroundColor', 'white', 'EdgeColor', 'black');

% Plot the point cloud
scatter3(workspace_points(:,1), workspace_points(:,2), workspace_points(:,3), ...
    4, workspace_points(:,3), 'filled', 'MarkerFaceAlpha', 0.15);

colormap(jet);
cb = colorbar;
cb.Label.String = 'Z Height (mm)';

title('BumbleBee Reachable Workspace');
xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('Z (mm)');
axis equal; grid on; view(45, 30);
disp('Calculation complete.');

% --- 5. Workspace Verification (Target Checking) ---

% Define your target points [X, Y, Z]
targets = [
    80.879, -124.543, 126.835+1.5;
   -80.879, -124.543, 126.835+1.5;
    0,      -148.500, 126.835+1.5;
    0,      -210.500, 126.835+1.5;
   -82.249, -193.766, 126.835+1.5;
    82.249, -193.766, 126.835+1.5;
    0,       125.000, 400.000
];

% Visually plot the target points as large green stars
hold on;
scatter3(targets(:,1), targets(:,2), targets(:,3), 150, 'g', 'p', 'filled', 'MarkerEdgeColor', 'k');

% Set up the Inverse Kinematics Solver
ik = inverseKinematics('RigidBodyTree', robot);

% CRITICAL FOR 4-DOF: Weights [Roll, Pitch, Yaw, X, Y, Z]
% We use 0 for orientation (ignore) and 1 for position (must match)
weights = [0, 0, 0, 1, 1, 1]; 
initialGuess = robot.homeConfiguration;

disp(' ');
disp('--- Target Reachability Report ---');
for i = 1:size(targets, 1)
    % Create transformation matrix for the target point
    targetTform = trvec2tform(targets(i, :));
    
    % Run the IK solver
    [config, info] = ik('end_effector', targetTform, weights, initialGuess);
    
    % Check if the solver succeeded with an acceptable error margin (< 1mm)
    if info.Status == "success" && info.PoseErrorNorm < 0.001
        fprintf('Point %d (%6.1f, %6.1f, %6.1f) : REACHABLE\n', i, targets(i,1), targets(i,2), targets(i,3));
    else
        fprintf('Point %d (%6.1f, %6.1f, %6.1f) : UNREACHABLE\n', i, targets(i,1), targets(i,2), targets(i,3));
    end
end
disp('----------------------------------');
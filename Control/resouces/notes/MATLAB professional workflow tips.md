## Mask
- [Creating a Mask: Masking Fundamentals - Simulink video](https://www.youtube.com/watch?v=7IUyTPQpQwc)
- Image masks
## Custom components
[Simscape 9th Episode: Creating Custom Components](https://www.youtube.com/watch?v=EhycUF1yMCo)
## Component-based modeling
[Component-Based Modeling in Simulink - YouTube](https://www.youtube.com/watch?v=fLVmzhCltHo)
## Custom libraries
- [Simulink Part 6 | Adding Libraries to Simulink Library Browser ( Create Custom Library ) | - YouTube](https://www.youtube.com/watch?v=0cQ3AGCIngw)
- [Add Libraries to Library Browser and Quick Insert - MATLAB & Simulink](https://www.mathworks.com/help/simulink/ug/adding-libraries-to-the-library-browser.html)
- [Libraries in Simulink Made Easy](https://www.youtube.com/watch?v=xWmIACn5Te0)
## Model and subsystem variants
- [Model Reference Variants - MATLAB & Simulink](https://www.mathworks.com/help/simulink/var/model-reference-variants.html)
## Parameterize with a Script
To make "Motor Selection" easy, create a `.m` script to store your motor data. This allows you to swap motors instantly without clicking through every block.
```matlab
% Motor Selection: NEMA 23 Example
R_motor = 0.45;      % Ohms
L_motor = 0.0012;    % Henrys
Kt_motor = 0.05;     % Torque Constant (Nm/A)
J_rotor = 1.2e-5;    % Rotor Inertia (kg*m^2)
```
### Configure the Callbacks
1. In the Model Properties window, navigate to the **Callbacks** tab.
2. On the left side, you will see a list of different callback triggers. You want to focus on two of them:
    - **`PreLoadFcn` (Runs when you open the model):** Select this and type the name of your script (without the `.m` extension - live scripts could also be used) into the text box on the right. For example, just type `robot_params`. This loads your variables into the workspace before the model even finishes rendering, preventing any "unrecognized variable" errors.
    - **`InitFcn` (Runs right before you hit Play):** I highly recommend putting your script name here as well. This way, if you have the model open, tweak a mass in your `.m` script, and hit "Run" in Simulink, it will automatically grab your newest numbers without you needing to manually run the script first.
### Startup script
```matlab
% --- Add Current Folder and ALL Subfolders to Path ---

% 1. Get the path to the folder where this script (startup.m) is located.

mainProjectRoot = fileparts(mfilename('fullpath'));

% 2. Use genpath to generate a list of all folders and subfolders

% starting from the mainProjectRoot.

allPaths = genpath(mainProjectRoot);

% 3. Add all generated paths to the MATLAB search path.

addpath(allPaths);

disp('Successfully added project root and all subfolders to the MATLAB path.');
```
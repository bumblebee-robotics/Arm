- "scope is in a locked system" > use a referenced subsystem or model
- [Loading and Logging Data in Simulink - MATLAB & Simulink](https://www.mathworks.com/videos/loading-and-logging-data-69029.html)
	- [Visualize Simulation Data in Simulink](https://www.youtube.com/watch?v=A1tvdhXRsE0)
	- [New Simulation Data Inspector](https://www.youtube.com/watch?v=ihFkwxysLwM)
	- [Inspect Simulation Data - MATLAB & Simulink](https://www.mathworks.com/help/simulink/ug/visual-inspection-of-signal-data.html)
	- [Simulink TIPS: Simulation data inspector](https://www.youtube.com/watch?v=ZrfFAUCnbhY)
	- [Simulink Data Inspector Secrets: Skip Scopes Forever! #matlab #simulink #electricalengineering](https://www.youtube.com/watch?v=cQmhU_-UYgM)
	- [Dashboard Block Library](https://www.youtube.com/watch?v=h5xXbMKhVrY&t=32s)
	- If you are pulling a lot of telemetry from a complex rigid body tree, managing multiple "To Workspace" blocks can become a headache. The cleaner, modern approach is to delete the "To Workspace" blocks entirely and use **Signal Logging**
		- You can log the signals directly **inside** your Subsystem Reference without adding a single Outport to the outside of the block. This keeps your main BumbleBee canvas perfectly clean and perfectly modular.
	- If you really love using "To Workspace" blocks and want them in your base MATLAB workspace immediately, simply move them outside the referenced file.
	- Adding virtual scopes
- Model reference = Simulink | Subsystem reference = Simulink + Simscape
	- Converting models to subsystem references requires detaching library link if present
- Ammeter is connected in series | Voltameter is connected in parallel
- Concatenating strings
```MATLAB
finalVarName = ['BumbleBee_', VarName, '_voltage'];
set_param([gcb, '/To Workspace'], 'VariableName', finalVarName);
```
- Parameterizing to workspace
	- In the Property Inspector on the right, uncheck the **Evaluate** box. This ensures Simulink treats whatever you type as pure text, not a mathematical variable.
	- In the Initialization commands box, paste this exact line: `set_param([gcb, '/To Workspace'], 'VariableName', VarName);`
	- Switch call back mode to mask (no need for external script files)
- Unable to modify contents of subsystem reference block
	- To fix this, you have to temporarily remove the code, complete the conversion, and then add the mask directly to the reference file itself (creating a "System Mask") with special permissions.
- Show hidden port labels
	- Open mask settings and look at the **Properties** pane on the right side. Find the **Port block names** dropdown.
	- Change it from "Hidden" to **Visible**.
- Actually making use of masks
	- Images
	- Text
	- Parameters
- Actually understanding model properties
	- Initialization call back functions
	- Model workspace
- Interfacing with simulink using code (`StopFcn`)
```MATLAB
% Extract the logged data
logs = out.logsout;

% Find specific paths (update these string names to match your blocks)
waist = logs.find('BlockPath', 'ROBOTIC_ARM_sim/Servo').Values.Data(end);
link1 = logs.find('BlockPath', 'ROBOTIC_ARM_sim/Servo1').Values.Data(end);
link2 = logs.find('BlockPath', 'ROBOTIC_ARM_sim/Servo2').Values.Data(end);

% Print a neat summary to the Command Window
disp('--- BumbleBee RMS Current Summary ---')
fprintf('Waist Servo: %f A\n', waist)
fprintf('Link 1 Servo: %f A\n', link1)
fprintf('Link 2 Servo: %f A\n', link2)
disp('-------------------------------------')
```
- Hiding things
	- In the **Diagnostics & Formatting** (or **Information Overlays**) section, look for a button called **Information Overlays**.
	- Signal names
		- **The Quick Click:** Click directly on the text label itself (a blue box will appear around it) and simply press **Delete** or **Backspace** on your keyboard. This removes the visual label but keeps the signal intact.
		- **The Right-Click Toggle:** Right-click the wire itself. In the context menu, look for **Show Signal Name** and uncheck it.
- Max of signal = min/max with memory block
- Library locking
	- **What the Library Lock protects:** It locks the display case. It prevents anyone from deleting the block from the library, changing its mask, or changing _which_ file the block points to.
	- **What the Library Lock DOES NOT protect:** It does not lock the destination file itself.
	- **Method 1: The OS-Level Lock (Quickest & Most Common)** Since Subsystem References are just standalone files, you can use your operating system to lock them down.
	- You could convert the referenced model into a **Protected Model** (`.slxp` file), which encrypts the contents and requires a password to open.
		- Because Subsystem References act as standalone files, putting them inside a custom Library is often redundant. Most teams either:
		- **Use purely Custom Libraries:** Build the standard subsystems directly inside the library `.slx` file (no references). When the library is locked, the instances are locked.
		- **Use purely Subsystem References:** Skip the custom library entirely. Just keep your `Servo_Ref.slx` files in your Current Folder and drag them directly onto your main canvas when you need them.
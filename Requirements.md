## General Concepts
- [[Concepts]]
![[Approaches]]
## The Task
> [!PDF|yellow] [[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=5&selection=131,0,135,46&color=yellow|Core Challenge]]
> > Core Challenge: The run is split into two phases: (1) a Manual Teleoperation Phase for initial maneuvering, and (2) a fully Autonomous Phase where the robot must rely solely on onboard sensors and computation to pick up/place the box and detect its color.

> [!PDF|yellow] [[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=7&selection=30,0,60,10&color=yellow|Safety Check]]
> > Pre-Competition Gate - Safety Check (Pass/Fail): the robot is inspected for wiring, sharp edges, mass, dimensions, fuse/protection, and PCB/electronics integrity. Failing teams must fix issues before competing.

![[Design Requirements 2026-02-09 04.29.29.excalidraw|650|center]]
> [!note] These actions should be repeatable
### Task Specifications
**Arena**
![[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=6&rect=69,364,591,625&color=yellow|Arena]]![[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=5&rect=59,115,508,206&color=yellow|Arena]]
**Interactive Zones**

> [!PDF|yellow] [[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=6&selection=14,0,18,13&color=yellow|Elevated Pickup Stations]]
> > Pickup Stations: elevated pedestals (approx. 40 cm height) holding cubes with QR code encoding their color. Access is constrained to test omni-capabilities:

|**Zone**|**Required Maneuver**|**Description**|
|---|---|---|
|**RED (Station A)**|**Pure Y Move**|You must approach the station straight-on and move purely forward/backward for final alignment before placing the cube.|
|**BLUE (Station B)**|**Pure X Move**|You must face the station _parallel_ and strafe sideways (lateral movement) to place the cube.|
|**GREEN (Station C)**|**Rotation Station**|You must align and then **rotate in place** to access and drop the cube.|

## The Features/Needs
### General Features
> [!PDF|yellow] [[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=2&selection=72,0,83,20&color=yellow|Manual Teleportation]]
> > The robot is manually operated along the track until it reaches a predefined landmark
> 
> [[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=5&selection=120,43,120,89&color=yellow|Through a Marked Lane]]
> > The robot must manually navigate a marked lane

> [!PDF|yellow] [[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=5&selection=116,46,120,41&color=yellow|Omni-directional drive]]
> >  a modular mobile manipulator robot equipped with an omni-directional drive (e.g., Mecanum or Kiwi)
> 
> 

> [!PDF|yellow] [[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=2&selection=85,0,91,4&color=yellow|Mode Switching]]
> > robot switches to autonomous mode
> 
> 

> [!PDF|yellow] [[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=2&selection=91,8,93,4&color=yellow|Autonomous Pick and Place]]
> > pick up a cube
> 
 > [[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=5&selection=122,0,123,37&color=yellow|Constrained Pickup Locations]]
> > autonomously retrieve QR code encoded colored cubes from constrained pickup stations using its arm
>
> [[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=5&selection=127,11,129,9&color=yellow|Colored drop-off zones]]
> > deliver them to matching colored drop-off zones
> 
> 

> [!PDF|yellow] [[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=5&selection=125,0,127,5&color=yellow|On-board Storage]]
> > store them on-board
> 
>  [[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=6&selection=78,9,80,79&color=yellow|On-board pin/rack]]
> > on-board bin/rack to securely hold at least 3 cubes simultaneously during transit.
> 

> [!PDF|yellow] [[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=2&selection=94,2,107,22&color=yellow|QR Code Recognition]]
> > Each cube is covered with a QR code that encodes the target box color
> 

> [!PDF|yellow] [[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=2&selection=109,0,111,29&color=yellow|Autonomous Navigation]]
> > correct landmark where the cube must be placed
> 
> > [!PDF|yellow] [[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=2&selection=133,0,139,38&color=yellow|State Estimation]]
> > During teleportation, teams can combine wheel encoder odometry, IMU-based heading stabilization, and additional sensors/AI tools as needed.
> 
> > [!note] Autonomous navigation is not required. However, it can be achieved by simple line following or wall following
### Project Requirements
> These are initial elements of the conceptual design
#### Functional
- Holonomic motion (using holonomic or omni-directional drive chain)
- Robotic arm with gripper (capable of lifting cubes from a ~40cm pedestal height and placing them into storage)
- Manual wireless teleportation
- Autonomous pick and place
- On-board storage bin/rack to hold 3 cubes simultaneously
- QR-code based color sorting
- Obstacle detection
- Repeatability
#### Modular
> [!PDF|yellow] [[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=6&selection=84,12,90,16&color=yellow|Independence and Plug-and-Play Interface]]
> > base module and manipulator module must be independently testable and integrate via plug-and-play interfaces.
> 
- Mobile base
	- Control sub-module
	- Power sub-module
	- Wheel motor encoders (odometry) for distance/speed measurement and precise holonomic motion control for pure x and pure y maneuvers
	- IMU heading stabilization to prevent unintended rotation and improve accuracy in strafing and rotation-zone maneuvers.
- Manipulator
	- Control sub-module
	- Power sub-module
	- Vision system (camera) capable of reading QR code to define box color
- Easy of assembly and disassembly (standard mechanical interface)
	- Mounting pattern
	- Alignment features
- Easy of connection and disconnection (standard electrical interface)
	- Power connector
	- Communication connector
- Communication protocol
	- Define the method: CAN/UART/Ethernet/RS-485
	- Heartbeat
		- Active monitoring (e.g. if the Mobile Base (master) stops receiving a heartbeat from the Manipulator (slave), it assumes the module has crashed or disconnected)
		- System integrity: (e.g. a continuous "keep-alive" check, preventing the robot from attempting to execute commands when one of its modules is unresponsive)
	- Safety states
		![[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=4&rect=59,360,517,514&color=yellow|MCT333_Project_Competition_Description_Spring2026_v4 (1), p.4]]
		- Emergency stop (e.g. disconnect power form all modules)
		- Failsafe mode (e.g. robot stops moving if it does not receive heartbeat and waits for manual intervention)
		- Transition points
- Optional sensors: proximity/ToF, depth camera, bump sensors, etc.

> [!note] Any open-source or reference designs used must be fully understood in terms of mechanical, electrical, and software considerations
#### Clean Finish and Safety Practices
##### Cable management
![[Pasted image 20260209155233.png]]
![[Pasted image 20260209155119.png]]
**Harness**
![[Pasted image 20260209155518.png]]
![[Pasted image 20260209155549.png]]
**Strain Relief**
![[Pasted image 20260209155644.png]]
![[Pasted image 20260209155809.png]]
**Extras**
- Cable Sleeves / Braided Sleeving / Spiral Wrap / Electrical Tape / Liquid Electrical Tape / Wire Dip Coating
- Wire Ducts / Cable Raceways
- Cable Ties (Zip Ties) & Mounts / Twisted Cable Ties, Twisted Flexible Cable Ties:, Cable Combs, Cable Clips
- Velcro Cable Ties / Straps
- Adhesive Cable Clips & Clamps
- Grommets
##### Electronics
- PCB
- Enclosure (pre-fabricated, custom 3d-printed, DIN rails, standoffs and spacers)
- [Connectors](https://www.ram-e-shop.com/shop/category/connectors-8)
	- Terminal blocks (screw terminals, lever-lock, screw cables like SMA cables)
	- Crimped connectors (JST SM, JST PH, Molex, DuPont, Barrel, MH4, Bullet Adapter, XT90, TRX, Deans, ID)
	- Heat shrink tubing
	- Crocodile connectors for testing
## Design Requirements
### Basic Requirements
![[MCT333_Project_Competition_Description_Spring2026_v4 (1).pdf#page=4&rect=58,531,540,720&color=yellow|MCT333_Project_Competition_Description_Spring2026_v4 (1), p.4]]
### System Performance Requirements
> [!quote] This should be Phase 0 of [[Timeline]]
> Example requirements include:
> - Speed
> - Payload
> - Accuracy
> - Autonomy Level
> - Safety


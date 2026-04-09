## $P_{battery} \approx P_{servo}$ $V_{battery} \times I_{battery} \approx V_{servo} \times I_{servo}$

If you use a **Buck Converter** (often sold as a UBEC in hobby robotics), your intuition is 100% correct. A switching regulator acts like an electronic gearbox. It converts high-voltage/low-current into low-voltage/high-current.

- **The Math:** If you have a 10V battery pack, the converter pulls the required 2.5W from the battery.
    
- 2.5W / 10V = **0.25A battery current.**
    
- _Reality Check:_ These converters are usually around 85% to 90% efficient, so it will actually draw slightly more than 0.25A to make up for the switching losses, but you are still cutting your battery current draw in half! This massively extends your runtime.

If you step the voltage down using a standard **Linear Regulator** (like the very common LM7805 chip), you will **not** save any battery current.

A linear regulator steps down voltage simply by acting like a smart resistor and burning off the excess voltage as raw heat.

- **The Math:** If the servo needs 0.5A, the linear regulator pulls that exact same 0.5A straight from the 10V battery.
    
- The battery is now delivering 5W of power (10V x 0.5A).
    
- The servo uses 2.5W of it, and the linear regulator physically burns the other 2.5W as heat (which is why these chips get blistering hot and need heatsinks). Your runtime is not improved at all.
## Sizing the C-Rating (Use Datasheet Worst-Case)
The C-rating is a measure of the battery's maximum safe discharge current. If you pull too much current from a battery with a low C-rating, the voltage will sag drastically (causing your electronics to reset) and the battery could catch fire.

**Do not use your simulation for this.** Size the C-rating for the apocalyptic worst-case scenario: all servos stalling at the exact same time.

- Count your servos (e.g., 4 arm joints + 1 gripper = 5 servos).
    
- Look up the **Stall Current** on the datasheet. Let's assume 750mA ($0.75\text{A}$).
    
- Calculate the Peak System Current:
    
    $$I_{peak} = 5 \times 0.75\text{A} = 3.75\text{A}$$
- Add a 20% safety margin for the microcontroller and sensors. You need a battery that can safely deliver **$\approx 4.5\text{A}$** continuously.
    
- If you buy a small 1000mAh ($1\text{Ah}$) battery, it needs a minimum discharge rating of **5C** ($1\text{Ah} \times 5\text{C} = 5\text{A}$). Most hobby LiPos are 20C+, so this is easy to hit, but if you are using custom 18650 lithium-ion packs for the robot, you must verify the cell's max discharge current.
## 2. Sizing the Capacity / Runtime (Use Scaled Simulation)

Capacity (mAh) determines how long the robot runs. You shouldn't use the stall current here, because the arm isn't stalling 100% of the time. This is where your simulated RMS current is actually useful, provided you scale it.

1. Take your simulated RMS current for the whole arm.
    
2. **Multiply it by 2** to account for gearbox inefficiencies, joint friction, and real-world thermal losses.
    
3. Add the continuous holding current of the gripper (if it has to actively pinch the 150g cube, it will draw continuous current).
    
4. This gives you a realistic $I_{average}$.
    

If your $I_{average}$ comes out to $1.5\text{A}$, and you want the robot to run for 2 hours, you need a battery capacity of:

$$Capacity = 1.5\text{A} \times 2\text{h} = 3\text{Ah} \text{ (or 3000mAh)}$$

---

## 1. Battery Packs and C-Ratings: Series vs. Parallel

When you build or buy a battery pack, the total safe current draw depends entirely on how the individual cells inside that pack are wired.

The C-rating itself is just a multiplier. To find the maximum continuous current ($I_{max}$) a cell can provide, you multiply its capacity (in Ah) by its C-rating:

$I_{max} = \text{Capacity} \times \text{C-rating}$

Here is how that scales when you combine cells into a pack:

- **Wired in Series (e.g., 2S, 3S):** If you wire cells end-to-end to increase the voltage, the maximum current draw **stays exactly the same as a single cell**.
    
    - _Example:_ If you put two 3000mAh, 5C cells (which can output 15A each) in series, your pack voltage doubles, but your maximum safe current is still **15A**. If your robot draws 20A, the batteries will overheat.
        
- **Wired in Parallel (e.g., 2P, 3P):** If you wire cells side-by-side to increase capacity, the maximum current draw **adds up**.
    
    - _Example:_ If you put those same two cells in parallel, your voltage stays the same, but your capacity becomes 6000mAh. Because both cells are sharing the load, your maximum safe current doubles to **30A**.
        

**The Rule of Thumb:** Calculate the $I_{max}$ of the _entire configured pack_. Your robot's absolute peak current draw (all motors stalling simultaneously) must be lower than the pack's $I_{max}$.

## 2. Sizing the Micro Servo for Runtime

A micro servo (like an SG90 or MG90S) actuating a gripper behaves very differently than an arm joint. Since it has to physically pinch and hold that 150g cube, it never gets to rest; the motor is constantly fighting the plastic flex of the gripper to maintain pressure.

Here is the breakdown of a typical 5V micro servo's current consumption:

- **Idle (Not moving, no load):** 10mA - 50mA
    
- **Moving (No load):** 150mA - 250mA
    
- **Holding a Load (Actively pinching):** 400mA - 500mA
    
- **Absolute Stall (Physically jammed):** 700mA - 800mA
    

For your runtime capacity math, you should assume the gripper servo will draw a continuous **400mA to 500mA (0.4A to 0.5A)** the entire time it is holding the cube.

To convert this to power (Watts) for your system-level runtime calculation:

$P_{gripper} = V \times I = 5\text{V} \times 0.5\text{A} = 2.5\text{W}$

**A Mechanical Warning:**

Forcing a cheap micro servo to pull 500mA continuously to hold a block will drain your battery surprisingly fast, and the tiny brushed motor inside will likely overheat and burn out if held for several minutes. If BumbleBee needs to hold that cube for a long time while the arm moves, consider designing the gripper with a mechanical linkage that "locks" over-center, or use a worm gear. This allows the motor to turn off completely (dropping to 10mA) while the mechanics hold the 150g load for free.


---
## The "Capacity" vs. "Energy" Trap

While you are entirely correct that the _capacity_ in Amp-hours doesn't increase, it is very important to know that the total **Energy** in the pack actually _does_ double.

In robotics, runtime isn't just about Amp-hours; it's about Watt-hours (Total Energy).

$Energy (\text{Wh}) = Voltage \times Capacity$

- **1 Cell:** $3.7\text{V} \times 3\text{Ah} = 11.1\text{Wh}$ of energy.
    
- **2 Cells in Series:** $7.4\text{V} \times 3\text{Ah} = 22.2\text{Wh}$ of energy.
    

Because your voltage doubled, your 2S pack holds twice as much total physical energy as a single cell.

This ties perfectly back to our earlier conversation about the buck converter. Because your buck converter acts as a smart transformer, feeding it 7.4V instead of 3.7V means it pulls exactly half the current from the battery to do the same amount of work. Even though the "Capacity" (mAh) didn't increase, your runtime still doubles because the battery is being drained half as fast!

## Here is the foolproof, step-by-step method to calculate your exact pack size using the "Energy Method."

### Step 1: Define Your Target Numbers

Before looking at batteries, you need three numbers from your robot:

1. **Average Power:** How many Watts the whole arm consumes while doing normal tasks (moving, holding the 150g cube). Let's assume **15W** for this example.
    
2. **Peak Power:** How many Watts the arm consumes if all servos stall at once. Let's assume **30W**.
    
3. **Target Runtime:** How long you want the robot to run continuously. Let's say **2 hours**.
    

### Step 2: Calculate Total Required Energy (Watt-hours)

To find out how big the "gas tank" needs to be, multiply your average power by your runtime.

$$Energy_{required} = P_{avg} \times t$$

- $15\text{W} \times 2\text{ hours} = \textbf{30Wh}$ (Watt-hours).
    

Your battery pack must hold at least 30Wh of total energy.

### Step 3: Size the Battery Pack (Series and Parallel)

Now, let's look at a standard 18650 lithium-ion cell. A typical good cell has these specs:

- **Voltage:** 3.7V nominal
    
- **Capacity:** 3000mAh (which is 3Ah)
    
- **Max Discharge:** 10C
    

First, calculate the energy inside **one single cell**:

$$Energy_{cell} = V_{cell} \times Capacity_{cell}$$

- $3.7\text{V} \times 3\text{Ah} = \textbf{11.1Wh}$ per cell.
    

**How many cells do you need in total?**

Divide your required energy by the energy of one cell:

- $30\text{Wh} / 11.1\text{Wh} \approx \textbf{2.7 cells}$.
    
    Since you can't buy 0.7 of a cell, you need a minimum of **3 cells** in your pack to hit your 2-hour runtime.
    

**How do we wire them? (The S and P configuration)**

- **Series (S) for Voltage:** Your buck converter needs a higher input voltage to step down to 5V efficiently. Let's wire 2 cells in series (2S). This gives you 7.4V.
    
- **Parallel (P) for Capacity:** A 2S pack only uses 2 cells (which gives you $22.2\text{Wh}$, falling short of your 30Wh goal). To increase capacity without increasing voltage, you add another "string" of 2 cells in parallel. This creates a **2S2P** pack (4 cells total).
    
- **Final Pack Specs:** 7.4V, 6000mAh (6Ah). Total energy: $7.4\text{V} \times 6\text{Ah} = \textbf{44.4Wh}$. This safely exceeds your 30Wh requirement!
    

### Step 4: Verify the C-Rating (The Safety Check)

Finally, ensure your chosen pack won't catch fire during a stall.

1. **Calculate the pack's max safe current:** Our 2S2P pack has a capacity of 6Ah. If the cells are rated for 10C:
    
    $$I_{safe\_max} = Capacity_{pack} \times C_{rating}$$
    
    - $6\text{Ah} \times 10 = \textbf{60A}$ safe continuous discharge.
        
2. **Calculate your robot's peak current draw:**
    
    If your arm stalls, it pulls your estimated Peak Power (30W) from the 7.4V battery pack.
    
    $$I_{peak} = \frac{P_{peak}}{V_{pack}}$$
    
    - $30\text{W} / 7.4\text{V} = \textbf{4.05A}$ peak draw.
        

Since your robot will only pull around 4A in the absolute worst-case scenario, and your 2S2P battery pack can safely deliver 60A, your C-rating is massively over-spec and perfectly safe.
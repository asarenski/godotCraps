# Godot Craps Roguelite: Game Vision

## High-Level Concept

The game is a dice-control roguelite built around a modified version of craps.

Rather than playing isolated casino rounds, the player attempts to survive an escalating run of multi-roll **sets**. During each set, the player commits to either the Pass side or the Don’t Pass side and places a wager. They then repeatedly establish and resolve points until their chosen side loses.

Between groups of sets, the player must reach increasingly difficult bankroll requirements. Successfully reaching a bankroll gate allows the player to select a new power-up card that changes how they prepare, throw, and control the dice.

The central fantasy is not merely becoming luckier. It is becoming a highly specialized dice thrower whose build, preparation, and execution can influence the physical behavior of the dice.

The player gradually develops a recognizable throwing style:

* A consistent 6 and 8 build
* A doubles and hardways build
* A low-variance controlled throw
* A chaotic high-luck throw
* A build centered around a particular dice axis
* A build that rewards risky wager doubling

The result should feel like a combination of craps, physics-based dice manipulation, deckbuilding, and escalating roguelite risk management.

---

## Player Fantasy

The player begins as an inexperienced shooter with limited control, a small maximum wager, and few advantages.

Over the course of a run, they become increasingly capable of:

* Setting the initial orientation of both dice
* Choosing a throwing technique
* Controlling force, spin, angle, and separation
* Reducing unwanted bounce and rotation
* Encouraging the dice to travel together
* Favoring certain totals or combinations
* Building around specific dice axes
* Taking increasingly dangerous financial risks

The player should feel that successful throws are influenced by both their decisions and their execution. Outcomes must remain uncertain, but knowledgeable players should be able to construct builds that noticeably change the probability landscape.

---

## Core Terminology

To avoid confusion between ordinary craps terminology and the game’s larger structure, the project should use the following working terms.

### Run

A complete roguelite attempt.

A run begins with the player’s starting bankroll and starting abilities. It ends when the player fails a bankroll requirement, loses all usable bankroll, or reaches the final progression goal.

### Set

A survival streak built around one Pass or Don’t Pass commitment.

At the beginning of a set, the player:

1. Chooses Pass or Don’t Pass.
2. Places a wager.
3. Commits to that side for the duration of the set.

The set continues through multiple point cycles until the player’s chosen side loses.

### Point Cycle

A sequence consisting of:

1. A come-out roll that establishes a point.
2. Additional throws until that point cycle resolves.
3. A choice to retain or increase the wager after a successful resolution.

A successful point cycle does not end the set. It allows the player to continue.

### Throw

One physical roll of the two dice.

A throw is influenced by initial dice orientation, player execution, character attributes, selected cards, and bounded randomness.

### Bankroll Gate

A required bankroll total checked after a group of sets.

Passing the gate allows the run to continue and grants a new card selection. Failing the gate ends the run.

---

## Core Set Loop

### 1. Choose a Side

At the beginning of each set, the player chooses:

* Pass
* Don’t Pass

This decision remains locked for the entire set.

Different builds may eventually favor one side, but both sides should remain viable strategic choices.

### 2. Place a Wager

The player places a wager from their current bankroll.

The maximum wager is limited by the player’s current level. This prevents the player from immediately risking their entire bankroll and makes increased wager capacity an important form of progression.

The wager represents both risk and momentum. Larger wagers allow the player to reach future bankroll gates more quickly, but they also make a set-ending loss more damaging.

### 3. Establish a Point

The player performs a come-out throw.

The come-out throw determines the point for the next point cycle. Come-out throws do not directly end the entire set.

The exact treatment of traditional come-out results such as 2, 3, 7, 11, and 12 will be defined separately as part of the game’s modified craps rules.

### 4. Resolve the Point Cycle

The player continues throwing until the point cycle resolves.

For a Pass player, the desired result is for the point to pass.

For a Don’t Pass player, the desired result is for the point not to pass.

When the player’s chosen side wins the point cycle:

* The set continues.
* The player retains the current wager.
* The player may be offered the opportunity to double or otherwise increase the wager.
* A new come-out throw begins the next point cycle.

When the player’s chosen side loses the point cycle:

* The set ends.
* The wager is settled.
* The game advances to the next set or checks the current bankroll gate.

This creates a push-your-luck structure. Each successful point cycle increases the player’s opportunity to gain bankroll, but continuing with an enlarged wager makes the eventual set-ending loss increasingly dangerous.

---

## Run Progression

A run is divided into groups of three sets.

After completing each group, the player must possess a minimum bankroll to continue.

Initial progression targets:

| Sets Completed |       Required Bankroll |
| -------------- | ----------------------: |
| 3              |                     150 |
| 6              |                   1,000 |
| 9              |                   3,000 |
| Later groups   | Increasing requirements |

The numbers are preliminary and will require balancing, but the intended pattern is clear:

* Early gates teach the system.
* Middle gates require a coherent build.
* Later gates require both a strong build and intelligent wagering.
* The player cannot survive indefinitely by making only minimum bets.
* The required bankroll rises faster than passive or extremely conservative play can support.

At each successful bankroll gate, the player chooses one new power-up card.

A run therefore alternates between:

1. Surviving sets
2. Growing the bankroll
3. Reaching a progression gate
4. Choosing a card
5. Adapting the throw strategy
6. Taking on more difficult financial requirements

---

## Player Level and Maximum Wager

The player’s level determines the maximum amount they may wager.

Level progression serves several purposes:

* Prevents extreme early-game betting
* Introduces risk gradually
* Creates meaningful rewards beyond bankroll
* Controls the pace at which the player can reach later gates
* Allows cards to interact with betting capacity

Level should likely increase during a run rather than being based only on permanent account progression.

Possible sources of run experience include:

* Completing a set
* Winning consecutive point cycles
* Executing difficult throws
* Rolling outcomes favored by the current build
* Reaching bankroll gates
* Successfully doubling a wager

Permanent progression may eventually unlock new starting cards, throw styles, characters, or card pools, but it should not remove the difficulty of bankroll management.

---

## Dice Throw System

The dice throw is the game’s primary form of player expression.

Each outcome should be influenced by four layers.

### 1. Dice Orientation

Before throwing, the player chooses how each die is positioned.

The visible top, front, and side faces determine the starting axis. Certain orientations naturally support particular strategies.

For example, a player may orient the dice around a 3V or “flying V” arrangement to favor a family of rotations and outcomes.

Orientation should matter without guaranteeing a result.

### 2. Throw Execution

The player performs the throw through a skill-based input system.

Potential throw variables include:

* Forward force
* Vertical force
* Release angle
* Spin
* Dice separation
* Timing
* Symmetry between the two dice
* Landing location

The control scheme should be understandable at a basic level but allow mastery through practice.

A beginner should be able to make a valid throw immediately. An experienced player should be able to intentionally reproduce similar throws.

### 3. Build Modifiers

Cards alter the conditions of the throw.

They may:

* Reduce rotational drift
* Improve consistency
* Favor matching dice behavior
* Preserve a selected axis
* Reduce bounce
* Increase or decrease variance
* Improve control at specific force levels
* Favor particular totals
* Reward particular face combinations
* Strengthen throws that meet execution requirements

Cards should generally influence the physical setup or probability distribution rather than directly replacing an unwanted result.

### 4. Bounded Randomness

Every throw retains uncertainty.

Even a highly optimized build should not guarantee a specific number. Collisions, table interaction, execution variance, and controlled random perturbations ensure that the player is managing probability rather than solving every throw deterministically.

Luck should influence the throw subtly. It may adjust tolerances, initial conditions, collision stability, or the likelihood that small variations favor the player’s build.

The game should avoid visibly changing a die after it has landed. The final result should appear to emerge from the throw itself.

---

## Deckbuilding and Power-Up Cards

Cards represent learned techniques, physical advantages, supernatural luck, equipment, or increasingly exaggerated mastery of dice control.

The player does not necessarily draw and play cards during every throw. Instead, the deckbuilding layer may function as a collection of passive and conditional powers assembled over the course of the run.

Each bankroll gate presents a limited selection of cards. The player chooses one, gradually creating a specialized build.

### Card Categories

#### Axis Control

Cards that help dice maintain or return to their initial rotational axis.

Examples:

* Reduced sideways rotation
* Improved 3V stability
* Better recovery after the first bounce
* Less axis drift when both dice are released evenly

#### Paired Dice

Cards that make the two dice behave more similarly.

Examples:

* More closely matched spin
* Reduced separation
* Similar bounce height
* Increased probability of correlated rotations
* Bonuses when the dice land close together

These cards can support doubles such as 3-3 and 4-4.

#### Total Specialization

Cards that favor particular totals or groups of totals.

Examples:

* Increased stability for 6 and 8 outcomes
* Bonuses for inside numbers
* Bonuses for hardways
* Bonuses for repeating the current point
* Improved control when targeting an even total

These should alter probabilities without making a desired total automatic.

#### Throw Technique

Cards that reward a specific type of execution.

Examples:

* Bonuses for low-force throws
* Bonuses for high arcs
* Bonuses for closely synchronized dice
* Bonuses for narrow landing zones
* Bonuses for minimal spin
* Bonuses for high-spin throws

These cards connect build construction directly to player skill.

#### Variance and Luck

Cards that change the amount or nature of randomness.

Examples:

* Lower variance but weaker maximum effects
* Higher variance with stronger favorable outcomes
* One die becomes more stable while the other becomes less stable
* Near-perfect throws receive a luck bonus
* Poorly executed throws receive limited correction

---

## Example Build: Flying V Sixes and Eights

A player might construct a build focused on rolling 6 and 8.

The player begins each throw with both dice arranged around a 3V axis. Their cards improve axis stability, reduce rotational drift, and reward synchronized releases.

Additional paired-dice cards cause both dice to travel and rotate more similarly. This increases the likelihood of combinations such as:

* 3-3
* 2-4
* 4-2
* 4-4
* 3-5
* 5-3

The player still needs to execute the throw correctly. An uneven release or excessive spin can break the intended axis and produce an unfavorable result.

This build is powerful because it combines:

* Intentional orientation
* Mechanical execution
* Card synergy
* Statistical specialization
* Remaining physical uncertainty

---

## Risk and Decision-Making

The game should not become a passive exercise in repeatedly using the same optimal throw.

The player must continually make decisions about:

* Pass versus Don’t Pass
* Initial wager size
* Whether to double after a successful point cycle
* Whether their current build is reliable enough for greater risk
* Whether to pursue consistency or high variance
* Which card best addresses the next bankroll requirement
* Whether to specialize further or cover a weakness

A strong dice build does not automatically create a strong run. The player must also manage bankroll growth and recognize when their throwing strategy is reliable enough to support larger wagers.

---

## Design Principles

### Skill Influences Probability

Player skill should create a meaningful statistical advantage without producing guaranteed results.

### The Physics Must Be Legible

Players should understand why a throw succeeded or failed. Orientation, release quality, card effects, and the resulting dice motion should be visible and learnable.

### Every Build Changes How the Player Throws

The strongest cards should change player behavior, not merely add invisible percentage bonuses.

### Wagering Creates Pressure

Bankroll gates should force the player to take calculated risks. Extremely conservative play should eventually become insufficient.

### Successful Sets Create Temptation

After winning a point cycle, retaining or doubling the wager should feel exciting and dangerous.

### Specialization Should Be Powerful but Fragile

A focused build should become noticeably effective, but no build should eliminate all unfavorable outcomes.

### Craps Is the Foundation, Not a Restriction

The game should retain recognizable craps concepts while modifying rules where necessary to support a longer roguelite structure.

---

## Major Rules Still to Define

The following decisions should be finalized before detailed implementation planning:

1. How traditional come-out results are handled when come-out throws cannot end a set
2. Whether a successful Pass or Don’t Pass point cycle pays immediately
3. Whether the wager remains committed between point cycles
4. How repeated doubling works
5. Whether the player may reduce a wager after increasing it
6. How bankroll is displayed while money is actively wagered
7. How player level increases during a run
8. Whether Pass or Don’t Pass can be changed between sets only
9. What happens on a push
10. The exact sequence for completing a set and checking bankroll
11. How physical execution is controlled with mouse, keyboard, touch, and controller
12. Whether luck affects initial conditions, physics behavior, final probabilities, or a combination
13. How much influence a fully developed build should have over expected outcomes
14. Whether cards are passive, equipped, drawn, consumed, upgraded, or combined
15. What constitutes victory for a complete run

---

## Vision Statement

Create a roguelite in which the player builds a personal dice-throwing style, applies that style through physical skill, and risks an increasingly valuable bankroll against escalating progression gates.

The player should finish a run remembering not only which cards they selected, but how their throw evolved: the dice orientation they relied on, the motion they learned to reproduce, the numbers their build favored, and the moment they decided to double a wager that could either save or end the run.

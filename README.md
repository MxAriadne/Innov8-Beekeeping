# Description 

We will be developing an educational Beekeeping game in Love2D for INNOV8 Africa, in conjunction with Vanderbilt University. This is completed as a part of MTSU's CSCI 5700 Software Engineering course.

# Group

- Freyja Richardson - Integrator & Debugger
- Stephanie Zhang - Economy & Progression
- Amelia Reiss - UI/UX Developer
- Elaina Vogel - Systems Developer
- Natalie Galvan - AI Developer
- Ming Chen - Base Gameplay Developer

Idea for group split:
- Base Gameplay Developer
	- Implement mechanics (movement, hive placement, event triggers)
- AI Developer
	- Implement predator AI (honey badgers breaking hives, wasps attacking colonies)
	- Implement bee colony behavior (foraging, returning with nectar, hive expansion).
- UI/UX Developer
	- Design and implement HUD elements (hive health, productivity bars, alerts).
	- UI menus for hive management, upgrades, and purchases.
	- Implement actual shopping mechanic and economy.
- Economy & Progression
	- Implement honey production and hive expansion.
	- Implement resource management systems (nectar collection, hive maintenance).
- Systems Developer
	- Event scripting (i.e. Colony growth, predator attacks.)
	- Implement save/load functionality to persist player progress.
	- Create educational tooltips in-game.
- Integrator & Debugger
	- Integrate all components (gameplay, UI, art, and educational elements).
	- Manage version control & project organization (GitHub, documentation).
	- Optimize existing code.

# Aims

###  Educational Highlights:  

1.  Introduces beekeeping practices, colony health, and nectar diversity.
### Game Loop

1.  **Startup Phase**  
	- Start with a small budget to purchase a basic hive and a queen bee.  
	- Place your hive in a designated area and plant flowers/trees nearby to attract bees.  
2. **Hive Management Phase**  
	- Monitor hive health by managing resources:  
		- Flowers/Trees: Ensure a variety of nectar sources for the bees.  
		- Hive Condition: Upgrade to better hives to accommodate larger colonies.  
		- Predator Defense: Build fences or elevate hives on poles to ward off honey badgers, wasps, and other threats.  
3. **Honey Production Phase**  
	- Bees collect nectar and produce honey over time.  
	- Players can check hive progress and decide when to harvest.  
	- Harvest honey and beeswax, which are converted into money based on market value.  
4. **Expansion Phase**  
	- Use money earned to:  
		- Buy more hives or better hive types.  
		- Invest in equipment (bee suits, smokers, tools).  
		- Expand flower/tree fields to increase honey production.  
	- Balance your resources to avoid overextending.

### Core Gameplay Mechanics

1. Hive Selection and Placement
	- Choose from different hive types, each with unique benefits:
		  - **Langstroth Hive**: High yield but expensive.
		  - **Top-Bar Hive**: Low maintenance but smaller output.
		  - **Traditional Log Hive**: Cheap but prone to pest issues.
	- Placement affects productivity:
		- Near flowers/trees for nectar.
		- Away from predators or shielded by defenses.

2. Predators and Threats
	- Random events challenge players to protect their hives:
		  - **Honey Badgers**: Break into unprotected hives.
		  - **Wasps**: Attack bees, lowering productivity.
		  - **Pesticides**: Reduce nectar availability.
	- **Counter these with strategies like:**
		  - Building fences or raising hives on poles.
		  - Planting bee-friendly flowers away from pesticide exposure.

3. Resource Management
	- **Flowers/Trees**: Balance planting costs with honey output.
	- **Bee Colonies**: Manage colony growth and ensure a queen is always present. Replace old queens to maintain productivity.
	- **Equipment**: Upgrade tools to make harvesting easier and safer.

4. Honey Harvesting and Profit
	- Harvest honey in different forms:
		  - **With Comb**: Higher price, lower yield.
		  - **Without Comb**: Lower price, higher yield.
	- **Beeswax** can also be harvested and sold or used to craft additional items.
		- **Players don’t handle manual sales**; money is deposited directly into the account upon harvesting.

5. Educational Elements
	- Simple tips teach about beekeeping practices:
		  - Why certain hive types work best in specific situations.
		  - Importance of planting diverse nectar sources.
		  - How to maintain bee colony health.

### Game Progression

1. Starting Out
	- Players begin with **one hive, a queen, and a small patch of flowers**.
	- Goals include harvesting enough honey to buy a **second hive and basic equipment**.

2. Mid-Game
	- Manage **multiple hives and colonies**.
	- Invest in **predator defenses** and expand the flower fields.
	- Unlock **advanced equipment and hive upgrades**.

3. Endgame
	- Scale up to a **thriving apiary** with diverse hive types and high honey output.
	- Achieve milestones like:
		  - Producing **1 ton of honey in a year**.
		  - Defending against a **major predator event**.

### User Interface

- **Top-Down View**: Display hives, flowers/trees, and surrounding areas.
- **HUD Elements:**
  - Hive health/status indicators.
  - Colony size and productivity bars.
  - Money and resource trackers.
  - Predator alerts and response options.

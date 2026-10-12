# Conway's Game of Life (Godot 4 Demo)

An expanded, interactive 2D simulation of Conway's Game of Life built with **Godot 4**. This project features an infinite grid system, dynamic viewport rendering, full camera controls, and custom cell rule variations.

FULL DISCLAIMER: Most of the hard work was done by Gemini(i.e. coding and documentation), but I have made edits to make things function in a way I find satisfactory.

## Key Features

* **Infinite Sparse Grid:** Uses dictionary-based coordinate tracking so cells can expand endlessly in any direction without map boundary constraints.

* **Viewport-Clipped Rendering:** Performs viewport bounds checks during `_draw()` to ensure high performance even when zoomed out across a massive world.

* **Camera System:** Full 2D panning and zooming capabilities.

* **Dual Cell Types:**

  * **Normal Cells (White):** Follow standard Conway's Game of Life rules ($B3/S23$).

  * **Inverted Cells (Red):** Follow inverted survival rules—they survive under conditions where standard cells usually die ($<2$ neighbors).

* **UI & Controls Overlay:** Displays game status, controls, and dynamic input updates via a canvas interface.

##  Game Controls

| Action | Input / Shortcut | 
| ----- | ----- | 
| **Add / Remove Normal Cell** | Left Mouse Click | 
| **Add / Remove Red Cell** | Right Mouse Click | 
| **Pan Camera** | `WASD` / Arrow Keys *or* Middle-Click Drag | 
| **Zoom In / Out** | Mouse Scroll Wheel Up / Down | 
| **Pause / Resume** | `Spacebar` | 
| **Clear Map** | `C` Key | 
| **Quit Game** | On-screen **Quit** Button (Bottom Left) | 

##  Cell Logic & Rules

### Standard Rules (White Cells)

1. **Underpopulation:** An alive white cell with fewer than $2$ alive neighbors dies.

2. **Survival:** An alive white cell with $2$ or $3$ alive neighbors lives on to the next generation.

3. **Overpopulation:** An alive white cell with more than $3$ alive neighbors dies.

4. **Reproduction:** Any dead cell with **exactly** $3$ **alive neighbors** becomes a live cell.

### Special Rules (Red Inverted Cells)

1. **Inverted Survival:** Alive red cells survive **only** when total adjacent neighbors are **less than** $2$.

2. **Inheritance Spawning:** When a dead cell is birthed via $3$ neighbors, it turns into a **Red Cell** if the majority of its adjacent neighbors are red.

## Project Architecture

```
GameOfLife (Node2D)          # Main script & infinite grid logic
├── Camera2D                 # Handles zoom and smooth pan transformations
└── UILayer (CanvasLayer)    # HUD layer decoupled from world space
    ├── InfoLabel (Label)    # Top-right corner control guide
    └── QuitButton (Button)  # Bottom-left corner application exit

```

##  How to Run

1. Open **Godot 4**.

2. Import or create a main scene containing a `Node2D` named `GameOfLife`.

3. Attach `game_of_life.gd` to the root node.

4. Add a `Camera2D` and a `CanvasLayer` (with a `Label` named `InfoLabel` and a `Button` named `QuitButton`).

5. Press **`F5`** to launch the project.

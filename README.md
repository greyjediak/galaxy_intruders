# Galaxy Intruders

## Project Summary
Galaxy Intruders is a space shooter game that runs on the Basys3 FPGA board. You fly a ship with a USB keyboard and press space to shoot lasers at aliens. The game is shown on a VGA monitor.

- **Keyboard input:** The USB keyboard plugs into the Basys3's USB port. The onboard PIC24 microcontroller turns key presses into PS/2 signals that the FPGA can read. Our logic syncs those signals to the Basys3 clock, shifts the bits into a shift register to get each scan code, and stores the codes in a FIFO. The game logic reads key presses from the FIFO.
- **VGA output:** This part isn't built yet. We're using a full-size VGA monitor, and we might draw the game in only a square part of the screen (not decided yet).
- **Gameplay:** Move the ship, shoot aliens with space, reset the game, and change the difficulty.

> Features are still changing. Treat this summary as the plan, not a final spec.

## Hardware
- Digilent Basys3 board (Artix-7, part `xc7a35tcpg236-1`)
- USB keyboard, plugged into the Basys3's USB port (labeled **USB HOST**, not the micro-USB programming port)
- VGA monitor and VGA cable
- Micro-USB cable, to power and program the Basys3 from your computer

## Repository Layout
```
FinalProject.xpr                    // Vivado project file; open this in Vivado
FinalProject.srcs/sources_1/new/    // our SystemVerilog design files (.sv)
sprites/                            // sprite art (.aseprite files)
.gitignore                          // tells git which files to skip
README.md                           // this file
```
Vivado creates other folders when you open or build the project (`.cache`, `.hw`, `.runs`, `.sim`, `.ip_user_files`). Those are ignored on purpose, so don't commit them.

---

## First-Time Setup
You only do this once per computer.

### 1. Install the tools
1. **Git:** Download it from https://git-scm.com/downloads and keep the default options in the installer.
2. **VS Code** (optional, but these instructions use it): https://code.visualstudio.com/
3. **Vivado 2025.2:** Download it from the AMD/Xilinx site. The free "Vivado ML Standard" edition works. Use **2025.2**, because other versions may ask to upgrade the project and that change can break things for everyone else.
4. **Basys3 board files:** Open Vivado, then go to **Tools > Vivado Store > Boards**. Search for **Basys3** and click Install. Without these, Vivado will warn about a missing board when you open the project.

### 2. Set up GitHub access
1. Make a GitHub account at https://github.com if you don't have one.
2. Send your GitHub username to the repo owner so they can add you as a collaborator. Then accept the email invite. You can't push changes until you accept it.
3. Tell git who you are. Open a terminal and run these two commands once, using the same email as your GitHub account:
   ```
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```
   The first time you push, a browser window will pop up asking you to sign in to GitHub. That's normal.

### 3. Get the code (clone the repo)
"Cloning" downloads the repo to your computer, already connected to GitHub. You do **not** need to run `git init`.

1. In File Explorer, pick the folder where you want the project to live, for example `C:\Documents\ECE580`.
   - Tip: Vivado sometimes has trouble with long folder paths or paths with spaces. A short path is safest.
2. In VS Code, go to **File > Open Folder** and open that folder.
3. Open a terminal with **Ctrl + `** (the backtick key, under Esc).
4. Run:
   ```
   git clone https://github.com/greyjediak/galaxy_intruders.git
   cd galaxy_intruders
   ```
   This creates a `galaxy_intruders` folder with everything inside it. From now on, run all git commands from inside this folder.

### 4. Open the project in Vivado
1. Open Vivado and click **Open Project**.
2. Go to your `galaxy_intruders` folder and select **FinalProject.xpr**.
3. Vivado rebuilds its working folders the first time. That's expected.

---

## Everyday Workflow

### Branches
A branch is your own copy of the code where you can make changes without affecting anyone else. **Never work directly on `main`.**

Before you start a new task, get the latest `main`, then make a branch from it:
```
git checkout main
git pull origin main
git checkout -b your-branch-name
```
Replace `your-branch-name` with something short that describes the work, like `vga-sync` or `alien-movement`. Don't type the `< >` brackets.

To see which branch you're on and what has changed, run:
```
git status
```

### Saving and pushing your changes
```
git status                          // see what changed
git add path/to/file.sv             // stage the files you want to save
git commit -m "describe what you did"
git push origin your-branch-name
```
`git add .` stages everything at once. It's fine to use, but run `git status` first so you don't commit something by accident.

### Getting your changes into main (pull request)
1. After you push, go to the repo on GitHub. You'll see a **Compare & pull request** button. Click it.
2. Write a short description of what you changed and click **Create pull request**.
3. A teammate looks it over and clicks **Merge**. Your changes are now in `main`.

### Staying up to date
Other people's changes don't show up on your computer automatically. `git status` won't download them either. To get them:
```
git checkout main
git pull origin main
git checkout your-branch-name
git merge main
```
**Close Vivado before you pull, merge, or switch branches.** Vivado keeps `FinalProject.xpr` open and can save its own copy over the changes git just made.

---

## Working in Vivado

### Adding a new design file
1. In Vivado, go to **File > Add Sources > Add or create design sources > Create File**.
2. Choose **SystemVerilog**, give the file a name, and leave the location as **<Local to Project>**.
3. The file is saved in `FinalProject.srcs/sources_1/new/`, so git will see it. Commit the new `.sv` file **and** `FinalProject.xpr`, because the `.xpr` is how Vivado knows the file belongs to the project.

If you add a file that already exists somewhere else on your computer, check **Copy sources into project**. Otherwise it stays outside the repo and nobody else gets it.

Constraints (`.xdc`) and simulation (testbench) files work the same way. Use **Add or create constraints** or **Add or create simulation sources** instead.

### If `FinalProject.xpr` has a merge conflict
Git says there's a conflict when two people changed the same part of a file. This happens with the `.xpr` when two people add files to the project at the same time. The easiest fix:
1. Keep the version from `main`: `git checkout --theirs FinalProject.xpr`
2. Open the project in Vivado and re-add your own files with **Add Sources** (choose the existing file this time).
3. Commit the fixed `.xpr`.

---

## Common Problems
| Problem | Fix |
|---|---|
| Vivado says the board part is missing | Install the Basys3 board files (see First-Time Setup, step 1.4). |
| Vivado asks to upgrade the project | You're using a different Vivado version. Close it without upgrading and install 2025.2. |
| `git push` gets "permission denied" or a 403 error | You haven't accepted the collaborator invite yet, or you're signed in to a different GitHub account. |
| Your new file isn't on GitHub | Check that it's inside the repo folder and that you committed it. Run `git status` to see. |
| Git wants to commit lots of `.runs`, `.cache`, or `.log` files | Those should be ignored. Don't commit them. Ask before you change `.gitignore`. |

## Altering the .gitignore
`.gitignore` lists files and folders that git should never track. Add one pattern per line:
```
foldername/        // ignore a whole folder
*.ext              // ignore every file ending in .ext
```
Git only ignores files it isn't already tracking. If a file is already committed, it stays tracked after you add it to `.gitignore`.

Built bitstreams (`.bit`) are ignored right now. To share one, remove the `*.bit` line from `.gitignore` first.

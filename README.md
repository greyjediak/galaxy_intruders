## Getting Setup
1. Get the URL or on Github, find Code > Copy URL to Clipboard.
2. In File Explorer, find or create where you want your main project folder to live. (e.g. finalproject)
3. In VSCode, open a window or create a workspace.
4. In VSCode, File > Open Folder, and get inside the folder you want everything to live in.
5. Open a terminal by pressing ctrl~ and navigate to that root folder (finalproject). ex: cd C:/Documents/finalproject.
6. In the terminal, run git clone https://github.com/greyjediak/galaxy_intruders
7. Make sure you're in the root project (you may have to cd into FinalProject).

## Branching
1. In terminal, check git status before branching
2. git checkout -b <branchname>   will automatically switch you to the new one and no <>! just replace with name

## Pushing Changes
Usually I do:
git add . (you're supposed to do git add /path/filename.ext but I never do)
git commit -m "your message here"
git push origin <branchname>
Changes now show in github and your branch can be merged with main
Never push to main (unless you just really want to)

## Staying Updated with Code Changes.
git status

## Altering the .gitignore.
*.folderyouwanttocompletelyignore/
*.

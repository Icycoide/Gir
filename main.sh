#!/bin/bash

function gir.main() {
    clear
    MENU_CHOICE=$(gum filter --header.foreground="#fe640b" --unselected-prefix.foreground="#fe640b" --selected-indicator.foreground="#fe640b" --indicator.foreground="#fe640b" --match.foreground="#fe640b" --prompt="| " --indicator=">" --header="Repository: $PWD ($(git branch | grep "*" | sed 's/* //g'))" --placeholder="Option" "Time Machine" "Add addition to last commit" "Edit last commit's message" "Correct an edit to a different branch" "Diff with fancy flag" "Undo file" "Undo commit" "Read file" "Add files to commit" "Remove files from commit" "Commit" "Push changes" "Pull changes" "Stash changes" "Switch branch" "Make new branch" "(Destructive) Reset to remote state" "(Re)initialise repository" "Information about current repo" "About" "Quit")
    case $MENU_CHOICE in
        "Time Machine")
            gir.timemachine
        ;;
        "Add addition to last commit")
            gir.tecommit
        ;;
        "Edit last commit's message")
            gir.editcommit
        ;;
        "Correct an edit to a different branch")
            gir.wrongbranch
        ;;
        "Diff with fancy flag")
            git diff --staged
        ;;
        "Undo file")
        	gir.undofile
        ;;
        "Undo commit")
            gir.undocommit
        ;;
        "Read file")
            gum pager < $(gum file --height=5 --selected.foreground="#fe640b" --all --cursor.foreground="#fe640b" --directory.foreground="#fe640b")
        ;;
        "Add files to commit")
            git add $(ls | gum filter --header.foreground="#fe640b" --selected-indicator.foreground="#fe640b" --indicator.foreground="#fe640b" --match.foreground="#fe640b" --no-limit --header "Add files" --prompt="| " --indicator="> " --selected-prefix "YES " --unselected-prefix " NO " --placeholder "Press TAB to select, Enter to confirm...")
        ;;
        "Remove files from commit")
            case $GIR_FORCEALL in
                1|TRUE|true)
                    git rm $(ls | gum filter --header.foreground="#fe640b" --selected-indicator.foreground="#d20f39" --indicator.foreground="#fe640b" --match.foreground="#fe640b" --no-limit --header "Remove files" --prompt="| " --indicator="> " --selected-prefix "REMOVE " --unselected-prefix "  KEEP " --placeholder "Press TAB to select, Enter to confirm...") -f
                ;;
                *)
                    git rm $(ls | gum filter --header.foreground="#fe640b" --selected-indicator.foreground="#d20f39" --indicator.foreground="#fe640b" --match.foreground="#fe640b" --no-limit --header "Remove files" --prompt="| " --indicator="> " --selected-prefix "REMOVE " --unselected-prefix "  KEEP " --placeholder "Press TAB to select, Enter to confirm...")
                ;;
            esac
        ;;
        "Commit")
            git commit -m "$(gum input --cursor.foreground="#fe640b" --width 50 --placeholder "Summary of changes")" \
                       -m "$(gum write --cursor.foreground="#fe640b" --width 80 --placeholder "Details of changes")"
        ;;
        "Push changes")
            git push
        ;;
        "Pull changes")
            git pull
        ;;
        "Stash changes")
        	git stash
        ;;
        "Switch branch")
            git checkout $(git branch | gum filter --header.foreground="#fe640b" --selected-indicator.foreground="#fe640b" --indicator.foreground="#fe640b" --match.foreground="#fe640b" --no-strict --header "Select branch to switch to" --prompt="| " --indicator="> " | sed 's/* //g' | sed 's/ //g')
        ;;
        "Make new branch")
            git checkout -b $(gum input --cursor.foreground="#fe640b" --placeholder "Enter the name of the new branch (no spaces, only hyphens) or leave empty to cancel. (Basing off $(git branch | grep "*"))")
        ;;
        "(Re)initialise repository")
        	git init
        ;;
        "(Destructive) Reset to remote state")
            gum confirm "You are about to reset this repository to the remote state, which will delete all untracked files and overwrite everything with whatever is stored remotely. Are you sure?" --affirmative="Yes, reset!" --negative="No, I changed my mind." --prompt.foreground="#d20f39" --selected.background="#d20f39" && gir.reset || echo "Operation cancelled."
        ;;
        "Information about current repo")
            git remote -v
            echo "           Branch | $(git branch | grep "*" | sed 's/* //g')"
            echo "Current directory | $PWD"
        ;;
        "About")
        	gir.about
        ;;
        "Quit")
            exit
        ;;
    esac
    read -p "Finished action \"$MENU_CHOICE\". Press Enter to proceed."
    gir.main
}

function gir.timemachine() {
    git reflog
    LINE_COUNT=$(git reflog | wc -l)
    MAX_OUT=$(($LINE_COUNT - 1))
    INDEX=$(gum input --cursor.foreground="#fe640b" --placeholder "Select the index to reset to...")
    clear
    git reflog | grep "HEAD@{$INDEX}"
    gum confirm "Selected index is $INDEX. Are you sure you want to time travel back to it?" --selected.background="#fe640b" --prompt.foreground="#fe640b" && git reset HEAD@{$INDEX} || echo "Operation cancelled."
}

function gir.tecommit() {
    gum confirm "Are you sure you want to amend the last commit? It is not recommended to do this with public commits" --selected.background="#fe640b" --prompt.foreground="#fe640b" || kill -INT $$
    git add $(ls | gum filter --header.foreground="#fe640b" --selected-indicator.foreground="#fe640b" --indicator.foreground="#fe640b" --match.foreground="#fe640b" --no-limit --header "Add files" --prompt="| " --indicator="> " --selected-prefix "YES " --unselected-prefix " NO " --placeholder "Press TAB to select, Enter to confirm...")
    git commit --amend --no-edit
}

function gir.editcommit() {
    gum confirm "Are you sure you want to amend the last commit? It is not recommended to do this with public commits" --selected.background="#fe640b" --prompt.foreground="#fe640b" || kill -INT $$
    git commit --amend
}

function gir.wrongbranch() {
    gum spin --spinner minidot --title "Undoing last commit..." -- git reset HEAD~ --soft
    git stash
    git checkout $(git branch | gum filter --header.foreground="#fe640b" --selected-indicator.foreground="#fe640b" --indicator.foreground="#fe640b" --match.foreground="#fe640b" --no-strict --header "Select the correct branch to commit to" --prompt="| " --indicator="> " | sed 's/* //g' | sed 's/ //g')
    git stash pop
    git add $(ls | gum filter --header.foreground="#fe640b" --selected-indicator.foreground="#fe640b" --indicator.foreground="#fe640b" --match.foreground="#fe640b" --no-limit --header "Add files" --prompt="| " --indicator="> " --selected-prefix "YES " --unselected-prefix " NO " --placeholder "Press TAB to select, Enter to confirm...")
    git commit -m
}

function gir.undocommit() {
    SEL_HASH=$(git log --oneline | gum filter --header.foreground="#fe640b" --selected-indicator.foreground="#fe640b" --indicator.foreground="#fe640b" --match.foreground="#fe640b" --header "Select hash to undo" --prompt="| " --indicator="> " | cut -d' ' -f1)
    git revert $SEL_HASH
}

function gir.undofile() {
    git checkout $(git log --oneline | gum filter --header.foreground="#fe640b" --selected-indicator.foreground="#fe640b" --indicator.foreground="#fe640b" --match.foreground="#fe640b" --header "Select hash to undo" --prompt="| " --indicator="> " | cut -d' ' -f1) -- $(gum file --show-help --all --file --directory --height=5 --selected.foreground="#fe640b" --cursor.foreground="#fe640b" --directory.foreground="#fe640b")
    git commit -m "$(gum input --width 50 --placeholder "Summary of changes (wow you didnt even have to copy-paste to undo)")" \
               -m "$(gum write --width 80 --placeholder "Details of changes")"
}

function gir.reset() {
    git fetch origin
    git checkout master || git checkout main
    git reset --hard origin/master || git reset --hard origin/main
    git clean -d --force
}

function gir.about() {
	echo "
gir version $GIR_VERSION
$(gum --version)
$(git --version)
host system kernel: $(uname -sr)

learn more about this release at:
https://github.com/Icycoide/Gir/releases/tag/v$GIR_VERSION"
}

function gir.variables() {
	GIR_VERSION=0.2.6
}

gir.variables
gir.main

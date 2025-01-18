#!/bin/bash

function gir.main() {
    clear
    git remote -v
    MENU_CHOICE=$(gum choose --header="Current directory: $PWD" "Time Machine" "Add addition to last commit" "Edit last commit's message" "Correct an edit to a different branch" "Diff with fancy flag" "Undo commit" "Read file" "Add files to commit" "Commit" "Push changes" "Pull changes" "(Destructive) Reset to remote state" "(Re)initialise repository" "Quit")
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
        "Undo commit")
            gir.undocommit
        ;;
        "Read file")
            gum pager < $(gum file --height=5)
        ;;
        "Add files to commit")
            git add $(ls | gum filter --no-limit --header "Add files" --prompt="| " --indicator="> " --selected-prefix "YES " --unselected-prefix " NO " --placeholder "Press TAB to select, Enter to confirm...")
        ;;
        "Remove files from commit")
            git rm $(ls | gum filter --no-limit --header "Add files" --prompt="| " --indicator="> " --selected-prefix "YES " --unselected-prefix " NO " --placeholder "Press TAB to select, Enter to confirm...")
        ;;
        "Commit")
            git commit -m "$(gum input --width 50 --placeholder "Summary of changes")" \
                       -m "$(gum write --width 80 --placeholder "Details of changes")"
        ;;
        "Push changes")
            git push
        ;;
        "Pull changes")
            git pull
        ;;
        "(Re)initialise repository")
        	git init
        ;;
        "(Destructive) Reset to remote state")
            gum confirm "You are about to reset this repository to the remote state, which will delete all untracked files and overwrite everything with whatever is stored remotely. Are you sure?" --affirmative="Yes, reset!" --negative="No, I changed my mind." --prompt.foreground="#d20f39" && gum spin --spinner minidot --title "Resetting repository to remote state..." -- gir.reset || echo "Operation cancelled."
        ;;
        "Quit")
            exit
        ;;
    esac
    read -p "Finished action $MENU_CHOICE. Press Enter to proceed."
    gir.main
}

function gir.timemachine() {
    git reflog
    LINE_COUNT=$(git reflog | wc -l)
    MAX_OUT=$(($LINE_COUNT - 1))
    INDEX=$(gum input --placeholder "Select the index to reset to...")
    clear
    git reflog | grep "HEAD@{$INDEX}"
    gum confirm "Selected index is $INDEX. Are you sure you want to time travel back to it?" && git reset HEAD@{$INDEX} || echo "Operation cancelled."
}

function gir.tecommit() {
    gum confirm "Are you sure you want to amend the last commit? It is not recommended to do this with public commits" || kill -INT $$
    git add $(ls | gum filter --no-limit --header "Add files" --prompt="| " --indicator="> " --selected-prefix "YES " --unselected-prefix " NO " --placeholder "Press TAB to select, Enter to confirm...")
    git commit --amend --no-edit
}

function gir.editcommit() {
    gum confirm "Are you sure you want to amend the last commit? It is not recommended to do this with public commits" || kill -INT $$
    git commit --amend
}

function gir.wrongbranch() {
    gum spin --spinner minidot --title "Undoing last commit..." -- git reset HEAD~ --soft
    git stash
    CORRECT_BRANCH=$(gum input --placeholder "Input the name of the correct branch")
    gum spin --spinner minidot --title "Running git checkout..." -- git checkout $CORRECT_BRANCH
    git stash pop
    git add $(ls | gum filter --no-limit --header "Add files" --prompt="| " --indicator="> " --selected-prefix "YES " --unselected-prefix " NO " --placeholder "Press TAB to select, Enter to confirm...")
    git commit -m
}

function gir.undocommit() {
    SEL_HASH=$(git log --oneline | gum filter | cut -d' ' -f1)
    git revert $SEL_HASH
}

function gir.undofile() {
    git checkout $(git log --oneline | gum filter | cut -d' ' -f1) -- $(gum file --show-help --all --file --directory --height=5)
}

function gir.reset() {
    git fetch origin
    git checkout master
    git reset --hard origin/master
    git clean -d --force
}

gir.main

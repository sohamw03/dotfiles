#!/bin/bash

unset dir
unset editor
unset proj_file
unset venv
unset is_cd

# Default settings
editor="nvim"
proj_file="/home/soham/CODE/proj.txt"
is_cd=false

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -p)
            if [ -n "$2" ]; then
                echo "$(pwd)/$2" >> "$proj_file"
                echo "Project path saved: $(pwd)/$2"
                dir="$(pwd)/$2"
                shift 2
            else
                echo "Error: No project path provided with -p."
                return 1
            fi
            ;;
        -e)
            if [ -n "$2" ]; then
                editor="$2"
                shift 2
            else
                echo "Error: No editor specified with -e."
                return 1
            fi
            ;;
        -cd)
            is_cd=true
            shift
            ;;
        *)
            echo "Invalid option: $1"
            return 1
            ;;
    esac
done

# If no project path was provided with -p, list all projects
if [ -z "$dir" ]; then
    dir=$(cat "$proj_file" | fzf --preview 'cat {}/README.md' --preview-window=right:50%:wrap)
    if [ -z "$dir" ]; then
        echo "No directory selected."
        return 1
    fi
fi

# Change to the project directory
cd "$dir" || { echo "Failed to change directory to $dir"; return 1; }
dir=$(pwd)

# Activate virtual environment if available
venv="$dir/.venv/bin/activate"
if [ -f "$venv" ]; then
    source "$venv"
fi

# Open editor in the current dir if is_cd is false
if [ "$is_cd" = false ]; then
    $editor .
fi


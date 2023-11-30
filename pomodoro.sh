#!/bin/bash

# Default values
POMODORO_DURATION=$((25 * 60))  # 25 minutes
BREAK_DURATION=$((5 * 60))      # 5 minutes
WORK_SESSIONS=0

# Function to display a notification
function show_notification() {
    if command -v notify-send &> /dev/null; then
        notify-send "$1" "$2"
    else
        echo "Please install notify-send to show notifications."
    fi
}

# Function to display information on separate lines with color and emoji
function show_info() {
    local session_type=$1
    local countdown=$2

    # ANSI color codes
    local light_blue='\033[1;34m'
    local light_red='\033[1;31m'
    local reset_color='\033[0m'

    # Emoji
    local tomato_emoji='🍅'

    # Move the cursor up four lines
    echo -e "${light_blue}Session: ${session_type}${reset_color}"
    echo -e "${light_red}Countdown:${reset_color} ${countdown} ${tomato_emoji}"
    echo -e "${light_red}Completed Work Sessions:${reset_color} ${WORK_SESSIONS}"
    echo -e "\033[4A"
}


# Function to start a Pomodoro session
function start_pomodoro() {
    local remaining_time=$POMODORO_DURATION

    ((WORK_SESSIONS++))

    while [ $remaining_time -gt 0 ]; do
        show_info "Work" "$(printf "%02d:%02d" $((remaining_time / 60)) $((remaining_time % 60)))"
        sleep 1
        ((remaining_time--))
    done

    show_notification "Pomodoro Timer" "Time is up! Take a break."
}

# Function to start a break session
function start_break() {
    local remaining_time=$BREAK_DURATION

    while [ $remaining_time -gt 0 ]; do
        show_info "Break" "$(printf "%02d:%02d" $((remaining_time / 60)) $((remaining_time % 60)))"
        sleep 1
        ((remaining_time--))
    done

    show_notification "Pomodoro Timer" "Break time is over. Get back to work!"
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--pomodoro)
            POMODORO_DURATION=$2
            shift
            ;;
        -b|--break)
            BREAK_DURATION=$2
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Main loop for continuous Pomodoro cycles
while true; do
    start_pomodoro
    start_break
done

#!/bin/bash

# Default values
POMODORO_DURATION=$((25 * 60))  # 25 minutes
BREAK_DURATION=$((5 * 60))      # 5 minutes
LONG_BREAK_DURATION=$((15 * 60)) # 15 minutes
SESSIONS_BEFORE_LONG_BREAK=4    # Default number of work sessions before a long break
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
    local light_blue='\033[38;2;120;120;255m'
    local light_red='\033[38;2;255;80;80m'
    local reset_color='\033[0m'

    # Emoji
    local tomato_emoji='🍅'

    # Move the cursor up four lines
    echo -e "${light_blue}Session:${light_red} ${session_type}    ${reset_color}"
    echo -e "${light_blue}Countdown:${light_red} ${countdown} ${reset_color} ${tomato_emoji}"
    echo -e "${light_blue}Completed Work Sessions:${light_red} ${WORK_SESSIONS}${reset_color}"
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

    # Check if it's time for a long break
    if [ $((WORK_SESSIONS % SESSIONS_BEFORE_LONG_BREAK)) -eq 0 ]; then
        start_long_break
    else
        start_break
    fi
}

# Function to start a short break session
function start_break() {
    local remaining_time=$BREAK_DURATION

    while [ $remaining_time -gt 0 ]; do
        show_info "Break" "$(printf "%02d:%02d" $((remaining_time / 60)) $((remaining_time % 60)))"
        sleep 1
        ((remaining_time--))
    done
}

# Function to start a long break session
function start_long_break() {
    local remaining_time=$LONG_BREAK_DURATION

    while [ $remaining_time -gt 0 ]; do
        show_info "Long Break" "$(printf "%02d:%02d" $((remaining_time / 60)) $((remaining_time % 60)))"
        sleep 1
        ((remaining_time--))
    done

    show_notification "Pomodoro Timer" "Long break is over. Get back to work!"
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
        -lb|--long-break)
            LONG_BREAK_DURATION=$2
            shift
            ;;
        -s|--sessions-before-long-break)
            SESSIONS_BEFORE_LONG_BREAK=$2
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
done

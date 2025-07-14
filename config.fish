# ────────────────
# Fish Shell Config (Dark Style)
# ────────────────

# Completely disable greeting
set -U fish_greeting

# Color scheme
set -g fish_color_normal white
set -g fish_color_command cyan
set -g fish_color_param white
set -g fish_color_error red
set -g fish_color_cwd green
set -g fish_color_cwd_root red
set -g fish_color_autosuggestion brblack
set -g fish_color_comment brblack
set -g fish_font_family "JetBrainsMono Nerd Font"
# Main prompt
function fish_prompt
    set -l last_status $status
    set -l pwd (prompt_pwd)

    # Color definitions
    set -l gray (set_color brblack)
    set -l white (set_color white)
    set -l cyan (set_color cyan)
    set -l red (set_color red)
    set -l green (set_color green)
    set -l reset (set_color normal)

    # Git branch
    set -l git_branch ""
    if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set git_branch (command git branch --show-current 2>/dev/null)
        if test -n "$git_branch"
            set git_branch " $gray($cyan$git_branch$gray)"
        end
    end

    # Status indicator
    set -l status_icon
    if test $last_status -ne 0
        set status_icon "$red✗$reset "
    else
        set status_icon "$green✓$reset "
    end

    # Build prompt
    echo -n "$gray┌─[$white$pwd$gray]$git_branch$reset"
    echo
    echo -n "$gray└─$reset $status_icon"
end

# Right prompt with time (fixed version)
function fish_right_prompt
    # First set all colors
    set -l gray (set_color brblack)
    set -l white (set_color white)
    set -l reset (set_color normal)

    # Then get time
    set -l time (date "+%H:%M")

    # Finally output with proper color reset
end

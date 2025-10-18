#!/bin/bash

#
# whatmatter - a tool for identifying the most important topics.
# In other wards, what matters to you the most.
#
# The idea is to increment the score of particular topic each time you see it.
# You do your everyday work and realize that something is important.
# You call this script and promote the topic.
# After some time you'll have a list with most important topics on the top.
#
# Topic scores a kept in db file (default: $XDG_DATA_HOME/whatmatter/whatmatter.txt).
#
# Synopsis:
#   whatmatter.sh <common-options> <command> <command-specific-parameters-or-common-options>
#
# Common options:
#   --verbose - set verbosity level
#   ...
#
# Commands:
#   * score - score selected of provided topic. This is a default command.
#
#     Parameters:
#       * topic - a term or topic to score (optional)
#         If not provided, a list of existing topics from 'db' files will be shown to choose from.
#
#     Examples:
#       ./whatmatter.sh score "smart contract"
#
#   * list - list all topics with scores
#
# Environment variables:
#   * WHATMATTER_DB - path to database file (default: $HOME/.config/whatmatter/whatmatter.txt)
#
# License: Apache License 2.0
#
# Copyright (c) 2025 Anton Pechinsky
#

toolVersion=${version}

#
# Dependency declaration.
#
# Supported dependency types:
#   - system:xxx - system dependency. exact tool or command availability (curl, awk, etc. )
#   - package:xxx - package dependency. (network-manager, network-manager-l2tp, etc). Experimental. Platform dependent.
#   - maven:xxx - shell script maven dependency (format: group:artifact:version:extension)
#   - custom:xxx - custom dependency check function.
#
dependencies='
system:sed
system:fzf
'

#
# Custom dependency check function.
#
# returns:
#   0 - if OK
#
checkCustomDependency() {
    # Custom dependency check
    echo
}

defineDefaults() {
    verbose=false

    dbHome="${XDG_DATA_HOME:-$HOME/.local/share}"

    basename=$(basename $0)
    name=${basename%.*}
    defaultDb="${dbHome}/${name}/${name}.txt"

    db=${WHATMATTER_DB:-$defaultDb}
}

main() {
    returnDependencies "$1"

    resolveDepencencies $dependencies

    defineDefaults

    if [[ ! -t 0 ]]; then
        local term="$(cat)"
        if [[ -n "$term" ]]; then
            addOrPromoteTerm "$term"
        fi
        exit 0
    fi

    while [[ -n "$1" && -z "$command" ]]; do

        case "$1" in

            -h | help )
                command="helpCommand" ;;

            -v | version )
                command="versionCommand" ;;

            score )
                command="scoreCommand" ;;

            list )
                command="listCommand" ;;

            * )
                echo "$@"
                if parseCommonArgument "$@"; then
                    shift
                else
                    die "Unexpected parameter: '$1'"
                fi
        esac

        shift
    done

    ${command:-scoreCommand} "$@"
}

#
# Parse single well-known argument from command line.
#
# parameters:
#   - command line
#
# returns:
#   0 - if argument was recognized
#   1 - if argument was NOT recognized
#
parseCommonArgument() {

    case "$1" in

        --verbose )
            shift
            verbose="$1";;

        * )
            return 1

    esac

    return 0
}

#
# List all topics with scores
#
listCommand() {
    echo "whatmatter db '$db'."

    if [[ ! -f "$db" ]]; then
        echo "Db '$db' does not exist."
        exit 0
    fi

    cat "$db" | sort -nr
}

#
# Score provided or choosen topic
#
scoreCommand() {
    ensureDbExists

    if [[ -n "$1" ]]; then
        addOrPromoteTerm "$1"
    else
        # cat "$db" | sort -nr | fzf --height=10 --layout=reverse --border | cut -d' ' -f2- | "$0"
        cat "$db" | sort -nr | fzf | cut -d' ' -f2- | "$0"
    fi
}

ensureDbExists() {
    if [[ ! -f "$db" ]]; then
        mkdir -p "$(dirname "$db")"
        touch "$db"
    fi
}

addOrPromoteTerm() {
    local term="$1"

    if grep -q "$term$" "$db" ; then
        promoteTerm "$term"
    else
        echo "1 $term" >> "$db"
    fi
}

promoteTerm() {
    local term="$1"
    sed -i -E "s/^([0-9]+) $term$/echo \$((\1 + 1)) $term/e" "$db"
}

###
### Common functions
###

#
# Print help message from script description
#
helpCommand() {
    sed -n '1d;/^#/{:loop n; /^[[:space:]]*$/q; s/#//p; b loop}' "$0"
}

#
# Print script version
#
versionCommand() {
    echo $toolVersion
}

#
# Returns real path where this script is physically located
#
getScriptDir() {
    command -v realpath >/dev/null 2>&1 || die "Script path can not be determined"
    echo "$( dirname "$( realpath $0 )" )"
}

#
# Returns dependencies of this script and exits.
#
# Useful for library scripts.
#
returnDependencies() {
    if [[ "$1" == "dependencies" ]]; then
        echo "$dependencies"
        exit 0
    fi
}

#
# Print a message to stderr.
#
# Usage
#   warn "format" ["arguments"...]
#
warn() {
    local format="$1"
    shift
    printf "${format}\n" "$@" >&2
}

#
# Print a message to stderr and exit with either the given status or
# that of the most recent command.
#
# Usage
#   some_command || die [status code] "message" ["arguments"...]
#
die() {
    local statusCode=$?

    if [[ "$1" != *[^0-9]* ]]; then
        statusCode="$1"
        shift
    fi

    echo "$@"
    exit "${statusCode}"
}

#
# Resolve dependencies
#
# Supported dependency types:
#   - system dependencies (system: wget, awk, etc.)
#   - shell script dependencies (maven:group:artifact:version:sh)
#   - custom dependency check function (custom:checkCustomDependency)
#
# parameters:
#   - dependency list
#
resolveDepencencies() {
    while [[ -n "$1" ]]; do

        if [[ $1 = system:* ]]; then
            checkSystemDependency "${1#system:}"

        elif [[ $1 = custom:* ]]; then
            "${1#custom:}"

        else
            die "Can not resolve dependency '$1'. No dependency type specifier."
        fi

        shift
    done
}

#
# Check if system dependency exists.
# 
# parameters:
#   - system dependency name (awk, sed, etc.)
#
checkSystemDependency() {
    command -v "$1" >/dev/null 2>&1 || die "Dependency '$1' is required. Use your package manager to install it."
}

main "$@"

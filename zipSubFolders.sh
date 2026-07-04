#!/opt/homebrew/bin/bash
#
# Filename: zipSubFolders.sh
# Project: File Management
# Version: 2.02
# Last Modified Date: 2026-04-01
# Category: File/Folder
# OS: Mac
# Maintainer: Cloud Box 9 Inc.
# -----------------------------------------------------------------------------
# Description:
#   Zips all subfolders within a target folder into a destination folder.
#   Cleans .DS_Store and desktop.ini files before zipping.
#   Optionally removes source folders after successful compression.
#
# Usage:
#   zipSubFolders.sh [OPTIONS] <targetFolder> [zipDestination]
#
# Arguments:
#   targetFolder      Folder containing subfolders to zip
#   zipDestination    Folder where zip files will be created (default: current folder)
#
# Options:
#   -r   Remove source folders after successful compression
#   -h   Show help and usage
#
# Example:
#   zipSubFolders.sh /Volumes/WD_BLACK/JCImportUnfiled
#   zipSubFolders.sh /Volumes/CB9-13Media/BPA_Media2025 /Volumes/BPA_16TB/BPA_MediaZipTemp
#   zipSubFolders.sh -r /Volumes/CB9-13Media/BPA_Media2025 /Volumes/BPA_16TB/BPA_MediaZipTemp
# -----------------------------------------------------------------------------
# Revision History:
# -----------------------------------------------------------------------------
# v2.02 (2026-04-01)
#   - zipDestination is now optional; defaults to current working directory
# -----------------------------------------------------------------------------
# v2.01 (2026-04-01)
#   - If target zip already exists, append -2 (or -3, -4, ...) to avoid collision
#   - Output shows renamed filename in brackets: OK (4.0K) [betty-2.zip]
# -----------------------------------------------------------------------------
# v2.0 (2026-04-01)
#   - CB9 compliant: dynamic-width header/footer, ANSI colors, copyright
#   - targetFolder and zipDestination now passed as arguments (no hardcoded paths)
#   - Added -r flag: remove source folders after successful compression
#   - Added -h flag: displays formatted help screen with usage and options
#   - Added execution header showing source, dest, start time, and active options
#   - Phase markers: Cleanup | Zipping | Remove
#   - Per-folder progress with [N/Total] counters and OK/FAILED status
#   - Execution summary: total folders, zipped, failed, removed counts
#   - Log written to ~/Documents/log/zipSubFolders.log
#   - Ctrl+C triggers clean exit screen
#   - Exit screen on completion and abort
# -----------------------------------------------------------------------------
# v1.0 (original)
#   - Initial version: zip all subfolders within a target folder
#   - Hardcoded targetFolder and zipDest paths
#   - Cleaned .DS_Store and desktop.ini before zipping
# =============================================================================

SCRIPT_NAME="Zip Sub Folders"
VERSION="2.02"
LOGFILE=~/Documents/log/zipSubFolders.log

# --------------------------
# ANSI Colors
# --------------------------
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[0;36m'
BRIGHT_CYAN='\033[1;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
RED='\033[0;31m'
BRIGHT_RED='\033[1;31m'
MAGENTA='\033[0;35m'

# --------------------------
# Terminal width
# --------------------------
TERM_WIDTH=$(tput cols 2>/dev/null || echo 100)

sep_line() {
    printf '%*s' "$TERM_WIDTH" '' | tr ' ' '='
    printf '\n'
}

# --------------------------
# Header
# --------------------------
print_header() {
    local page_detail="$1"
    printf '\n'
    sep_line
    printf " ${BRIGHT_CYAN}${SCRIPT_NAME}${RESET} ${DIM}v${VERSION}${RESET}"
    if [ -n "$page_detail" ]; then
        printf " ${GRAY}[${page_detail}]${RESET}"
    fi
    printf '\n'
    sep_line
}

# --------------------------
# Footer
# --------------------------
print_footer() {
    sep_line
    printf " ${DIM}Copyright © 2026 Cloud Box 9 Inc. All rights reserved.${RESET}\n"
}

# --------------------------
# Exit screen
# --------------------------
exit_screen() {
    local msg="${1:-exiting...}"
    clear
    sep_line
    printf " ${BRIGHT_CYAN}${SCRIPT_NAME}${RESET} ${DIM}v${VERSION}${RESET}\n"
    sep_line
    printf '\n'
    printf " ${GRAY}${SCRIPT_NAME} ${msg}${RESET}\n"
    printf '\n'
    printf " ${DIM}Copyright © 2026 Cloud Box 9 Inc. All rights reserved.${RESET}\n"
    printf '\n'
    sep_line
}

# --------------------------
# Help screen
# --------------------------
print_help() {
    print_header "Help"
    printf '\n'
    printf " ${YELLOW}USAGE${RESET}\n"
    printf "   zipSubFolders.sh ${CYAN}[OPTIONS]${RESET} ${CYAN}<targetFolder>${RESET} ${CYAN}[zipDestination]${RESET}\n"
    printf '\n'
    printf "   Zips each subfolder within targetFolder into a .zip file placed\n"
    printf "   inside zipDestination. Removes .DS_Store and desktop.ini before zipping.\n"
    printf '\n'
    printf " ${YELLOW}ARGUMENTS${RESET}\n"
    printf "   ${CYAN}targetFolder${RESET}     Folder whose subfolders will be zipped\n"
    printf "   ${CYAN}zipDestination${RESET}   Folder where .zip files are written (default: current folder)\n"
    printf '\n'
    printf " ${YELLOW}OPTIONS${RESET}\n"
    printf "   ${CYAN}-r${RESET}   Remove source folder after successful compression\n"
    printf "   ${CYAN}-h${RESET}   Show this help screen\n"
    printf '\n'
    printf " ${YELLOW}EXAMPLES${RESET}\n"
    printf "   ${DIM}zipSubFolders.sh /Volumes/Media /Volumes/ZipDest${RESET}\n"
    printf "   ${DIM}zipSubFolders.sh -r /Volumes/Media /Volumes/ZipDest${RESET}\n"
    printf '\n'
    printf " ${YELLOW}NOTES${RESET}\n"
    printf "   • Source folders are only removed when zip completes without error\n"
    printf "   • Log written to: ${GRAY}~/Documents/log/zipSubFolders.log${RESET}\n"
    printf '\n'
    print_footer
    printf '\n'
}

# --------------------------
# Log helper
# --------------------------
log() {
    local msg="$1"
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$msg" >> "${LOGFILE}"
}

# --------------------------
# Trap Ctrl+C
# --------------------------
trap 'printf "\n"; exit_screen "aborted."; log "--- Script aborted by user ---"; exit 130' INT

# --------------------------
# Parse arguments
# --------------------------
REMOVE_AFTER=false

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -r) REMOVE_AFTER=true; shift ;;
        -h) print_help; exit 0 ;;
        -*) printf "${RED}Error: Unknown option '$1'${RESET}\n"
            printf "Usage: zipSubFolders.sh [-r] [-h] <targetFolder> <zipDestination>\n"
            exit 1 ;;
        *)  break ;;
    esac
done

TARGET_FOLDER="$1"
ZIP_DEST="${2:-$(pwd)}"

# --------------------------
# Validate arguments
# --------------------------
if [ -z "$TARGET_FOLDER" ]; then
    printf "${RED}Error: targetFolder is required.${RESET}\n"
    printf "Usage: zipSubFolders.sh [-r] [-h] <targetFolder> [zipDestination]\n"
    exit 1
fi

if [ ! -d "$TARGET_FOLDER" ]; then
    printf "${RED}Error: targetFolder '$TARGET_FOLDER' not found.${RESET}\n"
    exit 1
fi

# Build options label for header
OPTIONS_LABEL="None"
if [ "$REMOVE_AFTER" = true ]; then
    OPTIONS_LABEL="-r (Remove source folders after zip)"
fi

# --------------------------
# Execution header
# --------------------------
clear
print_header "Running"
printf '\n'
printf "  ${YELLOW}Source ${RESET}: ${GRAY}${TARGET_FOLDER}${RESET}\n"
printf "  ${YELLOW}Dest   ${RESET}: ${GRAY}${ZIP_DEST}${RESET}\n"
printf "  ${YELLOW}Started${RESET}: ${GRAY}$(date '+%-I:%M:%S %p')${RESET}\n"
printf "  ${YELLOW}Options${RESET}: ${GRAY}${OPTIONS_LABEL}${RESET}\n"
printf '\n'
sep_line

START_EPOCH=$(date +%s)

# --------------------------
# Ensure log directory exists
# --------------------------
mkdir -p ~/Documents/log

log "======================================================================"
log "START: ${SCRIPT_NAME} v${VERSION}"
log "Source  : ${TARGET_FOLDER}"
log "Dest    : ${ZIP_DEST}"
log "Options : ${OPTIONS_LABEL}"
log "======================================================================"

# --------------------------
# Phase 1: Create zip destination if missing
# --------------------------
if [ ! -d "$ZIP_DEST" ]; then
    printf "\n ${MAGENTA}▶ Creating zip destination folder${RESET}\n"
    mkdir -p "$ZIP_DEST"
    chmod 777 "$ZIP_DEST"
    printf "   ${GREEN}Created: ${ZIP_DEST}${RESET}\n"
    log "Created zip destination: ${ZIP_DEST}"
fi

# --------------------------
# Phase 2: Cleanup
# --------------------------
printf "\n ${MAGENTA}▶ Cleanup${RESET} ${DIM}(removing .DS_Store and desktop.ini)${RESET}\n"
log "--- Phase: Cleanup ---"

DS_COUNT=$(find "${TARGET_FOLDER}" -name ".DS_Store" -type f 2>/dev/null | wc -l | tr -d ' ')
INI_COUNT=$(find "${TARGET_FOLDER}" -name "desktop.ini" -type f 2>/dev/null | wc -l | tr -d ' ')

find "${TARGET_FOLDER}" -name ".DS_Store" -type f -delete 2>/dev/null
find "${TARGET_FOLDER}" -name "desktop.ini" -type f -delete 2>/dev/null

printf "   ${GREEN}Removed ${DS_COUNT} .DS_Store and ${INI_COUNT} desktop.ini file(s)${RESET}\n"
log "Removed ${DS_COUNT} .DS_Store and ${INI_COUNT} desktop.ini files"

# --------------------------
# Phase 3: Count folders
# --------------------------
cd "$TARGET_FOLDER" || exit 1

FOLDERS=()
while IFS= read -r -d '' dir; do
    FOLDERS+=("$dir")
done < <(find . -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

TOTAL=${#FOLDERS[@]}

if [ "$TOTAL" -eq 0 ]; then
    printf "\n ${YELLOW}No subfolders found in ${TARGET_FOLDER}${RESET}\n"
    log "No subfolders found."
    printf '\n'
    print_footer
    printf '\n'
    exit 0
fi

# --------------------------
# Phase 4: Zipping
# --------------------------
printf "\n ${MAGENTA}▶ Zipping${RESET} ${DIM}(${TOTAL} folder(s) found)${RESET}\n"
log "--- Phase: Zipping (${TOTAL} folders) ---"

COUNT_OK=0
COUNT_FAIL=0
FAILED_FOLDERS=()

for dir in "${FOLDERS[@]}"; do
    DIR_NAME="${dir#./}"
    IDX=$((COUNT_OK + COUNT_FAIL + 1))
    # Resolve unique zip filename — append -2, -3, ... if file already exists
    ZIP_FILE="${ZIP_DEST}/${DIR_NAME}.zip"
    if [ -f "${ZIP_FILE}" ]; then
        SUFFIX=2
        while [ -f "${ZIP_DEST}/${DIR_NAME}-${SUFFIX}.zip" ]; do
            SUFFIX=$((SUFFIX + 1))
        done
        ZIP_FILE="${ZIP_DEST}/${DIR_NAME}-${SUFFIX}.zip"
    fi
    ZIP_BASENAME=$(basename "${ZIP_FILE}")

    printf "   ${CYAN}[%d/%d]${RESET} ${WHITE}%-40s${RESET}" "$IDX" "$TOTAL" "$DIR_NAME"
    log "[${IDX}/${TOTAL}] Zipping: ${DIR_NAME} -> ${ZIP_BASENAME}"

    zip -r "${ZIP_FILE}" "${DIR_NAME}" > /dev/null 2>&1
    ZIP_STATUS=$?

    if [ $ZIP_STATUS -eq 0 ]; then
        ZIP_SIZE=$(du -sh "${ZIP_FILE}" 2>/dev/null | awk '{print $1}')
        if [ "${ZIP_BASENAME}" != "${DIR_NAME}.zip" ]; then
            printf " ${BRIGHT_GREEN}OK${RESET} ${DIM}(${ZIP_SIZE}) [${ZIP_BASENAME}]${RESET}\n"
        else
            printf " ${BRIGHT_GREEN}OK${RESET} ${DIM}(${ZIP_SIZE})${RESET}\n"
        fi
        log "  OK -> ${ZIP_FILE} (${ZIP_SIZE})"
        COUNT_OK=$((COUNT_OK + 1))
    else
        printf " ${BRIGHT_RED}FAILED${RESET}\n"
        log "  FAILED: ${DIR_NAME}"
        COUNT_FAIL=$((COUNT_FAIL + 1))
        FAILED_FOLDERS+=("$DIR_NAME")
    fi
done

# --------------------------
# Phase 5: Remove source folders (if -r)
# --------------------------
COUNT_REMOVED=0
COUNT_REMOVE_FAIL=0

if [ "$REMOVE_AFTER" = true ]; then
    printf "\n ${MAGENTA}▶ Removing source folders${RESET}\n"
    log "--- Phase: Remove ---"

    for dir in "${FOLDERS[@]}"; do
        DIR_NAME="${dir#./}"
        ZIP_FILE="${ZIP_DEST}/${DIR_NAME}.zip"

        # Only remove if zip was successful (zip file exists)
        if [ -f "${ZIP_FILE}" ]; then
            printf "   ${CYAN}Removing${RESET} ${WHITE}${DIR_NAME}${RESET} ..."
            rm -rf "${TARGET_FOLDER}/${DIR_NAME}" 2>/dev/null
            RM_STATUS=$?
            if [ $RM_STATUS -eq 0 ]; then
                printf " ${BRIGHT_GREEN}OK${RESET}\n"
                log "  Removed: ${DIR_NAME}"
                COUNT_REMOVED=$((COUNT_REMOVED + 1))
            else
                printf " ${BRIGHT_RED}FAILED${RESET}\n"
                log "  Remove FAILED: ${DIR_NAME}"
                COUNT_REMOVE_FAIL=$((COUNT_REMOVE_FAIL + 1))
            fi
        else
            printf "   ${YELLOW}Skipped${RESET} ${WHITE}${DIR_NAME}${RESET} ${DIM}(no zip found)${RESET}\n"
            log "  Skipped remove (no zip): ${DIR_NAME}"
        fi
    done
fi

# --------------------------
# Summary
# --------------------------
END_EPOCH=$(date +%s)
RUN_SECS=$((END_EPOCH - START_EPOCH))
RUN_TIME=$(printf '%02d:%02d:%02d' $((RUN_SECS/3600)) $(((RUN_SECS%3600)/60)) $((RUN_SECS%60)))
END_TIME=$(date '+%-I:%M:%S %p')

printf '\n'
sep_line
printf " ${YELLOW}Summary${RESET}\n"
printf "  ${GRAY}End Time  : ${END_TIME}${RESET}\n"
printf "  ${GRAY}Run Time  : ${RUN_TIME}${RESET}\n"
printf '\n'
printf "  ${GRAY}Total Folders : ${TOTAL}${RESET}\n"
printf "  ${BRIGHT_GREEN}Zipped OK     : ${COUNT_OK}${RESET}\n"
if [ "$COUNT_FAIL" -gt 0 ]; then
    printf "  ${BRIGHT_RED}Zip Failed    : ${COUNT_FAIL}${RESET}\n"
    for f in "${FAILED_FOLDERS[@]}"; do
        printf "    ${RED}• ${f}${RESET}\n"
    done
else
    printf "  ${DIM}Zip Failed    : 0${RESET}\n"
fi

if [ "$REMOVE_AFTER" = true ]; then
    printf "  ${BRIGHT_GREEN}Folders Removed  : ${COUNT_REMOVED}${RESET}\n"
    if [ "$COUNT_REMOVE_FAIL" -gt 0 ]; then
        printf "  ${BRIGHT_RED}Remove Failed    : ${COUNT_REMOVE_FAIL}${RESET}\n"
    else
        printf "  ${DIM}Remove Failed    : 0${RESET}\n"
    fi
fi

printf '\n'
print_footer
printf '\n'

log "----------------------------------------------------------------------"
log "SUMMARY: Total=${TOTAL}  Zipped=${COUNT_OK}  Failed=${COUNT_FAIL}  Removed=${COUNT_REMOVED}  RunTime=${RUN_TIME}"
log "END: ${SCRIPT_NAME} v${VERSION}"
log ""

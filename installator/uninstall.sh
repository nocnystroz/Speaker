# --- Ensure script is run with bash ---
if [ -z "$BASH_VERSION" ]; then
    echo "Error: This script must be run with Bash. Please use 'bash installator/uninstall.sh'." >&2
    exit 1
fi

set -e # Exit on error

# --- Check for root privileges ---
if [ "$EUID" -eq 0 ]; then
    printf "${YELLOW}Script is running as root. Man page will be uninstalled automatically.\\n${NC}"
    RUN_AS_ROOT=true
else
    printf "${YELLOW}Script is NOT running as root. You will need to remove the man page manually if desired.\\n${NC}"
    RUN_AS_ROOT=false
fi

# --- Variables and Colors ---
INSTALL_DIR="$HOME/.local/share/speaker"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

printf "${YELLOW}This script will remove the Speaker tool and its configuration.\\n${NC}"
printf "${RED}WARNING: This action is irreversible.\\n${NC}"

# Confirmation prompt
read -r -p "Are you sure you want to continue? (y/n) " REPLY
echo
if [[ ! "$REPLY" =~ ^[Yy]$ ]]
then
    echo "Uninstallation cancelled."
    exit 1
fi

# --- Step 1: Remove the function from shell configuration files ---
printf "\\n${YELLOW}Step 1: Removing 'speak' function from shell configuration...\\n${NC}"

# Remove from .bashrc
if [ -f "$HOME/.bashrc" ]; then
    # Create a backup
    cp "$HOME/.bashrc" "$HOME/.bashrc.bak.$(date +%F)"
    # Use sed to remove the function block
    sed -i '/# --- Function for the Speaker tool ---/,/}/d' "$HOME/.bashrc"
    echo "Removed function from ~/.bashrc"
fi

# Remove from .zshrc
if [ -f "$HOME/.zshrc" ]; then
    # Create a backup
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%F)"
    sed -i '/# --- Function for the Speaker tool ---/,/}/d' "$HOME/.zshrc"
    echo "Removed function from ~/.zshrc"
fi

# --- Step 2: Remove the application directory ---
printf "\\n${YELLOW}Step 2: Removing application directory...\\n${NC}"
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "Removed directory $INSTALL_DIR"
else
    echo "Directory $INSTALL_DIR does not exist. Skipping."
fi

# --- Step 3: Remove Man Page (conditional on root privileges) ---
printf "\\n${YELLOW}Step 3: Removing Man Page...${NC}\\n"
if [ "$RUN_AS_ROOT" = true ]; then
    if [ -f "/usr/local/share/man/man1/speak.1.gz" ]; then
        rm "/usr/local/share/man/man1/speak.1.gz"
        mandb
        echo "Man page for 'speak' removed."
    else
        echo "Man page not found at /usr/local/share/man/man1/speak.1.gz. Skipping removal."
    fi
else
    echo "Man page removal requires root privileges. Please remove it manually if desired:"
    printf "${YELLOW}sudo rm /usr/local/share/man/man1/speak.1.gz\\n${NC}"
    printf "${YELLOW}sudo mandb\\n${NC}"
fi

# --- Completion ---
printf "\\n${GREEN}Uninstallation completed successfully!${NC}\\n"
echo "For the changes to take effect, please restart your terminal or run:"
printf "${YELLOW}source ~/.bashrc${NC} or ${YELLOW}source ~/.zshrc${NC}"
printf "\\nThe 'mpg123' package may still be installed. If you wish to remove it, you can do so manually, e.g., via:\\n"
printf "${YELLOW}sudo apt-get remove mpg123${NC}\\n"

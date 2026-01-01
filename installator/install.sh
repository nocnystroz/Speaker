#!/bin/bash

# Skrypt instalacyjny dla narzędzia Czytacz
# Uruchom ten skrypt z głównego katalogu repozytorium, np. przez: bash installator/install.sh

set -e # Przerwij w przypadku błędu

# --- Zmienne i kolory ---
INSTALL_DIR="$HOME/.local/share/czytacz"
REPO_DIR=$(pwd)
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Rozpoczynam instalację narzędzia Czytacz...${NC}"

# --- Krok 1: Wykrywanie menedżera pakietów i instalacja mpg123 ---
echo -e "\n${YELLOW}Krok 1: Sprawdzanie zależności systemowych (mpg123)...${NC}"

if command -v mpg123 &> /dev/null; then
    echo "mpg123 jest już zainstalowany."
else
    echo "Nie znaleziono mpg123. Próba instalacji..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y mpg123
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y mpg123
    elif command -v yum &> /dev/null; then
        sudo yum install -y mpg123
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm mpg123
    else
        echo -e "${YELLOW}Nie udało się automatycznie zainstalować mpg123. Proszę zainstaluj go ręcznie.${NC}" >&2
        exit 1
    fi
    echo "mpg123 został pomyślnie zainstalowany."
fi

# --- Krok 2: Tworzenie struktury katalogów i kopiowanie plików ---
echo -e "\n${YELLOW}Krok 2: Przygotowywanie katalogu aplikacji w $INSTALL_DIR...${NC}"
mkdir -p "$INSTALL_DIR"
cp "$REPO_DIR/czytacz.py" "$INSTALL_DIR/"
cp "$REPO_DIR/requirements.txt" "$INSTALL_DIR/"
cp "$REPO_DIR/.env.example" "$INSTALL_DIR/"
echo "Pliki aplikacji zostały skopiowane."

# --- Krok 3: Tworzenie środowiska wirtualnego i instalacja zależności Python ---
echo -e "\n${YELLOW}Krok 3: Konfiguracja środowiska wirtualnego Python...${NC}"
python3 -m venv "$INSTALL_DIR/venv"
source "$INSTALL_DIR/venv/bin/activate"
pip install -r "$INSTALL_DIR/requirements.txt"
deactivate
echo "Zależności Python zostały zainstalowane w środowisku wirtualnym."

# --- Krok 4: Konfiguracja polecenia 'czytaj' w powłoce ---
echo -e "\n${YELLOW}Krok 4: Dodawanie polecenia 'czytaj' do Twojej powłoki...${NC}"

CZYTAJ_FUNCTION=$(cat <<'EOF'

# --- Funkcja dla narzędzia Czytacz ---
function czytaj() {
    local CZYTACZ_DIR="$HOME/.local/share/czytacz"
    local PYTHON_EXEC="$CZYTACZ_DIR/venv/bin/python"
    local SCRIPT_PATH="$CZYTACZ_DIR/czytacz.py"

    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "Błąd: Nie znaleziono skryptu czytacza w '$SCRIPT_PATH'." >&2
        return 1
    fi

    if [ $# -eq 0 ]; then
        "$PYTHON_EXEC" "$SCRIPT_PATH" --help
        return 0
    fi

    "$PYTHON_EXEC" "$SCRIPT_PATH" "$@"
}
EOF
)

# Sprawdzenie i dodanie funkcji do .bashrc
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "# --- Funkcja dla narzędzia Czytacz ---" "$HOME/.bashrc"; then
        echo -e "\n$CZYTAJ_FUNCTION" >> "$HOME/.bashrc"
        echo "Dodano funkcję 'czytaj' do ~/.bashrc"
    else
        echo "Funkcja 'czytaj' już istnieje w ~/.bashrc. Pomijam dodawanie."
    fi
fi

# Sprawdzenie i dodanie funkcji do .zshrc
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "# --- Funkcja dla narzędzia Czytacz ---" "$HOME/.zshrc"; then
        echo -e "\n$CZYTAJ_FUNCTION" >> "$HOME/.zshrc"
        echo "Dodano funkcję 'czytaj' do ~/.zshrc"
    else
        echo "Funkcja 'czytaj' już istnieje w ~/.zshrc. Pomijam dodawanie."
    fi
fi

# --- Zakończenie ---
echo -e "\n${GREEN}Instalacja zakończona pomyślnie!${NC}"
echo "Aby zacząć korzystać z polecenia 'czytaj', uruchom ponownie terminal lub wpisz:"
echo -e "${YELLOW}source ~/.bashrc${NC} (jeśli używasz bash)"
echo "lub"
echo -e "${YELLOW}source ~/.zshrc${NC} (jeśli używasz zsh)"
echo -e "\nNie zapomnij skonfigurować kluczy API, kopiując i edytując plik:"
echo -e "${YELLOW}cp $INSTALL_DIR/.env.example $INSTALL_DIR/.env${NC}"

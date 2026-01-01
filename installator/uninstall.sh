#!/bin/bash

# Skrypt deinstalacyjny dla narzędzia Czytacz

# --- Zmienne i kolory ---
INSTALL_DIR="$HOME/.local/share/czytacz"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Ten skrypt usunie narzędzie Czytacz i jego konfigurację.${NC}"
echo -e "${RED}UWAGA: To działanie jest nieodwracalne.${NC}"

# Pytanie o potwierdzenie
read -p "Czy na pewno chcesz kontynuować? (t/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Tt]$ ]]
then
    echo "Deinstalacja anulowana."
    exit 1
fi

# --- Krok 1: Usunięcie funkcji z plików konfiguracyjnych powłoki ---
echo -e "\n${YELLOW}Krok 1: Usuwanie funkcji 'czytaj' z konfiguracji powłoki...${NC}"

# Usunięcie z .bashrc
if [ -f "$HOME/.bashrc" ]; then
    # Tworzenie kopii zapasowej
    cp "$HOME/.bashrc" "$HOME/.bashrc.bak.$(date +%F)"
    # Użycie sed do usunięcia bloku funkcji
    sed -i '/# --- Funkcja dla narzędzia Czytacz ---/,/}/d' "$HOME/.bashrc"
    echo "Usunięto funkcję z ~/.bashrc"
fi

# Usunięcie z .zshrc
if [ -f "$HOME/.zshrc" ]; then
    # Tworzenie kopii zapasowej
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%F)"
    sed -i '/# --- Funkcja dla narzędzia Czytacz ---/,/}/d' "$HOME/.zshrc"
    echo "Usunięto funkcję z ~/.zshrc"
fi

# --- Krok 2: Usunięcie katalogu aplikacji ---
echo -e "\n${YELLOW}Krok 2: Usuwanie katalogu aplikacji...${NC}"
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "Usunięto katalog $INSTALL_DIR"
else
    echo "Katalog $INSTALL_DIR nie istnieje. Pomijam."
fi

# --- Zakończenie ---
echo -e "\n${GREEN}Deinstalacja zakończona pomyślnie!${NC}"
echo "Aby zmiany weszły w życie, uruchom ponownie terminal lub wpisz:"
echo -e "${YELLOW}source ~/.bashrc${NC} lub ${YELLOW}source ~/.zshrc${NC}"
echo -e "\nPozostałością może być pakiet 'mpg123'. Jeśli chcesz go usunąć, możesz to zrobić ręcznie, np. przez:"
echo -e "${YELLOW}sudo apt-get remove mpg123${NC}"

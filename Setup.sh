#!/bin/sh

FORE_YELLOW="$(tput setaf 3)"
STYLE_RESET="$(tput sgr0)"

failure() {
    echo "FAIL | $@"
    exit 127
}

header() {
    echo "${FORE_YELLOW}$@${STYLE_RESET}"
}

check_dependencies() {
    header "Automatically detecting dependencies..."
    printf -- "- git: "
    if ! command -v -- "git" > /dev/null 2>&1; then
        echo "not found."
        failure "Setup currently doesn't handle installing 'git' automatically."
    else
        echo "OK."
    fi
    printf -- "- gum: "
    if ! command -v -- "gum" > /dev/null 2>&1; then
        echo "not found."
        install_dep_gum
    else
        echo "OK."
    fi
}

install_dep_gum() {
    echo "
Install Gum through:
 1: Homebrew
 2: Pacman
 3: Nix(-env)
 4: Flox
 5: Winget
 6: Scoop
 7: APT
 8: RPM(YUM)
 9: RPM(DNF)
10: RPM(Zypper)"
    read -p "Installation method > " OPT
    case $OPT in
        1)
            brew install gum
        ;;
        2)
            pacman -S gum
        ;;
        3)
            nix-env -iA nixpkgs.gum
        ;;
        4)
            flox install gum
        ;;
        5)
            winget install charmbracelet.gum
        ;;
        6)
            scoop install charm-gum
        ;;
        7)
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
            sudo apt update && sudo apt install gum
        ;;
        8|9|10)
            echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
            sudo rpm --import https://repo.charm.sh/yum/gpg.key
            case $OPT in 
                8)
                    sudo yum install gum
                ;;
                9)
                    sudo dnf install gum
                ;;
                10)
                    sudo zypper refresh
                    sudo zypper install gum
                ;;
            esac
    esac
}

install_gir() {
    header "Installing Gir..."
	echo "    1: /usr/bin/
    2: /usr/local/bin/
Other: Input any path"
    read -p "What directory should Gir be installed to? > " INSTALL_PATH
	case $INSTALL_PATH in
		1)
			INSTALL_PATH=/usr/bin
		;;
		2)
			INSTALL_PATH=/usr/local/bin
		;;
		*)
			echo "Ok!"
		;;
	esac
    sudo wget -O $INSTALL_PATH/gir https://github.com/Icycoide/Gir/releases/download/v0.2.6/main.sh || failure "Either failed download or invalid path or sudo does not exist."
    sudo chmod +x $INSTALL_PATH/gir || failure "Either insufficient permissions or file does not exist or sudo does not exist."
}

check_dependencies
install_gir

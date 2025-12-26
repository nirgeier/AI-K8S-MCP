#!/bin/bash

###############################################################################
# K-Agent Labs - Demo Launcher
# This script provides an interactive menu to launch any lab demo
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print banner
print_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║              K-AGENT LABS - DEMO LAUNCHER                 ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Print lab menu
print_menu() {
    echo -e "${GREEN}Available Labs:${NC}\n"
    
    labs=(
        "000:Environment Setup:15 min"
        "001:MCP Basics:10 min"
        "002:TypeScript MCP Server:15 min"
        "003:Python MCP Server:12 min"
        "004:Kubernetes Deployment:15 min"
        "005:Kubectl Tool:12 min"
        "006:Cluster Inspector:12 min"
        "007:Helm Integration:12 min"
        "008:PostgreSQL Tool:15 min"
        "009:ConfigMaps & Secrets:12 min"
        "010:Remote MCP Server:12 min"
        "011:Google GKE:15 min"
        "012:GCP SDK Tools:12 min"
        "013:Security & RBAC:15 min"
        "014:Production Ready:15 min"
    )
    
    for lab in "${labs[@]}"; do
        IFS=':' read -r num title duration <<< "$lab"
        printf "${YELLOW}%3s${NC} | ${BLUE}%-30s${NC} | ${CYAN}%s${NC}\n" "$num" "$title" "$duration"
    done
    
    echo ""
    echo -e "${GREEN}Options:${NC}"
    echo -e "  ${YELLOW}all${NC}  - Run all labs sequentially"
    echo -e "  ${YELLOW}q${NC}    - Quit"
    echo ""
}

# Run lab demo
run_lab() {
    local lab_num=$1
    local lab_dir="Labs/${lab_num}"
    
    if [ ! -d "$lab_dir" ]; then
        echo -e "${RED}✗ Lab directory not found: $lab_dir${NC}"
        return 1
    fi
    
    if [ ! -f "$lab_dir/_demo.sh" ]; then
        echo -e "${RED}✗ Demo script not found: $lab_dir/_demo.sh${NC}"
        return 1
    fi
    
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}▶ Running Lab $lab_num Demo${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    
    cd "$lab_dir"
    bash _demo.sh
    local exit_code=$?
    cd - > /dev/null
    
    echo ""
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ Lab $lab_num completed successfully${NC}"
    else
        echo -e "${RED}✗ Lab $lab_num failed with exit code $exit_code${NC}"
    fi
    echo ""
    
    return $exit_code
}

# Run all labs
run_all_labs() {
    echo -e "${YELLOW}Running all labs sequentially...${NC}\n"
    
    for i in {0..14}; do
        lab_num=$(printf "%03d" $i)
        lab_dir=$(find Labs -maxdepth 1 -type d -name "${lab_num}-*" 2>/dev/null | head -n 1)
        
        if [ -n "$lab_dir" ]; then
            run_lab "$(basename $lab_dir)"
            
            echo -e "${CYAN}Press Enter to continue to next lab...${NC}"
            read -r
        fi
    done
    
    echo -e "${GREEN}✓ All labs completed!${NC}"
}

# Main function
main() {
    print_banner
    
    while true; do
        print_menu
        echo -n "Select a lab number (or 'all'/'q'): "
        read -r choice
        
        case $choice in
            q|Q|quit|exit)
                echo -e "${CYAN}Goodbye!${NC}"
                exit 0
                ;;
            all|ALL)
                run_all_labs
                ;;
            [0-9]|[0-9][0-9]|[0-9][0-9][0-9])
                # Pad to 3 digits
                lab_num=$(printf "%03d" $choice)
                
                # Find the lab directory
                lab_dir=$(find Labs -maxdepth 1 -type d -name "${lab_num}-*" 2>/dev/null | head -n 1)
                
                if [ -n "$lab_dir" ]; then
                    run_lab "$(basename $lab_dir)"
                else
                    echo -e "${RED}✗ Lab $lab_num not found${NC}"
                fi
                ;;
            *)
                echo -e "${RED}✗ Invalid choice. Please select a valid lab number, 'all', or 'q'${NC}"
                ;;
        esac
        
        echo ""
        echo -e "${CYAN}Press Enter to return to menu...${NC}"
        read -r
        clear
        print_banner
    done
}

# Check if running from project root
if [ ! -d "Labs" ]; then
    echo -e "${RED}✗ Error: Must run from project root directory${NC}"
    echo -e "${YELLOW}  Run: cd /path/to/ && bash demo.sh${NC}"
    exit 1
fi

main

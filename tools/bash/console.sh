write-error(){
    local RED='\033[0;31m'
    local NC='\033[0m' # No Color
    echo -e "${RED}ERROR: $1${NC}"
}

write-warning(){
    local YELLOW='\033[1;33m'
    local NC='\033[0m' # No Color
    echo -e "${YELLOW}WARNING: $1${NC}"
}

write-success(){
    local GREEN='\033[0;32m'
    local NC='\033[0m' # No Color
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

write-message(){
    echo "$1"
}
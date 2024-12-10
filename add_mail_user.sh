#!/bin/bash
set -e

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Please ensure K3s is properly installed."
    exit 1
fi

# Function to show usage
usage() {
    echo "Usage: $0 {add|del|list} [username@domain] [password]"
    echo "Examples:"
    echo "  $0 add user@domain.com password"
    echo "  $0 del user@domain.com"
    echo "  $0 list"
    exit 1
}

# Check arguments
case "$1" in
    add)
        if [ "$#" -ne 3 ]; then
            usage
        fi
        kubectl exec -n mail deployment/mailserver -- setup email add "$2" "$3"
        ;;
    del)
        if [ "$#" -ne 2 ]; then
            usage
        fi
        kubectl exec -n mail deployment/mailserver -- setup email del "$2"
        ;;
    list)
        kubectl exec -n mail deployment/mailserver -- setup email list
        ;;
    *)
        usage
        ;;
esac
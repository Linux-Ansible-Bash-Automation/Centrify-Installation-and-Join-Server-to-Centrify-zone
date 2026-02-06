#!/usr/bin/env bash

set -euo pipefail

PLAYBOOK="centrify.yml"

# ---------- Colors ----------
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

echo "${BLUE}=== CentrifyDC Install & AD Join ===${RESET}"

# ---------- Become method ----------
echo
echo "Choose privilege escalation method:"
echo "  1) sudo"
echo "  2) dzdo"
read -rp "Enter choice [1-2]: " BECOME_CHOICE

case "$BECOME_CHOICE" in
  1) BECOME_METHOD="sudo" ;;
  2) BECOME_METHOD="dzdo" ;;
  *)
    echo "${RED}Invalid choice. Exiting.${RESET}"
    exit 1
    ;;
esac

# ---------- AD Join toggle ----------
echo
echo "Join Active Directory?"
echo "  1) Yes"
echo "  2) No"
read -rp "Enter choice [1-2]: " AD_JOIN_CHOICE

case "$AD_JOIN_CHOICE" in
  1) DO_AD_JOIN=true ;;
  2) DO_AD_JOIN=false ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

# ---------- AD Details ----------
if [[ "$DO_AD_JOIN" == "true" ]]; then
  read -rp "AD Domain (example.com): " AD_DOMAIN
  read -rp "AD Zone: " DOMAIN_JOIN_ZONE
  read -rp "Domain Join User: " DOMAIN_JOIN_USER
  read -srp "Domain Join Password: " DOMAIN_JOIN_PASSWORD
  echo
  read -rp "AD Server (optional, press Enter to skip): " AD_SERVER
else
  AD_DOMAIN=""
  DOMAIN_JOIN_ZONE=""
  DOMAIN_JOIN_USER=""
  DOMAIN_JOIN_PASSWORD=""
  AD_SERVER=""
fi


# ---------- SSH & Become passwords ----------
echo
read -rp "SSH Username: " SSH_USER
read -srp "SSH Password: " SSH_PASS
echo
read -srp "Become (${BECOME_METHOD}) Password: " BECOME_PASS
echo

# ---------- Run Ansible ----------
echo
echo "${YELLOW}Running Ansible playbook...${RESET}"

ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook "$PLAYBOOK" \
  -u "$SSH_USER" \
  --become \
  --extra-vars "
    ansible_password=${SSH_PASS}
    ansible_become_password=${BECOME_PASS}
    play_become_method=${BECOME_METHOD}
    do_ad_join=${DO_AD_JOIN}
    ad_domain=${AD_DOMAIN}
    domain_join_zone=${DOMAIN_JOIN_ZONE}
    domain_join_user=${DOMAIN_JOIN_USER}
    domain_join_password=${DOMAIN_JOIN_PASSWORD}
    ad_server=${AD_SERVER}
  "

RC=$?

if [[ $RC -eq 0 ]]; then
  echo "${GREEN}✔ Centrify install / AD join completed successfully${RESET}"
else
  echo "${RED}✖ Playbook failed. Check logs.${RESET}"
fi

exit $RC

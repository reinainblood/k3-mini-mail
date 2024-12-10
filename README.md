# Self-Hosted Mail Server Deployment

This project contains everything needed to deploy a production-ready mail server using K3s and docker-mailserver.

## Project Structure
```
mailserver-deployment/
├── README.md
├── ansible/
│   ├── inventory/
│   │   └── hosts.yml
│   ├── group_vars/
│   │   └── all.yml
│   ├── roles/
│   │   ├── k3s/
│   │   │   ├── tasks/
│   │   │   │   └── main.yml
│   │   │   └── templates/
│   │   │       └── k3s.service.j2
│   │   └── mailserver/
│   │       ├── tasks/
│   │       │   └── main.yml
│   │       └── templates/
│   │           └── values.yaml.j2
│   └── site.yml

└── scripts/
    ├── setup.sh
    └── add-mail-user.sh
```

## Prerequisites

1. A server running Ubuntu 20.04 or newer
2. Domain name with DNS access
3. SSH access to the server
4. Python 3.x installed on your local machine

## Quick Start

1. Clone this repository:
```bash
git clone <repository-url>
cd mailserver-deployment
```

2. Update configuration:
   - Edit `ansible/inventory/hosts.yml` with your server details
   - Edit `ansible/group_vars/all.yml` with your domain and email settings
   - (Optional) Edit `terraform/terraform.tfvars` if using Terraform

3. Run the setup:
```bash
# Using the setup script (recommended)
chmod +x scripts/setup.sh
./scripts/setup.sh

# OR manually with Ansible
cd ansible
ansible-playbook -i inventory/hosts.yml site.yml
```

4. Add email users:
```bash
./scripts/add-mail-user.sh user@yourdomain.com password
```

## Required DNS Records

Add these records to your domain's DNS configuration:

```
mail.yourdomain.com.     IN A     <Your-Server-IP>
yourdomain.com.          IN MX 10 mail.yourdomain.com.
yourdomain.com.          IN TXT   "v=spf1 ip4:<Your-Server-IP> -all"
_dmarc.yourdomain.com.   IN TXT   "v=DMARC1; p=reject; rua=mailto:postmaster@yourdomain.com"
```

## Maintenance Commands

### Check System Status
```bash
# Check K3s status
sudo systemctl status k3s

# Check pods
kubectl get pods -n mail

# Check logs
kubectl logs -n mail deployment/mailserver
```

### Manage Email Users
```bash
# Add user
./scripts/add-mail-user.sh add user@domain.com password

# Delete user
./scripts/add-mail-user.sh del user@domain.com

# List users
./scripts/add-mail-user.sh list
```

### Update Installation
```bash
# Update helm chart
helm upgrade mailserver docker-mailserver/docker-mailserver -n mail

# Update K3s
sudo systemctl stop k3s
curl -sfL https://get.k3s.io | sh -
sudo systemctl start k3s
```

## Configuration Files

### Key Locations
- K3s config: `/etc/rancher/k3s/k3s.yaml`
- Mail data: `/var/lib/rancher/k3s/storage/mail-data`
- SSL certificates: Managed by Let's Encrypt in K8s secrets

### Important Ports
- SMTP: 25, 465 (SSL), 587 (TLS)
- IMAP: 143, 993 (SSL)
- HTTP: 80 (Let's Encrypt verification)
- HTTPS: 443

## Troubleshooting

1. Check pod status:
```bash
kubectl get pods -n mail
kubectl describe pod -n mail <pod-name>
```

2. View logs:
```bash
kubectl logs -n mail deployment/mailserver
```

3. Common issues:
   - Port 25 blocked by ISP: Contact your provider
   - SSL certificate issues: Check Let's Encrypt logs
   - Authentication failures: Verify user creation
   - DNS issues: Verify records with `dig` or `nslookup`

## Security Notes

1. Default security measures:
   - SpamAssassin enabled
   - ClamAV virus scanning
   - DMARC, SPF, and DKIM configured
   - TLS enforced for SMTP and IMAP

2. Additional recommendations:
   - Regular system updates
   - Monitoring and alerts setup
   - Regular backup configuration
   - Firewall rules verification

## Backup and Recovery

1. Backup mail data:
```bash
kubectl exec -n mail deployment/mailserver -- backup
```

2. Restore from backup:
```bash
kubectl exec -n mail deployment/mailserver -- restore
```

## Support and Documentation

- [docker-mailserver Documentation](https://docker-mailserver.github.io/docker-mailserver/edge/)
- [K3s Documentation](https://rancher.com/docs/k3s/latest/en/)
- [Helm Chart Repository](https://github.com/docker-mailserver/docker-mailserver-helm)

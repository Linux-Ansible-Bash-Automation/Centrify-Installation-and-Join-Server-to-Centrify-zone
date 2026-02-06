# CentrifyDC Installation & Active Directory Join

**Bash + Ansible Automation**

This project provides an **interactive Bash wrapper** around an **Ansible playbook** to automate:

* Installation of **CentrifyDC**
* Optional **Active Directory (AD) domain join**
* Support for **multiple Linux distributions**
* Flexible privilege escalation (`sudo` or `dzdo`)

The goal is to make Centrify installation and AD join **safe, repeatable, and user-friendly**.

---

## 📂 Project Structure

```text
.
├── run-centrify.sh        # Interactive Bash wrapper
├── centrify.yml           # Ansible playbook
└── README.md
```

---

## 🚀 Features

* Interactive prompts (no long CLI arguments)
* Supports **sudo** and **dzdo**
* Optional AD join (install only or install + join)
* OS-aware repo and package handling
* Secure password handling (`read -s`, `no_log: true`)
* DNS and AD join validation
* Idempotent AD join logic (safe re-runs)

---

## 🖥️ Supported Operating Systems

### Red Hat Family

* RHEL / CentOS / AlmaLinux / Rocky

  * **7**
  * **8**
  * **9**

### Debian Family

* Ubuntu

  * **18.04**
  * **20.04**
  * **22.04**
  * **24.04**

---

## 🔐 Prerequisites

### Control Node

* Bash
* Ansible 2.9+
* Network access to:

  * Target servers
  * Internal Centrify/Delinea repo host

### Managed Nodes

* SSH access
* Python installed
* DNS configured correctly (FQDN → A record)
* Internet or internal repo access

---

## ⚙️ How It Works

### 1️⃣ Bash Wrapper (`run-centrify.sh`)

The Bash script:

* Prompts for:

  * Privilege escalation method (`sudo` / `dzdo`)
  * Whether to join Active Directory
  * AD domain details (if enabled)
  * SSH and become passwords
* Passes all values securely to Ansible using `--extra-vars`

### 2️⃣ Ansible Playbook (`centrify.yml`)

The playbook:

* Detects OS and version
* Configures appropriate Centrify/Delinea repository
* Installs required dependencies (`certutil`, `nss-tools`)
* Installs **CentrifyDC**
* Enables and restarts services
* Optionally joins the server to Active Directory

---

## ▶️ Usage

### Make script executable

```bash
chmod +x run-centrify.sh
```

### Run the automation

```bash
./run-centrify.sh
```

### Interactive Flow

1. Choose privilege escalation:

   * `sudo`
   * `dzdo`
2. Choose whether to join AD
3. (If joining AD) Provide:

   * AD domain
   * Zone
   * Join user
   * Password
   * Optional AD server
4. Enter:

   * SSH username/password
   * Become password
5. Ansible playbook executes

---

## 🧩 Key Variables Passed to Ansible

| Variable                  | Description                   |
| ------------------------- | ----------------------------- |
| `play_become_method`      | `sudo` or `dzdo`              |
| `do_ad_join`              | `true` / `false`              |
| `ad_domain`               | Active Directory domain       |
| `domain_join_zone`        | Centrify zone                 |
| `domain_join_user`        | AD join account               |
| `domain_join_password`    | AD join password              |
| `ad_server`               | Optional specific AD server   |
| `ansible_password`        | SSH password                  |
| `ansible_become_password` | Privilege escalation password |

---

## 🔄 AD Join Logic (Safe & Idempotent)

* Checks current AD join status using `adinfo`
* If already joined → skips join
* If object exists in AD:

  * Retries with `--forceDeleteObj`
* Handles known return codes safely:

  * `0` → success
  * `22` → object exists

---

## 🧪 DNS Validation

Before joining AD, the playbook:

* Checks DNS **A record** for the server FQDN
* Prints a clear status message:

  * `FOUND`
  * `NOT FOUND`

> Note: The server will join to AD if no DNS records are configured.

---

## 🔒 Security Considerations

* Passwords are:

  * Read securely (`read -srp`)
  * Never logged (`no_log: true`)
* No credentials stored in files
* SSH host key checking disabled only for execution scope

---

## 🛠️ Customization

### Change Repo Host

Edit in `centrify.yml`:

```yaml
repo_host: "your-repo-server.example.com"
```

### Change File names

Edit playbook tasks to match file names as yours

### Disable AD Join by Default

```yaml
do_ad_join: false
```

---

## 🧯 Troubleshooting

### Playbook fails early

* Verify SSH credentials
* Ensure Python is installed on target
* Check `/tmp` permissions (must be `1777`)

### AD Join fails

* Verify DNS A record
* Confirm AD credentials
* Ensure correct zone and domain

### Re-run safely

The playbook is **re-runnable** and will not break existing joins.

---

## ✅ Exit Codes

* `0` → Success
* `>0` → Ansible failure (see output)

---

## 📌 Best Practices

* Run from a secure control node
* Use a dedicated AD join service account
* Ensure time sync (NTP) on all servers
* Test on a non-production host first

---

## 📄 License

Adapt as needed for your organization.

---

## 👤 Author

**Sandeep Reddy Bandela**

Automation | Linux | Ansible | Infrastructure Engineering

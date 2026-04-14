# 🚀 Azure Mini Finance Deployment Pipeline (Terraform + Ansible)

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Azure](https://img.shields.io/badge/Microsoft_Azure-0089D6?style=for-the-badge&logo=microsoft-azure&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)

An end-to-end Infrastructure as Code (IaC) and Configuration Management pipeline. This project provisions a secure Azure Virtual Machine from scratch and automatically deploys a dynamic "Mini Finance" web application, injecting custom user data on the fly.

This project was built as part of the **DevOps Micro Internship (#DMI) Cohort 2.0** by [Pravin Mishra](https://www.linkedin.com/in/pravin-mishra-aws-trainer/).

---

## 🏗️ Architecture & Workflow

This project enforces a strict **separation of concerns**:
1. **Terraform (Infrastructure):** Builds the Virtual Network, Subnet, Network Security Group (Ports 22/80), and an Ubuntu VM (`Standard_B2ats_v2`).
2. **Ansible (Configuration):** Bootstraps the VM, installs Nginx & Git, clones the application repository, personalizes the HTML, and verifies the deployment with an automated HTTP 200 check.

---

## 📂 Project Structure
```text
mini-finance-azure-deployment/
├─ terraform/                  # Infrastructure layer
│  ├─ providers.tf             # Azure provider configuration
│  ├─ main.tf                  # VNet, Subnet, NSG, and VM definitions
│  └─ variables.tf             # Parameterized variables (Region, VM Size, SSH Key)
├─ ansible/                    # Configuration layer
│  ├─ inventory.ini            # Dynamic inventory and connection targets
│  └─ site.yml                 # Multi-play blueprint (Install -> Deploy -> Verify)
└─ README.md                   # Project documentation
```

## ⚠️ Prerequisites (Read Before Running)

To run this project seamlessly on your local machine, you must have the following installed:

* **Operating System:** Linux, macOS, or **Windows Subsystem for Linux (WSL)**. *(Note: Ansible does not run natively on Windows Command Prompt or PowerShell).*
* **[Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli):** Authenticated to your Azure account (`az login`).
* **[Terraform](https://developer.hashicorp.com/terraform/downloads):** Installed and added to your system PATH.
* **[Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html):** Installed via Python/Pip or your package manager.
* **SSH Key Pair:** You must have an SSH key to connect to the VM securely. 
  * If you don't have one, generate it by running: `ssh-keygen -t ed25519 -C "your_email@example.com"` (press Enter to accept default locations).

---

## 🚀 Step-by-Step Deployment Guide

### Step 1: Clone the Repository
Download this blueprint to your local machine:
```bash
git clone https://github.com/paharipratyush/mini-finance-azure-deployment.git
cd mini-finance-azure-deployment
```
### Step 2: Customize Your SSH Key Path (If needed)
By default, Terraform looks for your public SSH key at `~/.ssh/id_ed25519.pub`.
 - If your key is named differently (e.g., `id_rsa.pub`), open terraform/variables.tf.
 - Change the `default` value under `variable "ssh_public_key_path"` to match your system's exact path.
### Step 3: Provision the Infrastructure (Terraform)
Navigate to the Terraform directory, initialize the providers, and build the cloud resources:
```bash
cd terraform
terraform init
terraform apply -auto-approve
```
Important: When this finishes, Terraform will output a public_ip (e.g., 4.221.X.X). Copy this IP address.

Before moving on, accept the SSH fingerprint of your new server by running:
```bash
ssh azureuser@<YOUR_COPIED_PUBLIC_IP> "hostname"
```
(Type yes when prompted).
### Step 4: Update the Ansible Inventory
Navigate to the Ansible directory:
```bash
cd ../ansible
```
Open `inventory.ini` and replace the placeholder IP with the exact `public_ip` you copied from Terraform:
```bash
[web]
4.221.X.X  <-- REPLACE THIS
```
### Step 5: Personalize the Application (Optional)
This pipeline doesn't just deploy static code; it dynamically injects your details into the website dashboard!

Open `ansible/site.yml` and scroll down to the "Personalize the User Profile" tasks. 

Change the `replace:` values to your own Name, Email, and Phone Number:
```bash
- name: Personalize the User Profile Name
      ansible.builtin.replace:
        path: /var/www/html/index.html
        regexp: 'Curwen Arthurs'
        replace: 'YOUR NAME HERE' # Change this!
```
```bash
- name: Personalize the User Profile Email
      ansible.builtin.replace:
        path: /var/www/html/index.html
        regexp: 'curwen@site\.com'
        replace: 'pratyushpahari02@gmail.com' # Change this!
```
```bash
- name: Personalize the User Profile Phone
      ansible.builtin.replace:
        path: /var/www/html/index.html
        regexp: '\(60\) 12 345 6789'
        replace: '+91 9999999999' # Change this!
```

### Step 6: Deploy the Configuration (Ansible)
Run the master playbook to configure the server and deploy the app:
```bash
ansible-playbook -i inventory.ini site.yml
```
(You will see Ansible install Nginx, fix Linux directory permissions, inject your custom data, and run an automated verification test).
### Step 7: Verify in Browser
Open your favorite web browser and navigate to:
`http://<YOUR_COPIED_PUBLIC_IP>`

You should see the Mini Finance dashboard live on the internet, branded with your personal details 🎉

## Clean Up (Save Your Cloud Credits!)
To avoid being billed for resources when you are done testing, destroy the infrastructure.

Navigate back to the Terraform folder and run:
```bash
cd ../terraform
terraform destroy -auto-approve
```
## 📌 Author

Built with 💻 by [Pratyush Pahari](https://github.com/paharipratyush)

Feel free to ⭐ the repo if you found it useful!

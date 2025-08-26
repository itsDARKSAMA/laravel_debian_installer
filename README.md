# Laravel + Valet Auto Installer (Debian 12+)

**Author:** Eng. Abdelrahman M. Almajayda  
**GitHub:** [itsDaRKSAMA](https://github.com/itsDaRKSAMA)

---

## 📖 About
This script is a **professional Laravel development environment installer** for **Debian 12+**.  
It automates the setup of:
- PHP
- Composer
- Nginx
- MariaDB
- Dnsmasq
- Valet Linux
- Laravel project with `.env` configuration

Everything is installed, configured, and verified step by step with **colored progress bars, service checks, and logs**.

---

## ⚡ Features
✔️ Fully automated installation process  
✔️ Checks if MariaDB exists and lets you reconfigure or skip  
✔️ Detects Apache conflicts with Nginx  
✔️ Automatically enables and starts all required services  
✔️ Creates Laravel projects with database configuration in `.env`  
✔️ Colored terminal output for better UX  
✔️ Final summary table with service status (running/not running)  

---

## 🚀 Installation

### 1. Clone this repository
```bash
git clone https://github.com/itsDaRKSAMA/laravel_debian_installer.git
cd laravel_debian_installer
````

### 2. Make script executable

```bash
chmod +x install_debian_laravel.sh
```

### 3. Run the installer

```bash
sudo ./install_debian_laravel.sh
```

---

## 🛠 What the script does

1. **Update system packages**

   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Install required environment**

   * PHP (with extensions)
   * Composer
   * Nginx
   * MariaDB
   * Dnsmasq
   * Valet Linux

3. **Check & configure database**

   * Detect if MariaDB is already installed
   * Ask user: reinitialize database or continue using existing

4. **Check for conflicts**

   * Detect Apache and disable if present (to prevent conflict with Nginx)

5. **Enable and start services**

   * php-fpm
   * mariadb
   * nginx
   * dnsmasq
   * valet

6. **Create new Laravel project**

   * Place inside `~/Sites`
   * Setup `.env` with database credentials
   * Print credentials for future use

7. **Print final summary**

   * Which services were installed
   * Running status ✅ / ❌
   * Any warnings or errors

---

## 📂 Laravel Project Workflow

1. Create `~/Sites` directory (once):

   ```bash
   mkdir -p ~/Sites
   cd ~/Sites
   ```

2. Park this directory with Valet:

   ```bash
   valet park
   ```

   > Now every Laravel project inside `~/Sites` will be accessible at:

   ```
   http://project-name.test
   ```

3. Create new Laravel project:

   ```bash
   cd ~/Sites
   composer create-project laravel/laravel blog
   ```

4. Link & secure project:

   ```bash
   cd ~/Sites/blog
   valet link
   valet secure   # optional for HTTPS
   ```

---

## ⚙️ Database Configuration

During installation, you will be asked for:

* Database **name**
* Database **user**
* Database **password**

These will be automatically inserted into your Laravel project’s `.env` file:

```env
DB_CONNECTION=mariadb
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=your_db
DB_USERNAME=your_user
DB_PASSWORD=your_pass
```

---

## ✅ Final Step

After installation, visit your project in the browser:

```
http://blog.test
```

If you enabled HTTPS:

```
https://blog.test
```

---

## 📜 License

Designed & Developed by **Eng. Abdelrahman M. Almajayda**
👉 [GitHub.com/itsDaRKSAMA](https://github.com/itsDaRKSAMA)


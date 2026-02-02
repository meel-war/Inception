Developer Documentation

Table of Contents

1. [Project Architecture]
2. [Prerequisites]
3. [Environment Setup from Scratch]
4. [Project Structure]
5. [Docker Services]
6. [Docker Compose Configuration]
7. [Build Process]
8. [Container Management]
9. [Volume Management]
10. [Networking]
11. [Development Workflow]
12. [Debugging Guide]

---

Project Architecture

Overview

This project implements a WordPress infrastructure using Docker containers. The architecture follows a microservices pattern with three isolated services communicating through a private Docker network.

Service Responsibilities

| Service | Image Base | Purpose | Exposed Ports | Dependencies |
|---------|-----------|---------|---------------|--------------|
| **nginx** | debian:bullseye | HTTPS termination, reverse proxy | 443 (external) | wordpress (healthy) |
| **wordpress** | debian:bullseye | PHP-FPM, WordPress core | 9000 (internal) | mariadb (healthy) |
| **mariadb** | debian:bullseye | MySQL database | 3306 (internal) | None |

Communication Flow

1. **Browser** → `https://meel-war.42.fr`
2. **nginx** receives HTTPS request (TLS termination)
3. **nginx** proxies PHP requests → `wordpress:9000` (FastCGI)
4. **wordpress** (PHP-FPM) processes request
5. **wordpress** queries database → `mariadb:3306`
6. **mariadb** returns data
7. Response flows back: `mariadb` → `wordpress` → `nginx` → `browser`

---

Prerequisites

System Requirements

- **OS**: Linux (Debian/Ubuntu recommended) or macOS
- **RAM**: Minimum 2GB available
- **Disk**: 5GB free space
- **Processor**: x86_64 architecture

Required Software

| Software | Minimum Version | Installation |
|----------|----------------|--------------|
| Docker | 20.10+ | `apt install docker.io` or Docker Desktop |
| Docker Compose | 2.0+ | Included in Docker Desktop |
| Make | GNU Make 4.0+ | `apt install make` |
| Git | 2.0+ | `apt install git` |

Verify Installation

```bash
docker --version          # Should show 20.10+
docker compose version    # Should show 2.0+
make --version           # Should show GNU Make 4.0+
```

---

Environment Setup from Scratch

1. Clone the Repository

```bash
git clone <repository_url>
cd Inception-main
```

2. Configure Environment Variables

Edit the `.env` file in the `src/` directory:

```bash
nano src/.env
```

Required variables in `src/.env`:

```bash
# Database Configuration
SQL_ROOT_PASSWORD=your_root_password    # MariaDB root password
SQL_DATABASE=wordpress                  # Database name
SQL_USER=your_db_username               # WordPress DB user
SQL_PASSWORD=your_db_password           # WordPress DB password

# WordPress Configuration
WP_URL=your_login.42.fr                 # Your domain
WP_TITLE=Inception WordPress            # Site title
WP_ADMIN_USER=your_admin_username       # Admin username (NOT "admin")
WP_ADMIN_PASSWORD=your_admin_password   # Admin password
WP_ADMIN_EMAIL=your_email@example.com   # Admin email
WP_USER=your_user                       # Additional user
WP_USER_EMAIL=user@example.com          # User email
WP_USER_PASSWORD=your_user_password     # User password
```

3. Configure /etc/hosts

Add the following line to your `/etc/hosts` file:

```bash
sudo nano /etc/hosts
```

Add:
```
127.0.0.1   your_login.42.fr
```

---

Project Structure

```
Inception-main/
├── Makefile                           # Build automation
├── README.md                          # Project overview
├── USER_DOC.md                        # End-user documentation
├── DEV_DOC.md                         # This file
│
└── src/
    ├── .env                           # Environment variables (NOT committed)
    ├── docker-compose.yml             # Service orchestration
    │
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile             # MariaDB image definition
        │   └── db_setup.sh            # Database initialization script
        │
        ├── nginx/
        │   ├── Dockerfile             # Nginx image definition
        │   └── default.conf           # Nginx server configuration
        │
        └── wordpress/
            ├── Dockerfile             # WordPress image definition
            └── wp_setup.sh            # WordPress installation script
```

File Purposes

| File | Purpose |
|------|---------|
| `Makefile` | Build automation, defines targets (all, build, up, down, fclean, re) |
| `docker-compose.yml` | Defines services, networks, volumes orchestration |
| `Dockerfile` | Image build instructions for each service |
| `*.sh` | Initialization and entrypoint scripts |
| `*.conf` | Service-specific configuration files |
| `.env` | Environment variables (excluded from git) |

---

Docker Services

MariaDB Service

**Dockerfile**: `src/requirements/mariadb/Dockerfile`

**Key Points**:
- Base: `debian:bullseye` (stable Debian)
- Package: `mariadb-server` (installed via apt)
- Config: Bind address changed from 127.0.0.1 to 0.0.0.0 (accept all connections)
- Init: `db_setup.sh` creates database, users, sets passwords
- Port: 3306 exposed only within Docker network
- Socket: `/run/mysqld` directory created and owned by mysql user

**Initialization Flow** (`db_setup.sh`):
1. Check if MariaDB is already initialized (`/var/lib/mysql/mysql`)
2. If not, run `mysql_install_db` to create system tables
3. Create `/run/mysqld` directory for socket file
4. Generate SQL initialization script:
   - Create database (`$SQL_DATABASE`)
   - Create user (`$SQL_USER`) with password
   - Grant privileges to user on database
   - Set root password
5. Start MariaDB with `mysqld_safe` using init file
6. Execute as PID 1 for proper signal handling

**Important Configuration**:
```bash
# Allow connections from any IP (not just localhost)
sed -i 's/bind-address = 127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
```

---

WordPress Service

**Dockerfile**: `src/requirements/wordpress/Dockerfile`

**Key Points**:
- Base: `debian:bullseye`
- PHP: Version 7.4 with FPM (FastCGI Process Manager)
- Packages: `php7.4-fpm`, `php7.4-mysql`, `curl`, `mariadb-client`
- WP-CLI: Official WordPress command-line tool (downloaded in script)
- Config: PHP-FPM listens on port 9000 (not socket)
- Init: `wp_setup.sh` downloads WordPress, creates config, installs

**PHP-FPM Configuration**:
```bash
# Change from socket to TCP port for inter-container communication
sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 9000|' /etc/php/7.4/fpm/pool.d/www.conf
```

**Initialization Flow** (`wp_setup.sh`):
1. Wait for MariaDB to be ready (health check loop using `mariadb-admin ping`)
2. Check if WordPress is already installed (`wp-config.php` exists)
3. If not installed:
   - Download WP-CLI tool
   - Download WordPress core files
   - Create `wp-config.php` with database credentials
   - Set WordPress home and site URL (hardcoded to `https://meel-war.42.fr`)
   - Install WordPress (creates admin user)
   - Create additional user with author role
4. Start PHP-FPM as PID 1 (`exec php-fpm7.4 -F`)

**Important Note**: The WordPress URL is hardcoded in the script:
```bash
wp config set WP_HOME 'https://your_login.42.fr' --allow-root
wp config set WP_SITEURL 'https://your_login.42.fr' --allow-root
```

You should modify this in the `wp_setup.sh` file to match your domain.

---

Nginx Service

**Dockerfile**: `src/requirements/nginx/Dockerfile`

**Key Points**:
- Base: `debian:bullseye`
- Nginx: Web server with TLS 1.2/1.3 support
- SSL: Self-signed certificate generated at build time
- Config: FastCGI proxy to `wordpress:9000`
- Port: Only 443 exposed (HTTPS only)

**SSL Certificate Generation**:
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=State/L=City/O=42/OU=42/CN=your_login.42.fr/UID=your_login"
```

**Nginx Configuration** (`default.conf`):
```nginx
server {
    listen 443 ssl;
    server_name your_login.42.fr;

    ssl_certificate /etc/nginx/ssl/inception.crt;
    ssl_certificate_key /etc/nginx/ssl/inception.key;
    ssl_protocols TLSv1.2 TLSv1.3;  # Only secure protocols

    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    # Proxy PHP to WordPress container
    location ~ \.php$ {
        fastcgi_pass wordpress:9000;  # Docker network resolution
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param HTTPS on;
    }
}
```

---

Docker Compose Configuration

**File**: `src/docker-compose.yml`

Service Dependencies

```yaml
services:
  mariadb:
    # No dependencies - starts first
    healthcheck:
      test: ["CMD", "mariadb-admin", "ping", "-h", "localhost", "--silent"]
      interval: 5s
      retries: 5

  wordpress:
    depends_on:
      mariadb:
        condition: service_healthy  # Waits for mariadb healthcheck
    healthcheck:
      test: ["CMD", "test", "-f", "/var/www/html/index.php"]
      interval: 5s
      retries: 10

  nginx:
    depends_on:
      wordpress:
        condition: service_healthy  # Waits for wordpress healthcheck
```

**How it works**:
- MariaDB starts first and waits for health check to pass
- WordPress waits for MariaDB health check before starting
- Nginx waits for WordPress health check before starting
- This ensures services start in correct order

Restart Policy

All services use `restart: always`:
- Containers restart automatically after crashes
- Containers start on system boot (if Docker daemon is running)
- Useful for production-like reliability

Volume Configuration

```yaml
volumes:
  wp_data:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '/home/meel-war/data/wordpress'
  db_data:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '/home/meel-war/data/mariadb'
```

This creates a "named volume" that's actually a bind mount to a specific host path. It's a hybrid approach:
- Named volume syntax (portable in docker-compose.yml)
- Bind mount behavior (data at predictable host location)
- Required by subject: data must be in `~/data/` (or `/home/username/data/`)

**Note**: The paths are hardcoded in the docker-compose.yml file. You should update them to match your username.

---

Build Process

Build Command

```bash
make build
# Creates data directories and executes: docker compose -f src/docker-compose.yml build
```

Build Phases

1. **Create Data Directories**
   - `~/data/wordpress`
   - `~/data/mariadb`

2. **Read docker-compose.yml**
   - Parse service definitions
   - Identify Dockerfiles to build

3. **Build each service** (in parallel by default)

4. **Execute Dockerfile instructions**:
   - `FROM`: Pull base image (`debian:bullseye`)
   - `RUN`: Execute commands (apt install, sed, openssl, etc.)
   - `COPY`: Copy files from build context
   - `EXPOSE`: Document ports (metadata only)
   - `ENTRYPOINT`/`CMD`: Set default command

5. **Tag images**:
   ```
   inception-mariadb
   inception-wordpress
   inception-nginx
   ```

---

Container Management

Start Containers

```bash
make up
# Executes: docker compose -f src/docker-compose.yml up -d
```

**What happens**:
1. Create `inception` network (if not exists)
2. Mount volumes (bind mounts to `~/data/`)
3. Start containers in dependency order
4. Detach (`-d` flag)

View Running Containers

```bash
docker ps
# Shows: container ID, image, status, ports, names
```

Expected output:
```
CONTAINER ID   IMAGE                  STATUS                    PORTS
abc123         inception-nginx        Up 2 minutes (healthy)    0.0.0.0:443->443/tcp
def456         inception-wordpress    Up 3 minutes (healthy)    9000/tcp
ghi789         inception-mariadb      Up 4 minutes (healthy)    3306/tcp
```

Stop Containers

```bash
make down
# Executes: docker compose -f src/docker-compose.yml down
```

Stops and removes containers, but keeps:
- Volumes (data preserved)
- Images (no rebuild needed)
- Network (recreated on next up)

Execute Commands in Containers

```bash
# Open bash shell
docker exec -it mariadb bash

# Run single command
docker exec mariadb ls /var/lib/mysql

# Connect to database
docker exec -it mariadb mariadb -u$SQL_USER -p$SQL_PASSWORD $SQL_DATABASE

# Check WordPress installation
docker exec wordpress ls -la /var/www/html
```

---

Volume Management

Volume Locations

```bash
# On host machine
~/data/mariadb/       # MariaDB database files
~/data/wordpress/     # WordPress installation

# Inside containers
/var/lib/mysql        # mariadb container
/var/www/html         # wordpress & nginx containers
```

Inspect Volumes

```bash
# List all volumes
docker volume ls

# Inspect volume details
docker volume inspect inception_wp_data
docker volume inspect inception_db_data

# View volume contents (from host)
ls -la ~/data/mariadb/
ls -la ~/data/wordpress/
```

Volume Persistence

Data survives:
- ✅ Container stop (`make down`)
- ✅ Container removal
- ✅ Image rebuild
- ❌ `make fclean` (explicitly deletes volumes and `~/data/`)

---

Networking

Network Configuration

```bash
# Inspect network
docker network inspect inception

# Output shows:
# - Subnet: 172.x.0.0/16
# - Gateway: 172.x.0.1
# - Connected containers with IPs
```
Port Mapping

Only nginx exposes port to host:

```yaml
nginx:
  ports:
    - "443:443"  # Host:Container
```

Other services use internal ports only:
- `mariadb:3306` - accessible only within `inception` network
- `wordpress:9000` - accessible only within `inception` network

Network Isolation

```bash
# This WORKS (inside network)
docker exec nginx curl wordpress:9000

# This FAILS (from host, port not exposed)
curl localhost:9000
```

---

Quick Commands

```bash
make re                                           # Full rebuild
docker compose -f src/docker-compose.yml logs -f  # Watch all logs
docker exec -it <container> bash                  # Shell access
```

---

Debugging Guide

Essential Debug Commands

```bash
# Check container status
docker ps -a

# View logs
docker logs <container>

# Access container shell
docker exec -it <container> bash


# Check database connectivity
docker exec mariadb mariadb -u$SQL_USER -p$SQL_PASSWORD

# Inspect network
docker network inspect inception
```

Common Issues

| Problem | Solution |
|---------|----------|
| Container won't start | Check logs: `docker logs <container>` |
| Service unhealthy | Run healthcheck manually: `docker exec mariadb mariadb-admin ping -h localhost` |
| Network issues | Verify: `docker exec nginx ping mariadb` |
| Volume issues | Check: `ls -la ~/data/` and `docker inspect <container>` |
| Permission denied | May need sudo for Docker commands |

---

Security

✅ **DO**: 
- Use strong passwords
- Keep `.env` out of git (add to `.gitignore`)
- Use TLS 1.2/1.3 only
- Limit container privileges

❌ **DON'T**: 
- Use default passwords
- Expose unnecessary ports

---

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [WordPress Codex](https://codex.wordpress.org/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [MariaDB Documentation](https://mariadb.org/documentation/)
- [WP-CLI Documentation](https://wp-cli.org/)

---

**Last Updated**: 2026-01-30  
**Project**: Inception

_This project has been created as part of the 42 curriculum by meel-war._

---

Inception

A containerized WordPress infrastructure built with Docker, demonstrating modern DevOps practices through the deployment of a complete web application stack.

---

Table of Contents

- [Overview]
- [Technical Stack]
- [Quick Start Guide]
- [System Requirements]
- [Project Architecture]
- [Key Concepts]
- [Useful Resources]
- [Author]

---

Overview

Inception is a system administration exercise focused on containerization and infrastructure orchestration. The project deploys a fully functional WordPress website using Docker containers, with each component isolated in its own service. This approach demonstrates microservices architecture, container networking, and modern deployment strategies.

**What makes this project interesting:**
- Each service runs in isolation with custom-built Docker images
- Secure HTTPS communication using TLS 1.2/1.3
- Automated setup and deployment through Makefiles
- Persistent data storage that survives container restarts
- Health monitoring and dependency management between services

---

Technical Stack

The infrastructure consists of three main components:

🔷 NGINX (Web Server & Reverse Proxy)
- Handles incoming HTTPS requests on port 443
- Terminates SSL/TLS connections with self-signed certificates
- Proxies PHP requests to the WordPress container via FastCGI
- Serves static content directly

🔷 WordPress (Application Layer)
- Content Management System running on PHP-FPM 7.4
- Communicates with MariaDB for data persistence
- Installed and configured automatically via WP-CLI
- Supports multiple user roles (admin and author)

🔷 MariaDB (Database Layer)
- MySQL-compatible database server
- Stores all WordPress content and configuration
- Isolated from external network access
- Initialized with custom database and user on first run

---

Quick Start Guide

Initial Setup

```bash
# Clone the repository
git clone <repository>
cd Inception

# Configure your environment
nano src/.env

```

Configuration

Edit `src/.env` with your credentials:
```bash
SQL_ROOT_PASSWORD=your_secure_password
SQL_DATABASE=wordpress
SQL_USER=your_db_username
SQL_PASSWORD=your_db_password

WP_URL=your_login.42.fr
WP_TITLE=Your Site Title
WP_ADMIN_USER=your_admin_username
WP_ADMIN_PASSWORD=your_admin_password
WP_ADMIN_EMAIL=your_email@example.com
WP_USER=your_user
WP_USER_EMAIL=user@example.com
WP_USER_PASSWORD=your_user_password
```

Launch

```bash
make        # Build images and start services
```

Access Your Site

Open your browser to: **https://your_login.42.fr**

Accept the self-signed certificate warning (click "Advanced" → "Proceed").

---

System Requirements

| Component | Requirement |
|-----------|-------------|
| Operating System | Linux (Debian/Ubuntu) or macOS |
| Docker | Version 20.10 or higher |
| Docker Compose | Version 2.0 or higher |
| Make | GNU Make 4.0+ |
| RAM | Minimum 2GB available |
| Disk Space | 5GB free |

**Verify your installation:**
```bash
docker --version && docker compose version && make --version
```

---

Project Architecture

Container Communication Flow

```
┌─────────────────────────────────────────────────┐
│                   Browser                       │
│              https://your_login.42.fr           │
└─────────────────────┬───────────────────────────┘
                      │ HTTPS (port 443)
                      ↓
┌─────────────────────────────────────────────────┐
│         NGINX Container (Web Server)            │
│   - SSL/TLS Termination                         │
│   - Static file serving                         │
│   - FastCGI proxy to WordPress                  │
└─────────────────────┬───────────────────────────┘
                      │ FastCGI (port 9000)
                      ↓
┌─────────────────────────────────────────────────┐
│      WordPress Container (PHP-FPM 7.4)          │
│   - WordPress Core                              │
│   - PHP processing                              │
│   - Database queries                            │
└─────────────────────┬───────────────────────────┘
                      │ MySQL Protocol (port 3306)
                      ↓
┌─────────────────────────────────────────────────┐
│        MariaDB Container (Database)             │
│   - Data persistence                            │
│   - User management                             │
│   - Query processing                            │
└─────────────────────┬───────────────────────────┘
                      │
                      ↓
              Volume Storage (~/data/)
```

Network Design

All containers communicate through a **bridge network** named `inception`:
- Provides DNS-based service discovery (containers can ping each other by name)
- Isolates services from the host network
- Only NGINX exposes port 443 to the outside world
- Internal services (MariaDB, WordPress) remain protected

Data Persistence

Data is stored in bivolumes:
```
~/data/wordpress/  → WordPress files, themes, plugins, uploads
~/data/mariadb/    → Database tables and configuration
```

These volumes ensure your data persists even when containers are stopped or removed.

---

Key Concepts

Why Docker Over Virtual Machines?

| Feature | Docker Containers | Virtual Machines |
|---------|------------------|------------------|
| **Startup Time** | Seconds | Minutes |
| **Resource Usage** | Shares host kernel | Full OS overhead |
| **Size** | Megabytes | Gigabytes |
| **Isolation Level** | Process-level | Hardware-level |
| **Performance** | Near-native | Virtualization overhead |
| **Portability** | Highly portable | Platform-dependent |

Docker provides the isolation benefits of VMs with significantly less overhead, making it ideal for microservices architectures.

Container Orchestration with Docker Compose

Docker Compose manages multi-container applications through a single configuration file. Benefits include:
- **Dependency management**: WordPress waits for MariaDB to be healthy before starting
- **Network automation**: Creates and configures networks automatically
- **Volume management**: Handles data persistence without manual intervention
- **One-command deployment**: `make` builds and starts everything

Health Checks and Dependencies

Each service includes health checks:
```yaml
mariadb:
  healthcheck:
    test: ["CMD", "mariadb-admin", "ping", "-h", "localhost", "--silent"]

wordpress:
  depends_on:
    mariadb:
      condition: service_healthy
```

This ensures services start in the correct order and only become available when truly ready.

Environment Variables vs Secrets

**This project uses environment variables** (`.env` file) for configuration:
- ✅ Simple to configure and understand
- ✅ Works well for development environments
- ⚠️ Visible in container inspection
- ⚠️ Should not be committed to version control

**Alternative: Docker Secrets** (not used here):
- Stored in tmpfs (memory only, never written to disk)
- Not visible in `docker inspect`
- Better for production environments
- Requires Docker Swarm or manual secret management

Named Volumes with Bind Mounts

The project uses a hybrid approach:
```yaml
volumes:
  wp_data:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '/home/your_username/data/wordpress'
```

This gives us:
- Named volume syntax (portable configuration)
- Bind mount behavior (predictable host location)
- Compatibility with project requirements (`~/data/` location)

---

Useful Resources

Official Documentation
- **Docker**: https://docs.docker.com/
- **Docker Compose**: https://docs.docker.com/compose/
- **WordPress**: https://wordpress.org/documentation/
- **NGINX**: https://nginx.org/en/docs/
- **MariaDB**: https://mariadb.com/kb/

Learning Materials
- Docker concepts: containers, images, volumes, networks
- FastCGI protocol and PHP-FPM architecture
- SSL/TLS certificates and HTTPS encryption
- Database administration and user management
- WP-CLI for WordPress automation

Project Documentation
For detailed technical information and troubleshooting:
- **[DEV_DOC.md](DEV_DOC.md)** - Developer guide with architecture details, debugging, and workflows
- **[USER_DOC.md](USER_DOC.md)** - End-user manual for launching, accessing, and managing the site

---

Commands Reference

| Command | Action |
|---------|--------|
| `make` | Build images and start all services |
| `make build` | Create data directories and build Docker images |
| `make up` | Start containers in detached mode |
| `make down` | Stop containers (preserves data) |
| `make fclean` | Complete cleanup (⚠️ deletes all data) |
| `make re` | Full rebuild (fclean + make) |

**View container status:**
```bash
docker ps                           # Running containers
docker logs nginx                   # View specific container logs
docker exec -it mariadb bash        # Access container shell
```

---

## Author

**Project:** Inception  
**Developer:** meel-war  
**Year:** 2026

---

## License

This project is part of the 42 school curriculum and is subject to academic policies.

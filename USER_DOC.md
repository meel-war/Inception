User Documentation

Available Services

- WordPress (PHP-FPM)
- Nginx (Web server with HTTPS)
- MariaDB (Database)

---

Getting Started

Prerequisites

Before starting, you must configure the environment variables:

1. Edit `src/.env` file with your credentials and settings
2. Ensure `/etc/hosts` contains: `127.0.0.1   your_login.42.fr`

Launch the Project

Once the `.env` file is configured, run:

```bash
make
```

Wait until all services are **"Healthy"**. This takes approximately 30-60 seconds.

Access the Website

Open your browser and navigate to:

```
https://your_login.42.fr
```

You will see a security warning because the SSL certificate is self-signed. Click "Advanced" → "Proceed to site". This is normal for local development.

Well done! You are now on the WordPress website.

---

Connecting as User or Administrator

Access Admin Panel

In your browser, navigate to:

```
https://your_login.42.fr/wp-admin
```

**Login credentials:**
- **Username**: Value from `WP_ADMIN_USER` in your `src/.env` file
- **Password**: Value from `WP_ADMIN_PASSWORD` in your `src/.env` file

Access as Regular User

You can also login with the second user:
- **Username**: Value from `WP_USER` in your `src/.env` file
- **Password**: Value from `WP_USER_PASSWORD` in your `src/.env` file

This user has "Author" role (can create and edit posts but cannot manage the site).

---

Managing Credentials

All passwords are stored in the `src/.env` file:

| Credential | Variable Name | Description |
|------------|--------------|-------------|
| MySQL root password | `SQL_ROOT_PASSWORD` | Database root user |
| MySQL user password | `SQL_PASSWORD` | WordPress database connection |
| WordPress admin password | `WP_ADMIN_PASSWORD` | Admin panel login |
| WordPress user password | `WP_USER_PASSWORD` | Regular user login |

**To change a password:**
1. Edit the corresponding variable in `src/.env`
2. Restart the project: `make re`

**Security**: Never commit the `.env` file to git! It should be in your `.gitignore`.

---

Checking Service Status

Verify containers are running

```bash
docker ps
```

You should see 3 containers with status "Up (healthy)":
- `nginx`
- `wordpress`
- `mariadb`

View logs

```bash
# All services (live stream)
docker compose -f src/docker-compose.yml logs -f

# Specific service
docker logs nginx
docker logs wordpress
docker logs mariadb
```

Test website connectivity

```bash
curl -k https://your_login.42.fr
```

Should return HTML content if everything is working correctly.

---

Stopping the Project

Complete cleanup (removes all data)

```bash
make fclean
```

**Warning**: This command:
- Stops and removes all containers
- Deletes all volumes and images
- Removes all data from `~/data/`
- This action is **irreversible**!

Stop containers but keep data

```bash
make down
```

This stops containers but preserves your data in `~/data/`.

---

Restarting the Project

Full rebuild (clean + restart)

```bash
make re
```

This runs `make fclean` followed by `make` (complete cleanup and restart).

Restart without rebuilding

```bash
make down
make up
```

This restarts existing containers without rebuilding images.

---

Troubleshooting

Service not starting

Check logs for error messages:

```bash
docker logs <service_name>
```

Common issues:
- Port 443 already in use (another service using HTTPS)
- Missing or incorrect `.env` file
- Incorrect permissions on data directories

Cannot access website

1. **Verify `/etc/hosts` configuration:**

```bash
cat /etc/hosts | grep your_login.42.fr
```

Should display: `127.0.0.1   your_login.42.fr`

If not present, add it:
```bash
sudo nano /etc/hosts
# Add: 127.0.0.1   your_login.42.fr
```

2. **Check if containers are running:**

```bash
docker ps
```

All 3 containers should be listed with "Up" status.

3. **Verify nginx is responding:**

```bash
curl -k https://localhost:443
```

Database connection errors

1. **Verify MariaDB is healthy:**

```bash
docker ps | grep mariadb
```

Should show "healthy" status.

2. **Check MariaDB logs:**

```bash
docker logs mariadb
```

Look for error messages about initialization or connection issues.

3. **Verify credentials:**

Check that `src/.env` contains correct database credentials:
- `SQL_DATABASE` (database name)
- `SQL_USER` (database user)
- `SQL_PASSWORD` (database password)

4. **Test database connection:**

```bash
docker exec -it mariadb mariadb -u<SQL_USER> -p<SQL_PASSWORD> <SQL_DATABASE>
```

Replace `<SQL_USER>`, `<SQL_PASSWORD>`, and `<SQL_DATABASE>` with values from your `.env`.

WordPress not accessible

1. **Check WordPress container:**

```bash
docker logs wordpress
```

Look for WordPress installation logs. Should see "MariaDB is up" and WP-CLI installation messages.

2. **Verify WordPress files exist:**

```bash
docker exec wordpress ls -la /var/www/html
```

Should see WordPress core files including `index.php`, `wp-config.php`.

3. **Check if WordPress is listening:**

```bash
docker exec wordpress netstat -tuln | grep 9000
```

Should show PHP-FPM listening on port 9000.

HTTPS certificate warnings

**This is normal!** The certificate is self-signed and not from a trusted authority.

To proceed:
- **Chrome/Edge**: Click "Advanced" → "Proceed to your_login.42.fr (unsafe)"
- **Firefox**: Click "Advanced" → "Accept the Risk and Continue"
- **Safari**: Click "Show Details" → "visit this website"

For production use, you would need a real SSL certificate from Let's Encrypt or a certificate authority.

---

Data Persistence

All website data is stored in:

```
~/data/mariadb/      # Database files
~/data/wordpress/    # WordPress files (themes, plugins, uploads)
```

Even after stopping or removing containers, your data remains in these directories unless you run `make fclean`.

---

Configuration Reference

Environment Variables

Complete list of variables in `src/.env`:

```bash
# Database Configuration
SQL_ROOT_PASSWORD=your_root_password   # Root password for MariaDB
SQL_DATABASE=wordpress                 # Database name for WordPress
SQL_USER=your_db_username              # Database user for WordPress
SQL_PASSWORD=your_db_password          # Database user password

# WordPress Site Configuration
WP_URL=your_login.42.fr               # Your domain name
WP_TITLE=Your Site Title              # Website title
WP_ADMIN_USER=your_admin_username     # Administrator username
WP_ADMIN_PASSWORD=your_admin_password # Administrator password
WP_ADMIN_EMAIL=your_email@example.com # Administrator email

# WordPress Additional User
WP_USER=your_user                     # Second user username
WP_USER_EMAIL=user@example.com        # Second user email
WP_USER_PASSWORD=your_user_password   # Second user password
```

**Important Notes:**
- Use strong passwords for production environments
- The `WP_URL` should match your `/etc/hosts` entry
- The admin username should NOT be "admin" (security best practice)

---

Support

For additional help:
- Review container logs: `docker logs <container_name>`
- Check configuration: `cat src/.env`
- Verify Docker status: `docker ps -a`
- Inspect volumes: `ls -la ~/data/`
- Inspect network: `docker network inspect inception`

If containers fail to start, common solutions:
1. Rebuild everything: `make re`
2. Check Docker daemon is running: `sudo systemctl status docker`
3. Free up disk space: `docker system prune`
4. Check for port conflicts: `sudo lsof -i :443`

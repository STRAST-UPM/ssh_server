# SSH Server Docker Setup

This setup provides a Docker container running an SSH server based on Ubuntu 22.04.

## Quick Start

### Build and Run with Docker Compose

```bash
# Build and start the container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down
```

### Connect to the SSH Server

```bash
# Connect via SSH (password: sshpassword)
ssh -p 2222 sshuser@localhost
```

## Configuration

### Default Credentials

- **Username**: `sshuser`
- **Password**: `sshpassword`
- **Port**: 2222 (host) → 22 (container)

> ⚠️ **Security Warning**: Change the default password in production environments!

### Change Password

#### Option 1: Modify Dockerfile

Edit the `Dockerfile` and change the password in the RUN command:

```dockerfile
RUN echo 'sshuser:YOUR_NEW_PASSWORD' | chpasswd
```

Then rebuild:

```bash
docker-compose up -d --build
```

#### Option 2: Change password in running container

```bash
docker exec -it ssh-server passwd sshuser
```

### SSH Key Authentication (Recommended)

1. Create an `authorized_keys` file with your public key:

```bash
# Copy your public key to authorized_keys
cat ~/.ssh/id_rsa.pub > authorized_keys
```

2. Uncomment the volume mount in `docker-compose.yml`:

```yaml
volumes:
  - ./authorized_keys:/home/sshuser/.ssh/authorized_keys:ro
```

3. Restart the container:

```bash
docker-compose down
docker-compose up -d
```

4. Connect without password:

```bash
ssh -p 2222 sshuser@localhost
```

### Change Port

To use a different host port, edit `docker-compose.yml`:

```yaml
ports:
  - "YOUR_PORT:22"  # Change YOUR_PORT to desired port
```

## Volumes

- `ssh-user-data`: Persists the user's home directory data across container restarts

## Security Best Practices

1. **Change default password** immediately
2. **Use SSH key authentication** instead of passwords
3. **Disable password authentication** in `/etc/ssh/sshd_config` after setting up keys
4. **Use a firewall** to restrict access to the SSH port
5. **Keep the image updated** regularly

## Troubleshooting

### Check if the container is running

```bash
docker-compose ps
```

### View container logs

```bash
docker-compose logs ssh-server
```

### Access container shell

```bash
docker exec -it ssh-server /bin/bash
```

### Test SSH connection

```bash
# Test connection
ssh -p 2222 -v sshuser@localhost

# Test with specific key
ssh -p 2222 -i ~/.ssh/id_rsa sshuser@localhost
```

## Advanced Configuration

### Add more users

Edit the `Dockerfile` and add additional users:

```dockerfile
RUN useradd -rm -d /home/newuser -s /bin/bash -g root -G sudo -u 1002 newuser && \
    echo 'newuser:newpassword' | chpasswd
```

### Install additional software

Add installation commands in the `Dockerfile`:

```dockerfile
RUN apt-get update && \
    apt-get install -y git vim curl && \
    apt-get clean
```

### Customize SSH configuration

Modify the SSH configuration in the `Dockerfile`:

```dockerfile
RUN echo "MaxAuthTries 3" >> /etc/ssh/sshd_config && \
    echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config && \
    echo "ClientAliveCountMax 2" >> /etc/ssh/sshd_config
```

## Cleanup

```bash
# Stop and remove container, networks, and volumes
docker-compose down -v

# Remove the image
docker rmi sysdocs-ssh-server
```

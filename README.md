# Jellyfin 
A x86 Jellyfin Docker image with [Noto CJK font](https://notofonts.github.io/) and [Intel graphics driver](https://github.com/intel/compute-runtime)

# Usage
## Pull image
`docker pull ghcr.io/kennyfong19931/jellyfin:latest`

## Run the container
### Docker command line
```
docker run -d --volume /path/to/config:/config --volume /path/to/cache:/cache --volume /path/to/media:/media --user 1000:100 -p 8096:8096 -p 7359:7359/udp --restart=unless-stopped ghcr.io/kennyfong19931/jellyfin
```

### Docker Compose
```yaml
services:
  jellyfin:
    image: ghcr.io/kennyfong19931/jellyfin:latest
    container_name: jellyfin
    user: 1000:100
    volumes:
      - /path/to/config:/config
      - /path/to/cache:/cache
      - /path/to/media:/media
    ports:
      - 8096:8096
      - 8920:8920 # Optional - Https webUI, require own certificate
      - 7359:7359/udp # Optional - Allows clients to discover Jellyfin on the local network
      - 1900:1900/udp # Optional - Service discovery used by DNLA and clients
    environment:
      - JELLYFIN_PublishedServerUrl=http://example.com # Optional - autodiscovery response domain or IP address
    restart: unless-stopped
```
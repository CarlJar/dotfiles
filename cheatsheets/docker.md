# docker / compose cheatsheet

On carl-pi: data-root `/srv/data/docker` (on the RAID), services live in `/srv/data/appdata/<name>/`
with a `compose.yaml` and their config/data folders next to it. `carl` is in group `docker` → no `sudo` needed.

Two command families:
- `docker compose …` → works on **the stack in the current folder** (reads `compose.yaml`)
- `docker …` → works on single containers / images / volumes, system-wide

## 1. Daily — a compose stack (run inside its folder)

| Command | Does |
|---|---|
| `docker compose up -d` | create + start everything in the background (`-d` = detached). Re-run after editing `compose.yaml` → only changed containers are recreated |
| `docker compose ps` | status of this stack's containers |
| `docker compose logs -f --tail=100` | follow the last 100 log lines (`Ctrl-c` stops following, not the container) |
| `docker compose logs -f <service>` | logs of one service only |
| `docker compose restart` | restart containers (does **not** re-read `compose.yaml`; use `up -d` for that) |
| `docker compose stop` / `start` | stop / start, containers are kept |
| `docker compose down` | stop **and remove** containers + network. Your bind-mounted data in `appdata/` stays |
| `docker compose down -v` | ⚠ also deletes **named volumes** of the stack |
| `docker compose config` | print the final config — checks YAML syntax and variable substitution |
| `docker compose -f /path/compose.yaml ps` | work on a stack from anywhere |

## 2. Updating a service

```bash
cd /srv/data/appdata/homepage
docker compose pull          # download newer images (for the tags in compose.yaml)
docker compose up -d         # recreate only containers whose image changed
docker image prune           # remove the old, now unused images
```

Tag `latest` = always newest (convenient, can break). A pinned tag like `v1.2.3` = only updates when you change it.

## 3. Inside a container

| Command | Does |
|---|---|
| `docker compose exec <service> sh` | shell inside a running container (`bash` if the image has it) |
| `docker exec -it <container> sh` | same, by container name (`-i` keep input open, `-t` give a terminal) |
| `docker compose exec <service> cat /etc/os-release` | run one command, no shell |
| `docker cp <container>:/path/file .` | copy a file out (or in, swap the arguments) |
| `docker run --rm -it alpine sh` | throwaway container to test something, deleted on exit (`--rm`) |

## 4. Looking around (system-wide)

| Command | Does |
|---|---|
| `docker ps` / `docker ps -a` | running containers / including stopped |
| `docker stats` | live CPU / RAM per container (like htop) |
| `docker images` | downloaded images + size |
| `docker volume ls` / `docker network ls` | volumes / networks |
| `docker inspect <container>` | everything as JSON — mounts, IP, env, restart policy |
| `docker logs -f <container>` | logs by container name |
| `docker system df` | disk space used by images, containers, volumes, build cache |

Filter `inspect` output instead of scrolling: `docker inspect -f '{{ .State.Status }}' homepage`

## 5. Cleaning up

| Command | Does |
|---|---|
| `docker image prune` | remove dangling images (old versions without a tag) |
| `docker image prune -a` | remove **all** images not used by a container |
| `docker container prune` | remove stopped containers |
| `docker system prune` | stopped containers + unused networks + dangling images + build cache |
| `docker volume prune` | ⚠ unused volumes — that can be data. Check `docker volume ls` first |

## 6. compose.yaml — the parts you'll edit

```yaml
services:
  homepage:                         # service name (used in compose commands)
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage        # fixed name (otherwise <folder>-<service>-1)
    restart: unless-stopped         # start again after reboot / crash, unless you stopped it
    ports:
      - "80:3000"                   # host:container — Pi port 80 → app port 3000
    volumes:
      - ./config:/app/config        # bind mount: host folder (relative to compose.yaml) → container
    environment:
      - TZ=Europe/Berlin
```

- Two services can't use the **same host port**. Check what's taken: `ports` alias (`ss -tulpn`)
- Secrets go in a `.env` file next to `compose.yaml` (`KEY=value`, use as `${KEY}`) — keep `.env` out of git

## 7. When something's wrong

| Symptom | Look at |
|---|---|
| container keeps restarting | `docker compose logs <service>` — the error is usually in the last lines |
| port not reachable | `docker compose ps` (port shown?), `ports`, is the app listening on `0.0.0.0` inside? |
| "permission denied" on a bind mount | owner of the host folder vs the user the container runs as (`ls -ln`, image docs: `PUID`/`PGID`) |
| disk filling up | `docker system df`, then `docker image prune -a` |
| docker itself | `systemctl status docker`, `journalctl -u docker -e` |

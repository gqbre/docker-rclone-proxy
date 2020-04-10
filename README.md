<!--
 * @Author: your name
 * @Date: 2020-04-08 00:35:34
 * @LastEditTime: 2020-04-10 11:25:24
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: /docker-rclone-proxy/README.md
 -->
[rcloneurl]: https://rclone.org

[<img src="https://rclone.org/img/logo_on_light__horizontal_color.svg" width="50%" alt="rclone logo">](https://rclone.org/)

# Docker Rclone Proxy

Project's DockerHub [https://hub.docker.com/r/gqbre/docker-rclone-proxy](https://hub.docker.com/r/gqbre/docker-rclone-proxy)

Tutorial in Chinese [https://www.sheyilin.com/2020/04/docker-rclone-proxy](https://www.sheyilin.com/2020/04/docker-rclone-proxy)

Lightweight and simple Container Image (`alpine:latest - 160MB`) with compiled rclone (https://github.com/ncw/rclone master).

You need a working rclone.conf

## Usage Example:

```
docker run -d --name docker-rclone-proxy \
  --restart=unless-stopped \
  --cap-add SYS_ADMIN \
  --device /dev/fuse \
  --security-opt apparmor:unconfined \
  -e RemotePath="mediaefs:" \
  -e MountCommands="--allow-other --allow-non-empty" \
  -e Proxy="false" \
  -v /path/to/config:/config \
  -v /host/mount/point:/mnt/mediaefs:shared \
  gqbre/docker-rclone-proxy
```

> mandatory docker commands:

- --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined


> needed volume mappings:

- -v /path/to/config:/config
- -v /host/mount/point:/mnt/mediaefs:shared


> HTTP Proxy commands:
> Set HTTP/S Proxy before mount conmands

- -e Proxy="false"
- -e ProxyTarget="host.docker.internal"
- -e ProxyPort="1087"


## Environment Variables:

| Variable |  | Description |
|---|--------|----|
|`RemotePath`="mediaefs:path" | |remote name in your rclone config, can be your crypt remote: + path/foo/bar|
|`MountPoint`="/mnt/mediaefs"| |#INSIDE Container: needs to match mapping -v /host/mount/point:`/mnt/mediaefs:shared`|
|`ConfigDir`="/config"| |#INSIDE Container: -v /path/to/config:/config|
|`ConfigName`="rclone.conf"| |#INSIDE Container: /config/rclone.conf|
|`MountCommands`="--allow-other --allow-non-empty"| |default mount commands, (if you not parse anything, defaults will be used)|
|`UnmountCommands`="-u -z"| |default unmount commands|
|`AccessFolder`="/mnt" ||access with --volumes-from rclone-mount, changes of AccessFolder have no impact because its the exposed folder in the dockerfile.|
|`Proxy`="false"| |use http/s proxy setting or not|
|`ProxyTarget`="host.docker.internal"| |default `host.docker.internal` to connect the host machine (docker version 18.03+ supported but unreliable), set `172.17.0.1` in Synology DSM|
|`ProxyPort`="1087"| |port of http/s proxy|


### Use your own MountCommands with:
```Recommended:
-e MountCommands="--allow-other --allow-non-empty --buffer-size 32M --vfs-read-chunk-size=32M --vfs-read-chunk-size-limit 2048M --vfs-cache-mode writes --dir-cache-time 96h"
```

All Commands can be found at [https://rclone.org/commands/rclone_mount/](https://rclone.org/commands/rclone_mount/). Use `--buffer-size 256M` (dont go too high), when you encounter some "Direct Stream" problems on Plex Media Server (Samsung Smart TV for example).

### Troubleshooting:
When you force remove the container, you have to `sudo fusermount -u -z /mnt/mediaefs` on the hostsystem!
The `ProxyTarget` with value `host.docker.internal` is unreliabled, try `172.17.0.1` in Linux like Synology DSM, or use real IP address instead. Or you can try `--network host` mode to use host networking, with setting `ProxyTarget=localhost` to connect to host machine.


If you get an error like "docker: Error response from daemon: linux mounts: path /volume1/xxx is mounted on /volume1 but it is not a shared mount.", or "umount: can't unmount /mnt/mediaefs: Invalid argument" in Synology NAS(群晖) DSM operating system because of the `:shared` tag. Maybe you should try the command `sudo mount --make-shared /volume1` before runing the docker container, remember to change /volume1 to match your real setup.

### Thanks

This project base on [mumiehub/rclone-mount](https://hub.docker.com/r/mumiehub/rclone-mount)

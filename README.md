
Proof of concept container. It will automatically mount an image with s3ql and umount on exit doing fsck at the begining. It really mounts any swift unit, but the objective is to use hubic2swift and then use this container to get data.

# Requirements

hubic2swift installed on another container or machine, if you name it hubicgate and link it to this container, that are the default values.

# Environment variables

- `S3QL_CACHE_ENTRIES`: default 17000
- `S3QL_MOUNT`: default `/mnt/hubic`
- `S3QL_CACHESIZE`: default 10485760 (10GB = 10 * 1024 * 1024)
- `S3QL_METADATA_INTERVAL`: default 21600 (6h = 6 * 60 * 60) 
- `S3QL_STORAGE_URL`: default `hubicgate:80/default` (`<hostname>:<port>/<container>`)
- `S3QL_USER`: hubic
- `S3QL_PASSWORD`: dhubicgatepass
- `S3QL_FSPP`: default 12346789 (file system passphrase)

# Sample docker-compose

```yml
s3ql:
  build: s3ql
  environment:
    - S3QL_FSPP=0123456789
    - S3QL_USER=hubic
    - S3QL_PASSWORD=myhubic2swiftpasssword
    - S3QL_BACKEND_OPTIONS=no-ssl
  volumes:
    - ./cache:/tmp/cache
  devices:
    - /dev/fuse:/dev/fuse
  cap_add:
    - SYS_ADMIN
  links:
    - hubicgate
```

Check if is mounted

```bash
$ docker exec -ti s3ql_s3ql_1 df -h|grep hubic
swift://hubicgate:80/default/                           1.0T  4.0K  1.0T   1% /mnt/hubic
```

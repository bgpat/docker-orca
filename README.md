# docker-orca

[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/bgpat/orca.svg)](https://hub.docker.com/r/bgpat/orca)

Docker image for [ORCA](https://www.orca.med.or.jp/receipt/)

## Usage

### Run new server

```bash
# initialize DB and run ORCA server
make
```

### Restore from DB dump

```bash
# copy your dump file (*.dump) to ./restore
cp my_backup.dump restore/my_backup.dump

# start restoring
make restore

# run ORCA server
make
```

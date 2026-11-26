# Changelog

All notable changes to this project will be documented in this file. See [commit-and-tag-version](https://github.com/absolute-version/commit-and-tag-version) for commit guidelines.

## 1.0.0 (2026-11-26)

### Features

* deploy the Tdarr server as a non-root user, with claims for its database and server data ([111b708](https://github.com/tonylea/helm-chart-app-name/commit/111b70884cefa1de70d3e4a4fef6f57b8d4c6f83))

### Bug Fixes

* start Tdarr as root and let the image drop to PUID and PGID ([0c0febd](https://github.com/tonylea/helm-chart-app-name/commit/0c0febd74db0de67262c39285caae2b6c6e0986c))

### Documentation

* say Kubernetes creates the folders between the volumes ([a14aae5](https://github.com/tonylea/helm-chart-app-name/commit/a14aae533d4ad0e8c2ee6a1fce7f4053f655746a))

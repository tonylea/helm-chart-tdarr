# Tdarr Helm Chart

![Downloads](https://img.shields.io/github/downloads/tonylea/helm-chart-tdarr/total)

Deploys the [Tdarr](https://home.tdarr.io/) server from its official image, [`ghcr.io/haveagitgat/tdarr`](https://github.com/HaveAGitGat/Tdarr).
Tdarr transcodes and health-checks a media library, and the server schedules the work that its nodes do.

The chart runs one replica:

- A Deployment that stops the old pod before starting the new one, since the database is SQLite and takes one writer.
- Two PersistentVolumeClaims the chart owns unless an existing claim is given: one for the database at `/app/server/Tdarr/DB2`, and one for the rest of `/app/server`, which holds backups, plugins and samples.
  The database volume mounts inside the server volume.
- A transcode cache at `/temp`, an `emptyDir` unless an existing claim is given.
  The server and every node must see the cache and the media at the same paths.
- A Service on the web UI's port, 8265, and an optional Gateway API `HTTPRoute` to it.
  Nodes connect outbound to the server's port, 8266, which the container declares but no Service exposes yet.
- TCP liveness and readiness probes on the web UI port, since Tdarr documents no health endpoint.

Tdarr exposes no metrics, so the chart has no monitor or dashboard.

## Values

| Value | Default |
| --- | --- |
| `image.tag` | the chart's `appVersion` |
| `user` | `1000` |
| `group` | `1000` |
| `timezone` | `UTC` |
| `auth` | `true` |
| `apiKey.secretKeyRef.name` | none; the Secret holding the API key, required when the internal node and `auth` are on |
| `apiKey.secretKeyRef.key` | `api-key` |
| `jobReportsPath` | none; job reports stay in `Tdarr/DB2/JobReports` |
| `internalNode.enabled` | `false` |
| `internalNode.name` | `internal` |
| `internalNode.workers.transcodeCpu` | `2` |
| `internalNode.workers.healthcheckCpu` | `1` |
| `internalNode.workers.transcodeGpu` | `0` |
| `internalNode.workers.healthcheckGpu` | `0` |
| `resources` | none |
| `persistence.database.existingClaim` | none; the chart creates a claim |
| `persistence.database.storageClassName` | the cluster's default class |
| `persistence.database.size` | `1Gi` |
| `persistence.server.existingClaim` | none; the chart creates a claim |
| `persistence.server.storageClassName` | the cluster's default class |
| `persistence.server.size` | `2Gi` |
| `persistence.cache.existingClaim` | none; an `emptyDir` |
| `persistence.media` | none |
| `affinity` | none |
| `httpRoute.enabled` | `false` |
| `httpRoute.parentRefs` | none; required when enabled |
| `httpRoute.hostnames` | none |

### Media

Each `persistence.media` entry mounts an existing claim at a path, and needs a `name`, an `existingClaim` and a `mountPath`.
The nodes must mount the same claims at the same paths.

### Internal node

`internalNode.enabled` runs a node inside the server's pod, named `internalNode.name`, with the worker counts under `internalNode.workers`.
Nothing gives the pod a GPU, so the GPU worker counts stay at `0` unless something else does.
When it's off, none of the node's settings are passed.

### API key

`apiKey` names an existing Secret and the key in it that holds the API key.
The key must start with `tapi_`, be at least 14 characters, and hold only letters, digits and underscores.
It's passed as `seededApiKey`, which creates the key at start-up and, when no users exist, an `admin` user with the key as its password.
The internal node gets it as its `apiKey`, which it needs while `auth` is on.

## Fixed settings

The chart sets these, and Tdarr's environment variables override its JSON config:

- `serverIP=0.0.0.0`, `serverPort=8266` and `webUIPort=8265`, so the ports are the ones the container and Service use.
- `openBrowser=false`, since there's no browser in the container.

## User and group

The container starts as the image's default user, root, because the database volume mounts inside the server volume and Kubernetes creates the folders between them owned by root.
The image's startup takes ownership of its folders, then runs Tdarr as `user` and `group`, passed as `PUID` and `PGID`.

## Requirements

- A storage class for the database and server volumes, the cluster's default unless named.
- The existing claims for `persistence.media`, and any named in `persistence`.
- The Secret named in `apiKey`, when it's set.
- The Gateway API's `HTTPRoute` CRD, when `httpRoute.enabled` is set.

## Usage

```sh
helm repo add tdarr https://tonylea.github.io/helm-chart-tdarr
helm install tdarr tdarr/tdarr --values my-values.yaml
```

```yaml
timezone: Europe/London
# Key: api-key.
apiKey:
  secretKeyRef:
    name: tdarr-api-key
internalNode:
  enabled: true
persistence:
  media:
    - name: movies
      existingClaim: movies
      mountPath: /media/movies
```

## Development

Pull requests run:

- `helm lint --strict`, and the rendered chart checked by kubeconform against Kubernetes 1.37.
- helm-unittest's tests in `tests/`.
- An install and upgrade with chart-testing in a kind cluster.

Commits follow Conventional Commits.
Releases are versioned and tagged automatically from `main`, and published to the Helm repository on this repo's GitHub Pages.

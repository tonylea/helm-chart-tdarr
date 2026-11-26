{{- define "tdarr.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "tdarr.labels" -}}
{{ include "tdarr.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end }}

{{/* Without the chart's version, so a release that changes only the chart doesn't restart Tdarr. */}}
{{- define "tdarr.podLabels" -}}
{{ include "tdarr.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{- define "tdarr.claimName" -}}
{{- $root := index . 0 }}
{{- $volume := index . 1 }}
{{- $suffix := index . 2 }}
{{- $volume.existingClaim | default (printf "%s-%s" $root.Release.Name $suffix) }}
{{- end }}

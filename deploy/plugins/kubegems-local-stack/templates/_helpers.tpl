{{- define "observability.jaeger.address" -}}
{{- if .Values.observability.enabled  }}
    {{- printf "http://jaeger-operator-jaeger-query.%s:16686" .Values.observability.namespace }}
{{- else -}}
    {{- .Values.observability.externalJaeger.address }}
{{- end -}}
{{- end -}}

{{- define "monitoring.prometheus.address" -}}
{{- if .Values.monitoring.enabled  }}
    {{- printf "http://kube-prometheus-stack-prometheus.%s:9090" .Values.monitoring.namespace }}
{{- else -}}
    {{- .Values.monitoring.externalPrometheus.address }}
{{- end -}}
{{- end -}}

{{- define "monitoring.alertmanager.address" -}}
{{- if .Values.monitoring.enabled  }}
    {{- printf "http://kube-prometheus-stack-alertmanager.%s:9093" .Values.monitoring.namespace }}
{{- else -}}
    {{- .Values.monitoring.externalAlertmanager.address }}
{{- end -}}
{{- end -}}

{{- define "monitoring.grafana.address" -}}
{{- if .Values.monitoring.enabled  }}
    {{- printf "http://kube-prometheus-stack-grafana.%s:80" .Values.monitoring.namespace }}
{{- else -}}
    {{- .Values.monitoring.externalGrafana.address }}
{{- end -}}
{{- end -}}

{{- define "logging.loki.address" -}}
{{- if .Values.logging.enabled  }}
    {{- printf "http://loki-stack.%s:3100" .Values.logging.namespace }}
{{- else -}}
    {{- .Values.logging.externalLoki.address }}
{{- end -}}
{{- end -}}

{{- define "kubegems.local.agent.alert" -}}
    {{- printf "https://kubegems-local-agent.%s:8041/alert" .Values.kubegems.local.namespace }}
{{- end -}}

{{/*
{{ include "common.images.registry" . }}
*/}}
{{- define "common.images.registry" -}}
{{- $globalRegistry := .Values.global.imageRegistry -}}
{{- if $globalRegistry -}}
registry: {{ $globalRegistry }}
{{- end -}}
{{- end -}}

{{/*
{{ include "common.images.repository" ( dict "default" "library/alpine" "context" .) }}
*/}}
{{- define "common.images.repository" -}}
{{- $repository := .repository -}}
{{- $registry := .registry -}}
{{- $key := .key -}}
{{- if not $key -}}
  {{- $key = "repository" -}}
{{- end -}}
{{- $globalRegistry := .context.Values.global.imageRegistry -}}
{{- $globalRepository := .context.Values.global.imageRepository -}}
{{- if and $registry $globalRegistry -}}
    {{- $registry = $globalRegistry -}}
{{- end -}}
{{- if $globalRepository -}}
    {{- $repository = printf "%s%s" $globalRepository (regexFind "/.*" $repository)  -}}
{{- end -}}
{{- if or $globalRegistry $globalRepository -}}
    {{- if $registry -}}
        {{- printf "%s: %s/%s" $key $registry $repository -}}
    {{- else -}}
        {{- printf "%s: %s" $key $repository -}}
    {{- end -}}
{{- end -}}
{{- end -}}
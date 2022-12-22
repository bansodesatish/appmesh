{{- define "appmesh.envvar.value" -}}
  {{- $name := index . 0 -}}
  {{- $value := index . 1 -}}

- name: {{ $name }}
  value: {{ default "" $value | quote }}
{{- end -}}

{{- define "appmesh.envvar.configmap" -}}
  {{- $name := index . 0 -}}
  {{- $configMapName := index . 1 -}}
  {{- $configMapKey := index . 2 -}}

- name: {{ $name }}
  valueFrom:
    configMapKeyRef:
      name: {{ $configMapName }}
      key: {{ $configMapKey }}
{{- end -}}

{{- define "appmesh.envvar.secret" -}}
  {{- $name := index . 0 -}}
  {{- $secretName := index . 1 -}}
  {{- $secretKey := index . 2 -}}

- name: {{ $name }}
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: {{ $secretKey }}
{{- end -}}

{{- define "appmesh.envvar.configMapRef" -}}
- configMapRef:
    name: {{ . }}
{{- end -}}

{{- define "appmesh.envvar.secretRef" -}}
- secretRef:
    name: {{ . }}
{{- end -}}

{{- define "appmesh.envvar.env" -}}
{{- $context := .context -}}
      {{- range $key, $value := .values.keyValues }}
        {{- include "appmesh.envvar.value" (list $key $value ) | nindent 4 }}
      {{- end -}}
      {{- range $index, $secrets := .values.secrets }}
        {{- with $secrets -}}
          {{- if .secretKey -}}
            {{- include "appmesh.envvar.secret" (list .envName .secretName .secretKey ) | nindent 4 }}  
          {{- end -}}
        {{- end -}}
      {{- end -}}
      {{- range $index, $secrets := .values.configmaps }}
        {{- with $secrets -}}
          {{- if .configMapKey -}}
            {{- include "appmesh.envvar.configmap" (list .envName .configMapName .configMapKey ) | nindent 4 }}  
          {{- end }}
        {{- end }}
      {{- end }}
      {{- range $index, $value := .values.backendApplicationFQName }}
        {{- $FQN:= print (include "appmesh.name.serviceFQName" (dict "appName" $value.backendAppName "context" $context )) -}}
        {{- $envValue := $value.value | replace $value.placeHolder $FQN -}}
        {{- include "appmesh.envvar.value" (list $value.name $envValue ) | nindent 4 }}
      {{- end }}
{{- end }}    

{{- define "appmesh.envvar.envFrom" -}}
      {{- range $index, $secrets := .secrets }}
        {{- with $secrets -}}
          {{- if not .secretKey -}}
            {{- include "appmesh.envvar.secretRef" .secretName  | nindent 4 }}  
          {{- end -}}
        {{- end -}}
      {{- end -}}
      {{- range $index, $secrets := .configmaps }}
        {{- with $secrets -}}
          {{- if not .configMapKey -}}
            {{- include "appmesh.envvar.configMapRef" .configMapName | nindent 4 }}  
          {{- end }}
        {{- end }}
      {{- end }}
{{- end }}  
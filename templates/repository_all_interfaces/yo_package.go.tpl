// Code generated by yo. DO NOT EDIT.
package {{ .Package }}
{{- range $k, $v := .TableMap }}

type {{$v.Name}}Repository interface {
	{{$v.Name}}RepositoryIndexes
	{{$v.Name}}RepositoryCRUD
}
{{- end }}
{{- /* */ -}}
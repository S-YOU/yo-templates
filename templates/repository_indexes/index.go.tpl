{{- $short := (shortname .Type.Name "err" "sqlstr" "db" "q" "res" .Fields) -}}
{{- $name := (print (goparamname .Type.Name ) "Repository") -}}
{{- $table := (.Type.Table.TableName) -}}
{{- $database := (print .Type.Name "Repository") -}}
{{- $lname := (goparamname .Type.Name) -}}
{{- $idx0 := (index .Fields 0) }}

{{- if not .Index.IsUnique }}

// Get{{ .FuncName }} retrieves multiple rows from '{{ $table }}' as a slice of {{ .Type.Name }}.
// Generated from index '{{ .Index.IndexName }}'.
func ({{$short}} {{$name}}) Find{{ .FuncName }}(ctx context.Context{{ goparamlist .Fields true true }}) ([]*model.{{ .Type.Name }}, error) {
	{{ $lname }} := []*model.{{ .Type.Name }}{}
	if err := {{$short}}.Builder().
		Where("{{ colnamesquery .Fields " AND " }}", Params{
		{{- range $i, $f := .Fields -}}
			{{- if (gt $i 0) }}, {{ end -}}
			"param{{ $i }}": {{ goparamname $f.Name }}
		{{- end}}}).
		Query(ctx).Intos(&{{ $lname }}); err != nil {
		return nil, err
	}

	return {{ $lname }}, nil
}
{{- else }}

// Find{{ .FuncName }} retrieves a row from '{{ $table }}' as a {{ .Type.Name }}.
// Generated from unique index '{{ .Index.IndexName }}'.
func ({{$short}} {{$name}}) Get{{ .FuncName }}(ctx context.Context{{ goparamlist .Fields true true }}) (*model.{{ .Type.Name }}, error) {
	{{ $lname }} := &model.{{ .Type.Name }}{}
	if err := {{$short}}.Builder().
		Where("{{ colnamesquery .Fields " AND " }}", Params{
		{{- range $i, $f := .Fields -}}
			{{- if (gt $i 0) }}, {{- end }}
			"param{{ $i }}": {{ goparamname $f.Name }}
		{{- end}}}).
		Query(ctx).Into({{ $lname }}); err != nil {
		return nil, err
	}

	return {{ $lname }}, nil
}
{{- end }}

{{- if eq (len .Fields) 1 }}

// Find{{.FuncName}}s retrieves multiple rows from '{{ $table }}' as []*model.{{ .Type.Name }}.
// Generated from unique index '{{ .Index.IndexName }}'.
func ({{$short}} {{$name}}) Find{{.FuncName}}s(ctx context.Context, ids []{{$idx0.Type}}) ([]*model.{{ .Type.Name }}, error) {
	var items []*model.{{ .Type.Name }}
	if err := {{$short}}.Builder().Where("{{colname $idx0.Col}} IN UNNEST(?)", ids).Query(ctx).Intos(&items); err != nil {
		return nil, err
	}

	return items, nil
}
{{- end -}}

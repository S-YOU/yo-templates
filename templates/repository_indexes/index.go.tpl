{{- $short := (shortname .Type.Name "err" "sqlstr" "db" "q" "res" .Fields) -}}
{{- $name := (print (goparamname .Type.Name ) "Repository") -}}
{{- $table := (.Type.Table.TableName) -}}
{{- $typeName := .Type.Name -}}
{{- $database := (print .Type.Name "Repository") -}}
{{- $lname := (goparamname .Type.Name) -}}
{{- $pkeys := .Type.PrimaryKeyFields -}}

{{- if not .Index.IsUnique }}

// Find{{pluralize $typeName}}By{{- range $i, $f := .Fields }}{{ if $i }}And{{ end }}{{ .Name }}{{ end }}Fast retrieves multiple rows from '{{ $table }}' as a slice of {{ .Type.Name }}.
// Generated from index '{{ .Index.IndexName }}'. This retrieves only primary key, index key and storing columns
func ({{$short}} {{$name}}) Find{{pluralize $typeName}}By{{- range $i, $f := .Fields }}{{ if $i }}And{{ end }}{{ .Name }}{{ end }}Fast(ctx context.Context{{ goparamlist .Fields true true }}) ([]*model.{{ .Type.Name }}, error) {
	{{ $lname }} := []*model.{{ .Type.Name }}{}
	if err := {{$short}}.ReadUsingIndex(ctx, "{{ .Index.IndexName }}", Key{ {{- goparamlist .Fields false false -}} }).Intos(&{{ $lname }}); err != nil {
		return nil, err
	}

	return {{ $lname }}, nil
}

// Find{{pluralize $typeName}}By{{- range $i, $f := .Fields }}{{ if $i }}And{{ end }}{{ .Name }}{{ end }} retrieves multiple rows from '{{ $table }}' as a slice of {{ .Type.Name }}.
// Generated from index '{{ .Index.IndexName }}'.
func ({{$short}} {{$name}}) Find{{pluralize $typeName}}By{{- range $i, $f := .Fields }}{{ if $i }}And{{ end }}{{ .Name }}{{ end }}(ctx context.Context{{ goparamlist .Fields true true }}) ([]*model.{{ .Type.Name }}, error) {
	{{ $lname }} := []*model.{{ .Type.Name }}{}
	if err := {{$short}}.Builder().Where("{{ colnamesquery .Fields " AND " }}", Params{
		{{- range $i, $f := .Fields -}}
			{{- if $i }}, {{ end -}}
			"param{{ $i }}": {{ goparamname $f.Name }}
		{{- end}}}).Query(ctx).Intos(&{{ $lname }}); err != nil {
		return nil, err
	}

	return {{ $lname }}, nil
}
{{- else }}

// Get{{$typeName}}By{{- range $i, $f := .Fields }}{{ if $i }}And{{ end }}{{ .Name }}{{ end }} retrieves a row from '{{ $table }}' as a {{ .Type.Name }}.
// Generated from unique index '{{ .Index.IndexName }}'.
func ({{$short}} {{$name}}) Get{{$typeName}}By{{- range $i, $f := .Fields }}{{ if $i }}And{{ end }}{{ .Name }}{{ end }}(ctx context.Context{{ goparamlist .Fields true true }}) (*model.{{ .Type.Name }}, error) {
	{{ $lname }} := &model.{{ .Type.Name }}{}
	if err := {{$short}}.Builder().Where("{{ colnamesquery .Fields " AND " }}", Params{
		{{- range $i, $f := .Fields -}}
			{{- if $i }}, {{- end -}}
			"param{{ $i }}": {{ goparamname $f.Name }}
		{{- end}}}).Query(ctx).Into({{ $lname }}); err != nil {
		return nil, err
	}

	return {{ $lname }}, nil
}

// Get{{$typeName}}By{{- range $i, $f := .Fields }}{{ if $i }}And{{ end }}{{ .Name }}{{ end }}Fast retrieves a row from '{{ $table }}' as a {{ .Type.Name }}.
// Generated from unique index '{{ .Index.IndexName }}'. This retrieves only primary key, index key and storing columns
func ({{$short}} {{$name}}) Get{{$typeName}}By{{- range $i, $f := .Fields }}{{ if $i }}And{{ end }}{{ .Name }}{{ end }}Fast(ctx context.Context{{ goparamlist .Fields true true }}) (*model.{{ .Type.Name }}, error) {
	{{ $lname }} := &model.{{ .Type.Name }}{}
	if err := {{$short}}.ReadUsingIndex(ctx, "{{ .Index.IndexName }}", Key{ {{- gocustomparamlist .Fields false false -}} }).Into({{$lname}}); err != nil {
		return nil, err
	}

	return {{ $lname }}, nil
}
{{- end }}

{{- $inPkey := false }}
{{- if and (eq (len .Fields) 1) (gt (len $pkeys) 1) }}
	{{- range $_, $f := .Fields }}{{ range $_, $p := $pkeys }}{{ if eq $p.Name $f.Name }}{{ $inPkey = true }}{{ end }}{{end}}{{ end }}
{{- end }}
{{- if not $inPkey }}
// Find{{pluralize $typeName}}By{{- range $i, $f := .Fields }}{{ if $i }}And{{ end }}{{pluralize .Name }}{{ end }} retrieves multiple rows from '{{ $table }}' as []*model.{{ .Type.Name }}.
// Generated from index '{{ .Index.IndexName }}'.
func ({{$short}} {{$name}}) Find{{pluralize $typeName}}By{{- range $i, $f := .Fields }}{{ if $i }}And{{ end }}{{pluralize .Name }}{{ end }}(ctx context.Context{{- range .Fields }}, {{goparamname (pluralize .Name)}} []{{.Type}}{{end}}) ([]*model.{{ .Type.Name }}, error) {
	var items []*model.{{ .Type.Name }}
	if err := {{$short}}.Builder().Where("{{- range $i, $f := .Fields }}{{ if $i }} AND {{ end }}{{colname $f.Col}} IN UNNEST(@arg{{$i}}){{ end -}}", Params{
	{{- range $i, $f := .Fields -}}
		{{- if $i }}, {{ end -}}
		"arg{{ $i }}": {{goparamname (pluralize .Name)}}
	{{- end}}}).Query(ctx).Intos(&items); err != nil {
		return nil, err
	}

	return items, nil
}
{{- end }}

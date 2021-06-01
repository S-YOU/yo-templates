// Code generated by yo. DO NOT EDIT.
// Package {{ .Package }} contains the types.
package {{ .Package }}

import (
	"github.com/google/uuid"
)

func NewUUID() (string, error) {
	id, err := uuid.NewRandom()
	if err != nil {
		return "", err
	}
	return id.String(), nil
}
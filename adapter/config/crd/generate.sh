#!/bin/bash
#
# Copyright 2017 Istio Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################
#
# Generate structs for CRDs

cat << EOF
// Copyright 2017 Istio Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package crd

//
// THIS FILE IS AUTO-GENERATED. DO NOT EDIT DIRECTLY.
//

import (
	meta_v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"

	"istio.io/pilot/model"
)

var knownTypes = map[string]struct {
	obj        istioObject
	collection istioObjectList
}{
EOF

CRDS="MockConfig RouteRule IngressRule DestinationPolicy"

for crd in $CRDS; do
cat << EOF
	model.$crd.Type: {
		obj:        &${crd}{TypeMeta: meta_v1.TypeMeta{Kind: "${crd}", APIVersion: model.IstioAPIVersion}},
		collection: &${crd}List{},
	},
EOF

done

cat <<EOF
}

EOF

for crd in $CRDS; do
  sed -e "1,20d;s/IstioKind/$crd/g" adapter/config/crd/config.go
done

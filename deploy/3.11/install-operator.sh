#!/usr/bin/env bash


NAMESPACE="splunk-connect-operator"
IMAGE=$1
TAG=$2
HEC_TOKEN_B64=$3

if [[ -z $IMAGE ]]; then
 printf "You must provide image repository with name!!!\n"
 exit 1
fi

if [[ -z $TAG ]]; then
 printf "You must provide image tag!!!\n"
 exit 1
fi

if [[ -z $HEC_TOKEN_B64 ]]; then
 printf "You must provide Splunk HEC token encoded in base64 !!!\n"
 exit 1
fi

printf "Create operator project\n"
cat <<EOF | oc apply -f-
apiVersion: v1
kind: Namespace
metadata:
  name: ${NAMESPACE}
spec: {}
EOF


printf "Create or update CRD\n"
cat <<EOF | oc apply -f-
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: splunkconnects.logging.ocp.io
spec:
  group: logging.ocp.io
  names:
    kind: SplunkConnect
    listKind: SplunkConnectList
    plural: splunkconnects
    singular: splunkconnect
  scope: Namespaced
  subresources:
    status: {}
#    validation:
#      openAPIV3Schema:
#        type: object
#        x-kubernetes-preserve-unknown-fields: true
  versions:
    - name: v1
      served: true
      storage: true
EOF


printf "Create service account roles and cluster rolebindings\n"
cat <<EOF | oc -n ${NAMESPACE} apply -f-
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: splunk-connect
---
apiVersion: authorization.openshift.io/v1
groupNames: null
kind: ClusterRoleBinding
metadata:
  name: splunk-connect-operator-cluster-admin
roleRef:
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: splunk-connect
    namespace: ${NAMESPACE}
userNames:
  - system:serviceaccount:${NAMESPACE}:splunk-connect

---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: splunk-connect
subjects:
  - kind: ServiceAccount
    name: splunk-connect
roleRef:
  kind: Role
  name: splunk-connect
  apiGroup: rbac.authorization.k8s.io

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
 creationTimestamp: null
 name: splunk-connect
rules:
- apiGroups:
    - ""
  resources:
    - pods
    - services
    - services/finalizers
    - endpoints
    - persistentvolumeclaims
    - events
    - configmaps
    - secrets
  verbs:
    - create
    - delete
    - get
    - list
    - patch
    - update
    - watch
- apiGroups:
    - apps
  resources:
    - deployments
    - daemonsets
    - replicasets
    - statefulsets
  verbs:
    - create
    - delete
    - get
    - list
    - patch
    - update
    - watch
- apiGroups:
    - monitoring.coreos.com
  resources:
    - servicemonitors
  verbs:
    - get
    - create
- apiGroups:
    - apps
  resourceNames:
    - splunk-connect
  resources:
    - deployments/finalizers
  verbs:
    - update
- apiGroups:
    - ""
  resources:
    - pods
  verbs:
    - get
- apiGroups:
    - apps
  resources:
    - replicasets
    - deployments
  verbs:
    - get
- apiGroups:
    - logging.ocp.io
  resources:
    - '*'
  verbs:
    - create
    - delete
    - get
    - list
    - patch
    - update
    - watch
EOF


printf "Create secret with HEC token\n"
cat <<EOF | oc -n ${NAMESPACE} apply -f-
apiVersion: v1
kind: Secret
metadata:
   name:   splunk-hec
type: Opaque
data:
  splunk_hec_token: ${HEC_TOKEN_B64}
EOF

printf "Create deployment\n"
cat <<EOF | oc -n ${NAMESPACE}  apply -f-
apiVersion: apps/v1
kind: Deployment
metadata:
  name: splunk-connect-operator
spec:
  replicas: 1
  selector:
    matchLabels:
      name: splunk-connect-operator
  template:
    metadata:
      labels:
        name: splunk-connect-operator
    spec:
      serviceAccountName: splunk-connect
      containers:
        - name: ansible
          command:
            - /usr/local/bin/ao-logs
            - /tmp/ansible-operator/runner
            - stdout
          image: "${IMAGE}:${TAG}"
          imagePullPolicy: "Always"
          volumeMounts:
            - mountPath: /tmp/ansible-operator/runner
              name: runner
              readOnly: true
        - name: operator
          image: "${IMAGE}:${TAG}"
          imagePullPolicy: "Always"
          volumeMounts:
            - mountPath: /tmp/ansible-operator/runner
              name: runner
          env:
            - name: WATCH_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: OPERATOR_NAME
              value: "splunk-connect"
            - name: ANSIBLE_GATHERING
              value: explicit
      volumes:
        - name: runner
          emptyDir: {}
EOF

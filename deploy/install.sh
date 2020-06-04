oc adm new-project  splunk-connect-operator

oc process -f  install-template-3.11-private.yaml  -p GIT_REPO=$1 -p GIT_BRANCH=$2 -p HEC_TOKEN_B64=$3 | oc -n splunk-connect-operator apply -f-






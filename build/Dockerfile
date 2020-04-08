FROM quay.io/operator-framework/ansible-operator:v0.15.2
#This's hack for openshift client in release version
RUN  pip3 install --user --upgrade openshift kubernetes hvac
COPY watches.yaml ${HOME}/watches.yaml

COPY roles/ ${HOME}/roles/

Role Name
=========
Установка и конфигурация Fluentd агентов для отправки всех логов кластера OpenShift в Splunk

За основу взято: https://github.com/splunk/splunk-connect-for-kubernetes/tree/develop/manifests/splunk-kubernetes-logging 

Requirements
------------

Клиентская python библиотека для работы с k8s , можно установить командой:  ```pip install openshift```

Role Variables
--------------


```splunk_hec_host```  -  Splunk hostname 

```splunk_hec_protocol```  - протокол для взаимодействия со Splunk (по умолчанию https )

```splunk_port```  - номер порта на Splunk (по умолчанию  8080 )


Example Playbook
----------------

Пример вызова роли в playbook :

```


- hosts: localhost
  gather_facts: no
  become: no
  tasks:
    - include_role:
                 name: openshift_splunk_logs_aggregation

```

License
-------

BSD

Author Information
------------------

YurevID@it.mos.ru 

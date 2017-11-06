#!/bin/bash

##### https://www.zabbix.com/documentation/3.0/manual/api/reference/user/login
hostname=192.168.1.200

gethostid(){
hostid=`curl -s -X POST -H 'Content-Type:application/json' -d '
 {
     "jsonrpc": "2.0",
     "method": "host.get",
     "params": {
         "output": ["hostid"],
		 "filter": {
            "host": [
                "'$hostname'"
            ]
        }
     },
     "auth": "ca8a7ae867dac1d4a213c3afb6defcca8a7ae867dac1d4a21",
     "id": 1
 }'  http://hostip:port/api_jsonrpc.php | jq . | grep hostid | awk -F':' '{print $2}' | sed 's/"//g' | sed 's/ //g'`
 echo $hostid
}

getinterfaceid(){
interfaceid=`curl -s -X POST -H 'Content-Type:application/json' -d ' 
{
    "jsonrpc": "2.0",
    "method": "hostinterface.get",
    "params": {
        "output": "extend",
        "hostids": "'$hostid'"
    },
    "auth": "ca8a7ae867dac1d4a213c3afb6defcca8a7ae867dac1d4a21",
    "id": 1
}' http://hostip:port/api_jsonrpc.php | jq . | grep interfaceid | awk -F':' '{print $2}' | sed 's/"//g' | sed 's/ //g' | sed 's/,//g'`
echo $interfaceid
}

getapplicationid(){
applicationid=`curl -s -X POST -H 'Content-Type:application/json' -d ' 
{
    "jsonrpc": "2.0",
    "method": "application.get",
    "params": {
        "output": "extend",
        "hostids": "'$hostid'",
        "sortfield": "name"
    },
    "auth": "ca8a7ae867dac1d4a213c3afb6defcca8a7ae867dac1d4a21",
    "id": 1
}' http://hostip:port/api_jsonrpc.php | jq . | grep -B 2  HAPROXY | grep applicationid | awk -F':' '{print $2}' | sed 's/"//g' | sed 's/ //g' | sed 's/,//g'`
echo $applicationid
}

doexec(){
for i in `cat ha_server.txt | awk -F',' '{print $1}'` 
do
curl -s -X POST -H 'Content-Type:application/json' -d ' 
 {
    "jsonrpc": "2.0",
    "method": "item.create",
    "params": {
        "name": "'$i'",
        "key_": "'$i'",
        "hostid": "'$hostid'",
        "type": 0,
        "value_type": 3,
        "delta": 2,
        "interfaceid": '$interfaceid',
        "applications": [
            "'$applicationid'"
        ],
        "delay": 60
    },
    "auth": "ca8a7ae867dac1d4a213c3afb6defcca8a7ae867dac1d4a21",
    "id": 1
}' http://hostip:port/api_jsonrpc.php
done
}

gethostid
getinterfaceid
getapplicationid
doexec

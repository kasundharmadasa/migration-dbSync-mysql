#!/bin/sh

sourceDBUrl=
sourceDBUser=
sourceDBPass=
sourceDBDriver="com.mysql.jdbc.Driver"

destDBUrl=
destDBUser=
destDBPass=
destDBDriver="com.mysql.jdbc.Driver"

java -jar org.wso2.carbon.migration.dbsync-1.0.0-jar-with-dependencies.jar \
$sourceDBUrl  $sourceDBUser  $sourceDBPass  $sourceDBDriver  $destDBUrl  $destDBUser  $destDBPass  $destDBDriver
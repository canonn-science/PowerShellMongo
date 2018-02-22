<#
.SYNOPSIS
  Initilises a mongo database with a copy of EDDB

.DESCRIPTION
  Uses a local fileset to instaniate a database, this is quite large and has no checking or error detection

.PARAMETER ExecPath
    Where your local mongo binary folder is

.PARAMETER HostAddress
    IP Address of Mongo Server

.PARAMETER ExecPath
    Where your local mongo binary folder is

.INPUTS
  csv, jsonl data files from https://eddb.io

.OUTPUTS
  Mongo Database

.NOTES
  Version:        1.0
  Author:         Andrew Holligs
  Creation Date:  21/02/2018
  Purpose/Change: Initial script development
  Contact         deepchaos66@hotmail.co.uk
  
.EXAMPLE
  .\InitialiseEDDB.ps1
#>

[CmdletBinding()]
Param (
    $ExecPath='c:\Program Files\MongoDB\Server\3.4\bin',
    $HostAddress = '127.0.0.1:27017',
    $ImportPath = 'c:\Elite'
)

clear-host

Set-Location $ExecPath

$ImportPath="C:\Elite"

start-process "./mongoimport"  -argumentlist "/host:$HostAddress /db:elite /collection:systems /type:csv /headerline $($ImportPath)\systems.csv /drop" -wait

# Warning this is big !
start-process ".\mongoimport" -argumentlist "/host:$HostAddress /db:elite /collection:bodies       /type:json            $($ImportPath)\bodies.jsonl /drop " -wait 

# Create All Indexes Even on collections which may or may not exist as its easier...  This can take a while
start-process ".\mongo" -argumentlist "127.0.0.1/elite  C:\git\canonn-science\PowerShellMongo\DataBase\Elite_Indexes.js" -wait

# Patch the bodies
start-process ".\mongoimport" -argumentlist "/host:$HostAddress /db:elite /collection:bodies       /type:json            $($ImportPath)\bodies_recently.jsonl /upsert /upsertFields:id " -wait 

start-process ".\mongoimport" -argumentlist "/host:$HostAddress /db:elite /collection:stations     /type:json /jsonArray $($ImportPath)\stations.json    /drop" -wait 
start-process ".\mongoimport" -argumentlist "/host:$HostAddress /db:elite /collection:factions     /type:json /jsonArray $($ImportPath)\factions.json    /drop" -wait 
start-process ".\mongoimport" -argumentlist "/host:$HostAddress /db:elite /collection:commodities  /type:json /jsonArray $($ImportPath)\commodities.json /drop" -wait 
start-process ".\mongoimport" -argumentlist "/host:$HostAddress /db:elite /collection:modules      /type:json /jsonArray $($ImportPath)\modules.json     /drop" -wait 

# Create All Indexes Even on collections which may or may not exist as its easier...  This can take a while... Existing indexes are not re-created / altered
start-process ".\mongo" -argumentlist "127.0.0.1/elite  C:\git\canonn-science\PowerShellMongo\DataBase\Elite_Indexes.js" -wait


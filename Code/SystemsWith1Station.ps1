<#
.SYNOPSIS
  Products a list of systems with only 1 station

.DESCRIPTION
  Products a list of systems with only 1 station, it is depentant on a mongo server with a database called elite.
  This database contains the collections which are imported from https://eddb.io

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  Requires Mongo Database either local or network

.OUTPUTS
  CSV File

.NOTES
  Version:        1.0
  Author:         Andrew Holligs
  Creation Date:  21/02/2018
  Purpose/Change: Initial script development
  Contact         deepchaos66@hotmail.co.uk
  
.EXAMPLE
  .\SystemsWith1Station.ps1
#>
[CmdletBinding()]
Param (
    [string]$FileName = "Systems With 1 Station.csv",
    [string]$OutFilePath="C:\Users\deepc\Google Drive\EDDB"
)

# import the mongo connector module
import-module mdbc

#connect to database
Connect-Mdbc mongodb://localhost:27017 elite

# setup pointers/objects to bits of database
$Database = $Server.GetDatabase('elite')
$systems = $Database.GetCollection('systems')
$factions = $Database.GetCollection('factions')
$bodies = $Database.GetCollection('bodies')
$stations = $Database.GetCollection('stations')

# main query
$AllSystems=Invoke-MdbcAggregate @(
    # group and count stations with same system_id
    @{ '$group' = @{
				_id = '$system_id'
				Count = @{ '$sum' = 1 }
    }}
    # select only systems with 1 station
    @{ '$match' = @{
       'Count' = @{ '$eq' = 1 }
    }}
    # ditch all data except system_id
    @{ '$project' = @{ 
       'system_id'= '$_id'
       '_id' = 0
    }}
    # left join to systems collection
    @{ '$lookup' = @{
       'from'         = 'systems'
       'localField'   = 'system_id'
       'foreignField' = 'id'
       'as'           = 'systems'
    }}
    # as each system is only 1 system turn the array into a document
    @{ '$unwind' = @{
       'path' = '$systems';
       'preserveNullAndEmptyArrays' = $false
    }}
    # left join to stations
    @{ '$lookup' = @{
       'from'         = 'stations'
       'localField'   = 'system_id'
       'foreignField' = 'id'
       'as'           = 'stations'
    }}
    # as each system is only 1 station turn the array into a document
    @{ '$unwind' = @{
       'path' = '$stations';
       'preserveNullAndEmptyArrays' = $false
    }}
    # ditch all data and rename fields
    @{ '$project' = @{ 
        'system_name' = '$systems.name'
        'x' = '$systems.x'
        'y' = '$systems.y'
        'z' = '$systems.z'
        'population' = '$systems.population'
        'stations_name' = '$stations.name'
        'stations_type' = '$stations.type'
        'stations_distance_to_star' = '$stations.distance_to_star'
        'stations_controlling_minor_faction_id' =   '$stations.controlling_minor_faction_id'
    }}
    # sort the data
    @{ '$sort' = @{
    'Stations_distance_to_star' = 1
    }}
) -Collection $stations 

if ( $AllSystems.count -gt 0 )
{
    # silently remove old file, if present
    remove-item "$OutFilePath\$FileName" -Force -ErrorAction SilentlyContinue
    
    #output header
    "system_name,x,y,z,population,stations_name,stations_type,stations_distance_to_star,Stations_controlling_minor_faction_id" | add-Content "$OutFilePath\$FileName"
    
    # Have to output RBAR - pants but true
    foreach($system in $AllSystems)
    {
        write-verbose "$($system.system_name),$($system.x),$($system.y),$($system.z),$($system.population),$($system.stations_name),$($system.stations_type),$($system.stations_distance_to_star),$($system.stations_controlling_minor_faction_id)"
        "$($system.system_name),$($system.x),$($system.y),$($system.z),$($system.population),$($system.stations_name),$($system.stations_type),$($system.stations_distance_to_star),$($system.stations_controlling_minor_faction_id)" | add-Content "$OutFilePath\$FileName"
    }
}
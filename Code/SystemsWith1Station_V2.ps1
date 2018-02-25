<#
.SYNOPSIS
  Products a list of systems with only 1 station

.DESCRIPTION
  Products a list of systems with only 1 station, it is depentant on a mongo server with a database called elite.
  This database contains the collections which are imported from https://eddb.io

.PARAMETER $FileName
    Filename for  the output file

.PARAMETER $OutFilePath
    Output Folder

.PARAMETER FurtherThan
    Find Stations further away from nav point
    default 100,000 ls

.PARAMETER CloserThan
    Find Stations closer than Nav point
    default 1000 ls

.PARAMETER AllStations
    Switch when added all stations are listed
    default OFF

.PARAMETER allegiance
    Default Any, when specified only specific Alliegance listed
    
.INPUTS
  Requires Mongo Database either local or network

.OUTPUTS
  CSV File

.NOTES
  Version:        2.0
  Author:         Andrew Holligs
  Creation Date:  21/02/2018
  Purpose/Change: Initial script development
  Contact         deepchaos66@hotmail.co.uk
  
.EXAMPLE 
  .\SystemsWith1Station.ps1

  lists any allience, stations < 1000 ls and > 100,000 ls

.EXAMPLE
 .\SystemsWith1Station.ps1 -allegiance Empire

  Lists any allience equal 'Empire' - Warning Case sensitive by design

.EXAMPLe

    .\SystemsWith1Station.ps1 -AllStations

    Lists all stations
#>
[CmdletBinding()]
Param (
    [string]$FileName = "Systems With 1 Station V2.csv",
    [string]$OutFilePath="C:\git\canonn-science\PowerShellMongo\Reports_Exports",
    [double]$FurtherThan = 1000,
    [double]$CloserThan = 100000,
    [switch]$AllStations,
    [ValidateSet('Any','Alliance','Empire','Federation','Independent')]
    [string]$allegiance = 'Any'
)

# nasty hack to change type for bson query
if($AllStations.IsPresent)
{
    $GetAllStations = $true
}
else
{
    $GetAllStations = $false
}
$GetAllStations = $true

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
$PopulatedSystems = $Database.GetCollection('systems_populated')

Write-Output "Running Query... Stanby."

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
    @{ '$addFields' = @{ 'allegiancetest' = $allegiance
                            'GetAllStations' = $GetAllStations
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
    @{ '$match' = @{    
        '$or' = @(   @{ 'stations.distance_to_star' = @{ '$lt' = $CloserThan  } }
                     @{ 'stations.distance_to_star' = @{ '$gt' = $FurtherThan } } 
                     @{ 'GetAllStations' = @{    '$eq' = $true } } )                  # force all stations if flag set
        '$and' = @(  @{ '$or' = @( @{  'stations.allegiance' = $allegiance }
                                   @{ 'allegiancetest' = @{ '$eq' = 'Any' } }      # force all allegiance unless set
                                    ) } )
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
        'stations_allegiance' = '$stations.allegiance'
        'stations_distance_to_star' = '$stations.distance_to_star'
        'stations_controlling_minor_faction_id' =   '$stations.controlling_minor_faction_id'
    }}
    # sort the data
    @{ '$sort' = @{
    'Stations_distance_to_star' = 1
    }}
) -Collection $stations 

# We could join another collection, but we'll Hash it, furture support for multi-faction dumps
$FactionList = Get-MdbcData  -Collection $factions
filter ArrayToHash
{
    begin { $hash = @{} }
    process { $hash[$_.id] = $_.name }
    end { return $hash }
}
$HashTable = $FactionList | ArrayToHash

if ( $AllSystems.count -gt 0 )
{
    Write-Output "Writing file... Stanby."
    # silently remove old file, if present
    remove-item "$OutFilePath\$FileName" -Force -ErrorAction SilentlyContinue
    
    #output header
    "system_name,x,y,z,population,stations_name,stations_type,stations_distance_to_star,Stations_controlling_minor_faction_id,stations_allegiance" | add-Content "$OutFilePath\$FileName"
    
    # Have to output RBAR - pants but true
    foreach($system in $AllSystems)
    {
        # cope with nulls
        try
        {
            $ControllingFaction = $HashTable.($system.stations_controlling_minor_faction_id)
        }
        catch
        {
            $ControllingFaction = 'not known'
        }
        write-verbose "$($system.system_name),$($system.x),$($system.y),$($system.z),$($system.population),$($system.stations_name),$($system.stations_type),$($system.stations_distance_to_star),$($system.stations_allegiance),$ControllingFaction "
        "$($system.system_name),$($system.x),$($system.y),$($system.z),$($system.population),$($system.stations_name),$($system.stations_type),$($system.stations_distance_to_star),$($system.stations_allegiance),$ControllingFaction " | add-Content "$OutFilePath\$FileName"
    }
}
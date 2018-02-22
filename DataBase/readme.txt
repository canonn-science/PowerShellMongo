Intructions for deploying local copy of EDDB On Windows

1. Install Mongo DB and Set as per documentation to run as service
2. Unzip EliteDB.zip somewhere c:\elite is good ;)
3. Download Files from https://github.com/canonn-science/PowerShellMongo
4. Copy File Elite_Indexes and InitialisedEDDB.ps1 to the location for step 2.
5. Open InitialisedEDDB.ps1 in powershell and wait a very long time ;)

NB Note the Elite.zip is 2.7 GB and you will need 27GB free to unzip.

Grab a copy here :- https://lab.canonn.technology/database/Elite.zip

There is also a Elite MongoDB(3.4) backup for Linux / Windows Hosts
which can be 'just' restored https://lab.canonn.technology/database/EliteDB.zip

To Backup a Mongo Database.
	mongodump /host:localhost /port:27017 /db:elite /out:c:\elite
NB the out parameter is the folder where to create a folder for the DB Backup

To Restore a Mongo Database.
	mongorestore /host:localhost /port:27017 /db:elite /drop c:\elite

WARNING this will DROP and any EXISTING DATABASE called elite
the out parameter is the folder where to create a folder for the DB Backup

The last parameter is the folder where you unzipped the files

The Mongo Database is about 13GB
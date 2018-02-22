//
// Written By Andy Hollings (deepchaos66@hotmail.co.uk)
// Initialises Elite DB Indexes
// If the exist they will be ignored
// 22/02/2018
//
db.getSiblingDB('elite').bodies.createIndex({ "_id" : 1 })
db.getSiblingDB('elite').bodies.createIndex({ "system_id" : 1 })
db.getSiblingDB('elite').bodies.createIndex({ "id" : 1 })
db.getSiblingDB('elite').commodities.createIndex({ "_id" : 1 })
db.getSiblingDB('elite').commodities.createIndex({ "name" : 1 })
db.getSiblingDB('elite').commodities.createIndex({ "id" : 1 })
db.getSiblingDB('elite').factions.createIndex({ "_id" : 1 })
db.getSiblingDB('elite').factions.createIndex({ "name" : 1 })
db.getSiblingDB('elite').factions.createIndex({ "id" : 1 })
db.getSiblingDB('elite').modules.createIndex({ "_id" : 1 })
db.getSiblingDB('elite').stations.createIndex({ "_id" : 1 })
db.getSiblingDB('elite').stations.createIndex({ "name" : 1 })
db.getSiblingDB('elite').stations.createIndex({ "id" : 1 })
db.getSiblingDB('elite').stations.createIndex({ "system_id" : 1 })
db.getSiblingDB('elite').systems.createIndex({ "_id" : 1 })
db.getSiblingDB('elite').systems.createIndex({ "x" : 1 })
db.getSiblingDB('elite').systems.createIndex({ "y" : 1 })
db.getSiblingDB('elite').systems.createIndex({ "z" : 1 })
db.getSiblingDB('elite').systems.createIndex({ "name" : 1 })
db.getSiblingDB('elite').systems.createIndex({ "id" : 1 })
db.getSiblingDB('elite').systems.createIndex({ "is_populated" : 1, "population" : 1 })
db.getSiblingDB('elite').systems.createIndex({ "population" : 1, "is_populated" : 1 })
db.getSiblingDB('elite').systems.createIndex({ "reserve_type" : 1 })
db.getSiblingDB('elite').temp.createIndex({ "_id" : 1 })


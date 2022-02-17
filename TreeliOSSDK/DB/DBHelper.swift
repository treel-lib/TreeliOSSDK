//
//  DBHelper.swift
//  demofrm
//
//  Created by Treel on 16/12/21.
//

import Foundation
import SQLite3

public struct DBHelper
{

    init()
    {
        db = openDatabase()
        createTable()
    }
    
    public var id : Int?
    public var tagId : String?
    static var DBHelperShared = DBHelper()
    let dbPath: String = "treelSDK.sqlite"
    var db:OpaquePointer?
    func openDatabase() -> OpaquePointer?
    {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
        {
            print("error opening database")
            return nil
        }
        else
        {
            print("Successfully opened connection to database at \(dbPath)")
            return db
        }
    }
    
    // MARK: Table Creation
    func createTable() {
        
   //MARK: ----------------------------Tyre Configuration Table---------------------------------
        let createTableString = "CREATE TABLE IF NOT EXISTS vehicle_configuration(Id INTEGER PRIMARY KEY AUTOINCREMENT,vin_number TEXT,mac_address TEXT,tyre_position TEXT,recommended_pressure INTEGER,low_pressure INTEGER,high_pressure INTEGER,high_temperature INTEGER,timeStamp TEXT,vehicleType TEXT,UNIQUE(mac_address));"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("vehicle_configuration table created.")
            } else {
                print("vehicle_configuration table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
        
        
    //MARK: ---------------------------------------------------------------------------------------
        
            //Create Table For SensorEventDetection
            let createSensorEventDetectionTable = "CREATE TABLE IF NOT EXISTS SensorEventDetection(id INTEGER PRIMARY KEY AUTOINCREMENT, vin_number TEXT, mac_address TEXT UNIQUE,tyre_position TEXT, sensor_data TEXT, detectionTimeStamp TEXT, last_low_pressure_time_stamp TEXT, last_high_pressure_time_stamp TEXT, last_high_temprature_stamp TEXT, data_type TEXT NOT NULL DEFAULT 'BLE', FOREIGN KEY(mac_address) REFERENCES vehicle_configuration(mac_address) ON UPDATE CASCADE ON DELETE CASCADE)"
            
            if sqlite3_exec(db, createSensorEventDetectionTable, nil, nil, nil) != SQLITE_OK {
                let errorMessage = String.init(cString: sqlite3_errmsg(db))
                print("SensorEventDetection error executing query \(errorMessage)")
                return
            }else{
                print("SensorEventDetection Table Created")
            }
            //MARK: ---------------------------------------------------------------------------------------
        
            //Create Table For Alerts
            let createAlertTable = "CREATE TABLE IF NOT EXISTS Alerts(id INTEGER PRIMARY KEY AUTOINCREMENT, vin_number TEXT, mac_address TEXT,tyre_position TEXT,alert_type TEXT, msg TEXT, timeStamp TEXT, isViewed INTEGER)"
            
            if sqlite3_exec(db, createAlertTable, nil, nil, nil) != SQLITE_OK {
                print("createAlertTable error executing query")
                return
            }else{
                print("Alert Table Created")
            }
        
            //MARK: ---------------------------------------------------------------------------------------
    
        
        
        let tpmsDataHistoryTable = "CREATE TABLE IF NOT EXISTS tpmsDataHistory(id INTEGER PRIMARY KEY AUTOINCREMENT, mac_address TEXT, vin_number TEXT,tyre_position TEXT, pressure INTEGER, temperature INTEGER, battery INTEGER,timeStamp TEXT)"
        
        if sqlite3_exec(db, tpmsDataHistoryTable, nil, nil, nil) != SQLITE_OK {
            let errorMessage = String.init(cString: sqlite3_errmsg(db))
            print("tpmsDataHistory error executing query \(errorMessage)")
            return
        }else{
            print("tpmsDataHistory Table Created")
        }
        
    }
    //MARK: value insertion queries
    
    func insertTireConfigData(vinNumber: String ,macAddress: String , tyrePosition: String , recommnededPressure : Int, lowPressure : Int , highPressure : Int, highTemp : Int , vehicleType : String )
      {
          

          let insertStatementString = "INSERT INTO vehicle_configuration (vin_number,mac_address,tyre_position, recommended_pressure,low_pressure, high_pressure,high_temperature,timeStamp,vehicleType) VALUES (?,?,?,?,?,?,?,?,?);"
          var insertStatement: OpaquePointer? = nil
          
          let vinNumber = vinNumber as NSString
          let macAddress = macAddress.replacingOccurrences(of: "\n", with: "") as NSString
          let tyrePosition = tyrePosition as NSString? ?? ""
          let vehicleType = vehicleType as NSString
 
          if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
              
               if sqlite3_bind_text(insertStatement, 1, vinNumber.utf8String,-1, nil)==SQLITE_OK &&
                  sqlite3_bind_text(insertStatement, 2, macAddress.utf8String,-1, nil)==SQLITE_OK &&
                  sqlite3_bind_text(insertStatement, 3, tyrePosition.utf8String,-1, nil)==SQLITE_OK &&
                  sqlite3_bind_int(insertStatement, 4, Int32(recommnededPressure))==SQLITE_OK &&
                  sqlite3_bind_int(insertStatement, 5, Int32(lowPressure))==SQLITE_OK &&
                  sqlite3_bind_int(insertStatement, 6, Int32(highPressure))==SQLITE_OK &&
                  sqlite3_bind_int(insertStatement, 7, Int32(highTemp))==SQLITE_OK &&
                  sqlite3_bind_text(insertStatement, 9, vehicleType.utf8String,-1, nil)==SQLITE_OK
              {
                  print("vehicle_configuration Inserted values")
              }
              
                  if sqlite3_step(insertStatement) == SQLITE_DONE {
                      print("vehicle_configuration Successfully inserted row.")
                  } else {
                      print("vehicle_configuration Could not insert row.")
                  }
                  // 4
                  sqlite3_reset(insertStatement)
//              }
              
              sqlite3_finalize(insertStatement)
          }else {
              print("vehicle_configuration INSERT statement could not be prepared.")
          }
      }
    
        //MARK: ---------------------------------------------------------------------------------------
    
        //Save All Sensor data to Local Database
    func SaveTpmsDataHistory(macAddress: String,vinNumber: String,tyrePosition: String ,pressure: Int,temperature: Int, battery: Int,timeStamp: String) {
   
        let insertStatementString = "INSERT INTO tpmsDataHistory (mac_address, vin_number, tyre_position, pressure, temperature, battery,timeStamp) VALUES ('\(macAddress)','\(vinNumber)','\(tyrePosition)','\(pressure)','\(temperature)','\(battery)','\(timeStamp)');"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("TREEL tpmsDataHistory event inserted")
            } else {
                let errorMessage = String.init(cString: sqlite3_errmsg(db))
                print("tpmsDataHistory Query could not be insert! \(errorMessage)")
            }
        } else {
            print("tpmsDataHistory INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    
    }
        //MARK: ---------------------------------------------------------------------------------------
    
    
    func saveSensorLastDetectionEvent(macAddress: String,vinNumber: String, sensorData: String, timeStamp: String, dataType: String,tyrePosition: String) {
     let insertStatementString = "INSERT INTO SensorEventDetection (vin_number,mac_address,tyre_position, sensor_data, detectionTimeStamp, data_type) VALUES ('\(vinNumber)','\(macAddress)','\(tyrePosition)','\(sensorData)','\(timeStamp)','\(dataType)');"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("TREEL saveSensorDetectionEvent inserted")
            } else {
              
                let errorMessage = String.init(cString: sqlite3_errmsg(db))
                print("saveSensorDetectionEvent Query could not be insert! \(errorMessage)")
            }
        } else {
            print("saveSensorDetectionEvent INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
        
        //Update incase insertion failed
        let updatedStatementString = "UPDATE SensorEventDetection SET sensor_data = '\(sensorData)', detectionTimeStamp = '\(timeStamp)', data_type = '\(dataType)' where mac_address = '\(macAddress)' ;"
        var updateStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, updatedStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("TREEL saveSensorDetectionEvent alert event updated")
            } else {
                print("saveSensorDetectionEvent alert event Could not update.")
            }
        } else {
            print("saveSensorDetectionEvent UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
    }
        //MARK: ---------------------------------------------------------------------------------------
        //MARK: Value Update queries
    
    func saveLowPressureAlertDetectionEvent(macAddress: String, timeStamp: String, dataType: String) {
       
        //Update incase insertion failed
        let updatedStatementString = "UPDATE SensorEventDetection SET last_low_pressure_time_stamp = '\(timeStamp)', data_type = '\(dataType)' where mac_address = '\(macAddress)' ;"
       
        var updateStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, updatedStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("LowPressure alert event updated")
            } else {
                print("LowPressure alert event Could not update.")
            }
        } else {
            print("LowPressure UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
    }
        //MARK: ---------------------------------------------------------------------------------------
    func saveHighPressureAlertDetectionEvent(macAddress: String, timeStamp: String, dataType: String) {
        
            
        //Update incase insertion failed
        let updatedStatementString = "UPDATE SensorEventDetection SET last_high_pressure_time_stamp = '\(timeStamp)', data_type = '\(dataType)' where mac_address = '\(macAddress)' ;"
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updatedStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
            print("HighPressure alert event updated")
            } else {
            print("HighPressure alert event Could not update.")
            }
        } else {
            print("HighPressure UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
    }
    
        //MARK: ---------------------------------------------------------------------------------------
    
    func saveHighTemperatureAlertDetectionEvent(macAddress: String, timeStamp: String, dataType: String) {
        
        let updatedStatementString = "UPDATE SensorEventDetection SET last_high_temprature_stamp = '\(timeStamp)', data_type = '\(dataType)' where mac_address = '\(macAddress)' ;"
        var updateStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, updatedStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("HighTemperature alert event updated")
            } else {
                print("HighTemperature alert event Could not update.")
            }
        } else {
            print("HighTemperature UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
    }
    
    
    
    
        //MARK: ---------------------------------------------------------------------------------------
    
        //MARK: Value Read queries
    public mutating func fetchVehiclesConfigurationData() -> [VehicleConfiguration]{

        let queryStatementString = "SELECT * FROM vehicle_configuration;"
        var queryStatement: OpaquePointer? = nil
        var tireConfig : [VehicleConfiguration] = []
               
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let ConfigID = sqlite3_column_int(queryStatement, 0)
                let vinNumber = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
               
                let macAddress = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                
                let tyrePosition = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                
                let recommnededPressure = sqlite3_column_int(queryStatement, 4)
                
                let lowPressure = sqlite3_column_int(queryStatement, 5)
                
                let highPressure = sqlite3_column_int(queryStatement, 6)
                
                let highTemp = sqlite3_column_int(queryStatement, 7)
                
                let vehicleType = String(describing: String(cString: sqlite3_column_text(queryStatement, 9)))
                
         
                tireConfig.append(VehicleConfiguration(configId: Int(ConfigID),vinNumber: vinNumber, macAddress: macAddress, tyrePosition: tyrePosition, recommendedPressureSetPoint: Int(recommnededPressure), lowPressureSetPoint: Int(lowPressure), highPressureSetPoint: Int(highPressure), highTemperatureSetPoint: Int(highTemp), vehicleType: vehicleType))

            }
            
         } else {
            print("fetchConfigurationForTag SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return tireConfig
    }
    
        //MARK: ---------------------------------------------------------------------------------------
    
    
    func getSensorDetectionEvent(macAddress: String)-> SensorDetectionEvent? {
        let queryStatementString = "select * from SensorEventDetection where mac_address = '\(macAddress)'"
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let sensorDetectionEvent = SensorDetectionEvent()
                
                
                let queryResultTagID = sqlite3_column_text(queryStatement, 1)
                sensorDetectionEvent.macAddress = String(cString: queryResultTagID!)
                
                let queryResultvinNumber = sqlite3_column_text(queryStatement, 2)
                sensorDetectionEvent.vinNumber = String(cString: queryResultvinNumber!)
                
                
                let queryResultSensorData = sqlite3_column_text(queryStatement, 3)
                sensorDetectionEvent.sensorData = String(cString: queryResultSensorData!)
                
                let queryResultTimestamp = sqlite3_column_text(queryStatement, 4)
                sensorDetectionEvent.sensorDetectionTimestamp = String(cString: queryResultTimestamp!)
                
                
                if let queryResultLowPressureTimestamp = sqlite3_column_text(queryStatement, 5) {
                    sensorDetectionEvent.lowPressureDetectionTimestamp = String(cString: queryResultLowPressureTimestamp)
                    
                }
                if let queryResultHighPressureTimestamp = sqlite3_column_text(queryStatement, 6) {
                    sensorDetectionEvent.highPressureDetectionTimestamp = String(cString: queryResultHighPressureTimestamp)
                    
                }
                if let queryResultHighTemperatureTimestamp = sqlite3_column_text(queryStatement, 7) {
                    sensorDetectionEvent.highTemperatureDetectionTimestamp = String(cString: queryResultHighTemperatureTimestamp)
                    
                }
                
                if let dataType = sqlite3_column_text(queryStatement, 8) {
                    sensorDetectionEvent.dataType = String(cString: dataType)
                }
  
            }
        }
        return nil
    }
        //MARK: ---------------------------------------------------------------------------------------
    
    
    func getAllSensorDetectionEvent(vinNumber: [String])-> [SensorDetectionEvent]? {
        
        let inExpression = vinNumber.compactMap{ String("'\($0)'") }.joined(separator: ",")
        
        let queryStatementString = "select * from SensorEventDetection where vin_number in (\(inExpression))"
//        let queryStatementString = "select * from SensorEventDetection;"

        var sensData : [SensorDetectionEvent] = []
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
            // 2
                let sensorDetectionEvent = SensorDetectionEvent()
                
                
                let queryResultvinNumber = sqlite3_column_text(queryStatement, 1)
                sensorDetectionEvent.vinNumber = String(cString: queryResultvinNumber!)
                
                let macAddress = sqlite3_column_text(queryStatement, 2)
                sensorDetectionEvent.macAddress = String(cString: macAddress!)
                
                
                let tirePosition = sqlite3_column_text(queryStatement, 3)
                sensorDetectionEvent.tirePosition = String(cString: tirePosition!)
                
                let sensorData = sqlite3_column_text(queryStatement, 4)
                sensorDetectionEvent.sensorData = String(cString: sensorData!)
                
                let sensorDetectionTimestamp = sqlite3_column_text(queryStatement, 5)
                sensorDetectionEvent.sensorDetectionTimestamp = String(cString: sensorDetectionTimestamp!)
                
                if let lowPressureDetectionTimestamp = sqlite3_column_text(queryStatement, 6) {
                    sensorDetectionEvent.lowPressureDetectionTimestamp = String(cString: lowPressureDetectionTimestamp)
                    
                }
                if let highPressureDetectionTimestamp = sqlite3_column_text(queryStatement, 7) {
                    sensorDetectionEvent.highPressureDetectionTimestamp = String(cString: highPressureDetectionTimestamp)
                    
                }
                if let highTemperatureDetectionTimestamp = sqlite3_column_text(queryStatement, 8) {
                    sensorDetectionEvent.highTemperatureDetectionTimestamp = String(cString: highTemperatureDetectionTimestamp)
                    
                }
                
                if let dataType = sqlite3_column_text(queryStatement, 9) {
                    sensorDetectionEvent.dataType = String(cString: dataType)
                }
 
                sensData.append(sensorDetectionEvent)
            }
        }else {
            print("getAllSensorData SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return sensData
    }
    
    
        //MARK: ---------------------------------------------------------------------------------------
    
    
    func getSensorDetectionEventByVinNumber(vinNumber: String )-> [SensorDetectionEvent]? {
        let queryStatementString = "select * from SensorEventDetection where vin_number = '\(vinNumber)'"
        var sensData : [SensorDetectionEvent] = []
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
            // 2
                let sensorDetectionEvent = SensorDetectionEvent()
                
                
                let queryResultvinNumber = sqlite3_column_text(queryStatement, 1)
                sensorDetectionEvent.vinNumber = String(cString: queryResultvinNumber!)
                
                let macAddress = sqlite3_column_text(queryStatement, 2)
                sensorDetectionEvent.macAddress = String(cString: macAddress!)
                
                
                let tirePosition = sqlite3_column_text(queryStatement, 3)
                sensorDetectionEvent.tirePosition = String(cString: tirePosition!)
                
                let sensorData = sqlite3_column_text(queryStatement, 4)
                sensorDetectionEvent.sensorData = String(cString: sensorData!)
                
                let sensorDetectionTimestamp = sqlite3_column_text(queryStatement, 5)
                sensorDetectionEvent.sensorDetectionTimestamp = String(cString: sensorDetectionTimestamp!)
                
                if let lowPressureDetectionTimestamp = sqlite3_column_text(queryStatement, 6) {
                    sensorDetectionEvent.lowPressureDetectionTimestamp = String(cString: lowPressureDetectionTimestamp)
                    
                }
                if let highPressureDetectionTimestamp = sqlite3_column_text(queryStatement, 7) {
                    sensorDetectionEvent.highPressureDetectionTimestamp = String(cString: highPressureDetectionTimestamp)
                    
                }
                if let highTemperatureDetectionTimestamp = sqlite3_column_text(queryStatement, 8) {
                    sensorDetectionEvent.highTemperatureDetectionTimestamp = String(cString: highTemperatureDetectionTimestamp)
                    
                }
                
                if let dataType = sqlite3_column_text(queryStatement, 9) {
                    sensorDetectionEvent.dataType = String(cString: dataType)
                }
 
                sensData.append(sensorDetectionEvent)
 
            }
        }else {
            print("getAllSensorData SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return sensData
    }
        //MARK: ---------------------------------------------------------------------------------------
    
    
    func getLastLowPressureAlertDetectionEvent(macAddress: String)-> String? {
        let queryStatementString = "select last_low_pressure_time_stamp from SensorEventDetection where mac_address = '\(macAddress)'"
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                // 2
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                if let queryResultCol = sqlite3_column_text(queryStatement, 0) {
                    let dateTime = String(cString: queryResultCol)
                    return dateTime
                }
            }
        }
        return nil
    }
    
        //MARK: ---------------------------------------------------------------------------------------
    
    
       
    
    func getLastHighPressureAlertDetectionEvent(macAddress: String)-> String? {
        let queryStatementString = "select last_high_pressure_time_stamp from SensorEventDetection where mac_address = '\(macAddress)'"
        
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                if let queryResultCol = sqlite3_column_text(queryStatement, 0) {
                    let dateTime = String(cString: queryResultCol)
                    return dateTime
                }
            }
        }
        return nil
    }
    
    
    func fetchVehicleDetails(vinNumber: String) -> VehicleConfiguration? {
        let Config = VehicleConfiguration()
        
        let queryStatementString = "select * from vehicle_configuration where vin_number = '\(vinNumber)'"
        
        if vinNumber == "" {
            
        }
        
        var queryStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
          
            if sqlite3_step(queryStatement) == SQLITE_ROW {
               
                let ConfigID = sqlite3_column_int(queryStatement, 0)
                let vinNumber = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
               
                let macAddress = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                
                let tyrePosition = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                
                let recommnededPressure = sqlite3_column_int(queryStatement, 4)
                
                let lowPressure = sqlite3_column_int(queryStatement, 5)
                
                let highPressure = sqlite3_column_int(queryStatement, 6)
                
                let highTemp = sqlite3_column_int(queryStatement, 7)
                
//                let timeStamp = String(describing: String(cString: sqlite3_column_text(queryStatement, 8)))
                let vehicleType = String(describing: String(cString: sqlite3_column_text(queryStatement, 9)))
                
                // 5
                print("fetchVehicleDetails Query Result:")
                print("\(ConfigID)| \(vinNumber)| \(macAddress)| \(tyrePosition)| \(recommnededPressure)| \(lowPressure)| \(lowPressure)| \(highTemp)")
                
                Config.configId = Int(ConfigID)
                Config.vinNumber = vinNumber
                Config.macAddress = macAddress
                Config.tyrePosition = tyrePosition
                Config.recommendedPressureSetPoint = Int(recommnededPressure)
                Config.highPressureSetPoint = Int(highPressure)
                Config.highTemperatureSetPoint = Int(highTemp)
                Config.vehicleType = vehicleType
                
                
                return Config
                
            } else {
                print("fetchVehicleDetails Query returned no results")
            }
        } else {
            print("fetchVehicleDetails SELECT statement could not be prepared")
        }
        return nil
    }
    
    
        //MARK: ---------------------------------------------------------------------------------------
    
     
    func getLastHighTemperatureAlertDetectionEvent(mac_address: String)-> String? {
        let queryStatementString = "select last_high_temprature_stamp from SensorEventDetection where mac_address = '\(mac_address)'"
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            // 2
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                if let queryResultCol = sqlite3_column_text(queryStatement, 0) {
                    let dateTime = String(cString: queryResultCol)
                    return dateTime
                }
                
            }
        }
        return nil
    }
 
    
    // ******************************* Alerts QUERY *************************** //
    //MARK: Save Alerts to Alert
    func saveAlerts(vinNumber: String?, macAddress: String?, alertType: String?, alertMessage: String?, timeStamp: String?,tyrePosition:String?, isViewed: Int?){
        
        let insertStatementString = "INSERT INTO Alerts (vin_number,mac_address,tyre_position, alert_type ,msg, timeStamp, isViewed) VALUES (?,?,?,?,?,?,?);"
        
        var insertStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            //Converting Strings to NSString
            let vinNumber = NSString(string: vinNumber!)
            let macAddress = macAddress?.replacingOccurrences(of: "\n", with: "") as NSString?
            let alertTyp = alertType as NSString?
            let alertMssg = alertMessage as NSString?
            let timeStamp = timeStamp as NSString?
            let isViewd = isViewed
            let tyrePosition = tyrePosition as NSString?
            
                if sqlite3_bind_text(insertStatement, 1, vinNumber.utf8String,-1, nil)==SQLITE_OK &&
                    sqlite3_bind_text(insertStatement, 2, macAddress?.utf8String,-1, nil)==SQLITE_OK &&
                    sqlite3_bind_text(insertStatement, 3, tyrePosition?.utf8String,-1, nil)==SQLITE_OK &&
                    sqlite3_bind_text(insertStatement, 4, alertTyp?.utf8String,-1, nil)==SQLITE_OK &&
                    sqlite3_bind_text(insertStatement, 5, alertMssg?.utf8String,-1, nil)==SQLITE_OK &&
                    sqlite3_bind_text(insertStatement, 6, timeStamp?.utf8String,-1, nil)==SQLITE_OK &&
                    sqlite3_bind_int(insertStatement, 7, Int32(isViewd!))==SQLITE_OK
                {
                    print("saveAlerts Inserted values")
                }else{
                    print("saveAlerts failed to insert")
                }
                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("saveAlerts Successfully inserted row.")
                } else {
                    print("saveAlerts Could not insert row.")
                }
                sqlite3_reset(insertStatement)

                sqlite3_finalize(insertStatement)
   
            
        } else {
            print("saveAlerts INSERT statement could not be prepared.")
        }
        
    }
   
        //MARK: ******************************************* DELETE QUERY *********************************************
    
    func deleteAllConfiguration(){
        
        let deleteStatementStirng = "DELETE FROM vehicle_configuration";
        
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("vehicle_configuration Successfully deleted row.")
            } else {
                print("vehicle_configuration Could not delete row.")
            }
        } else {
            print("vehicle_configuration DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
        
    }
    
    func deleteAllSensorDetectionEvent(){
        
        let deleteStatementStirng = "DELETE FROM SensorEventDetection";
        
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("SensorEventDetection Successfully deleted row.")
            } else {
                print("SensorEventDetection Could not delete row.")
            }
        } else {
            print("SensorEventDetection DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
        
    }
    
    func deleteAllAlerts(){
        
        let deleteStatementStirng = "DELETE FROM Alerts";
        
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Alerts Successfully deleted row.")
            } else {
                print("Alerts Could not delete row.")
            }
        } else {
            print("Alerts DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
        
    }
    
    func deleteAlltpmsDataHistory(){
        
        let deleteStatementStirng = "DELETE FROM tpmsDataHistory";
        
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("tpmsDataHistory Successfully deleted row.")
            } else {
                print("tpmsDataHistory Could not delete row.")
            }
        } else {
            print("tpmsDataHistory DELETE statement could not be prepared")
        }
        
        sqlite3_finalize(deleteStatement)
        
    }
    
    
}
//Alerts  tpmsDataHistory

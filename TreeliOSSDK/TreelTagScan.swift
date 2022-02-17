//
//  TreelTpmsScanning.swift
//  TreelB2CTPMSsdk
//
//  Created by Treel on 20/12/21.
//

import Foundation
import CoreLocation

public struct TreelTagScan{
    public static var shared: TreelTagScan?
    public var isBLEDetected = false
  
    var sensorDetectedData : [SensorDetectionEventDataModel] = []
    public static func initialize(){
      
        updateVehicleConfigurations()
        checkLocationServiceType()


       }
    
    public static func syncVehicleConfigurations(vehicleConfig : VehicleConfiguration){
        DBHelper.DBHelperShared.insertTireConfigData(vinNumber: vehicleConfig.vinNumber!, macAddress: vehicleConfig.macAddress!, tyrePosition: vehicleConfig.tyrePosition!, recommnededPressure: vehicleConfig.recommendedPressureSetPoint!, lowPressure: vehicleConfig.lowPressureSetPoint!, highPressure: vehicleConfig.highPressureSetPoint!, highTemp: vehicleConfig.highTemperatureSetPoint!, vehicleType: vehicleConfig.vehicleType! )
    }
  
    public static func syncVehicleConfigurations(vehicleConfiguration : Array<VehicleConfiguration>){
        for vehicleConfig in vehicleConfiguration{
            
            DBHelper.DBHelperShared.insertTireConfigData(vinNumber: vehicleConfig.vinNumber!, macAddress: vehicleConfig.macAddress!, tyrePosition: vehicleConfig.tyrePosition!, recommnededPressure: vehicleConfig.recommendedPressureSetPoint!, lowPressure: vehicleConfig.lowPressureSetPoint!, highPressure: vehicleConfig.highPressureSetPoint!, highTemp: vehicleConfig.highTemperatureSetPoint!, vehicleType: vehicleConfig.vehicleType! )
            
        }
       
    }
    
    public static func updateVehicleConfigurations(){
        
        BLEManager.sharedManager.updateVehicleConfigurations()
    }
    
    public static func checkLocationServiceType(){
        switch CLLocationManager.authorizationStatus() {
        case  .authorizedWhenInUse:
                print("Enable Location service as 'Always' from the Settings. This will enable the app to scan the sensors  in the background even though when the application is not opened.")
            break
        case .authorizedAlways:
               
            break
        default:
            break
        }
        
    }
    
    public static func deleteAllVehicleConfigurations (){
        DBHelper.DBHelperShared.deleteAllConfiguration()
        DBHelper.DBHelperShared.deleteAllSensorDetectionEvent()
        DBHelper.DBHelperShared.deleteAllAlerts()
        DBHelper.DBHelperShared.deleteAlltpmsDataHistory()
    }
    
    
    public static func fetchLatestTpmsData(vinNumber: String ,callback: ([TpmsDetectionData]?) -> Void) { 
        var tpmsDetectionDatas : [TpmsDetectionData] = []
        let sensorDetectionEvent = DBHelper.DBHelperShared.getSensorDetectionEventByVinNumber(vinNumber: vinNumber)
        
        for sensorDetection in sensorDetectionEvent! {
            let sensorData = sensorDetection.sensorData.split(separator: ",")
            var tpmsDetectionData = TpmsDetectionData(vinNumber: sensorDetection.vinNumber, macAddress: sensorDetection.macAddress, tyrePosition: sensorDetection.tirePosition!, pressure: Int(sensorData[0]), temperature: Int(sensorData[1]), battery: Int(sensorData[2]), timeStamp: sensorDetection.sensorDetectionTimestamp)

            tpmsDetectionDatas.append(tpmsDetectionData)
        }
        
        callback(tpmsDetectionDatas)
        
        }
    
    public static func fetchLatestTpmsData(vinNumber: [String] ,callback: ([TpmsDetectionData]?) -> Void) {
        var tpmsDetectionDatas : [TpmsDetectionData] = []
        let sensorDetectionEvent = DBHelper.DBHelperShared.getAllSensorDetectionEvent(vinNumber: vinNumber)
        
        for sensorDetection in sensorDetectionEvent! {
            let sensorData = sensorDetection.sensorData.split(separator: ",")
            var tpmsDetectionData = TpmsDetectionData(vinNumber: sensorDetection.vinNumber, macAddress: sensorDetection.macAddress, tyrePosition: sensorDetection.tirePosition!, pressure: Int(sensorData[0]), temperature: Int(sensorData[1]), battery: Int(sensorData[2]), timeStamp: sensorDetection.sensorDetectionTimestamp)

            tpmsDetectionDatas.append(tpmsDetectionData)
        }
        
        callback(tpmsDetectionDatas)
        
        }
    
    
}


extension Notification.Name {
  
    static let loadBLEData = Notification.Name("loadBLEData")
   
    
}

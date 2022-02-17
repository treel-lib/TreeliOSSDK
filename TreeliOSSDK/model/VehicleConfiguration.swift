    //
    //  VehicleConfiguration.swift
    //  demoFrame
    //
    //  Created by Treel on 10/12/21.


import Foundation
public class VehicleConfiguration: NSObject {
   
    public var configId: Int?
    public var vinNumber: String?
    public var macAddress: String?
    public var tyrePosition: String?
    public var recommendedPressureSetPoint: Int?
    public var lowPressureSetPoint : Int?
    public var highPressureSetPoint : Int?
    public var highTemperatureSetPoint :Int?
    public var tireReading: SensorDetectionModel?
    public var vehicleType: String?
    
   public init(configId: Int? = nil, vinNumber: String? = nil, macAddress: String? = nil, tyrePosition: String? = nil, recommendedPressureSetPoint: Int? = nil, lowPressureSetPoint: Int? = nil, highPressureSetPoint: Int? = nil, highTemperatureSetPoint: Int? = nil, tireReading: SensorDetectionModel? = nil, vehicleType: String? = nil) {
        self.configId = configId
        self.vinNumber = vinNumber
        self.macAddress = macAddress
        self.tyrePosition = tyrePosition
        self.recommendedPressureSetPoint = recommendedPressureSetPoint
        self.lowPressureSetPoint = lowPressureSetPoint
        self.highPressureSetPoint = highPressureSetPoint
        self.highTemperatureSetPoint = highTemperatureSetPoint
        self.tireReading = tireReading
        self.vehicleType = vehicleType
    }
 
    
//    public var configId: Int?
//    public var vinNumber: String?
//    public var macAddress: String?
//    public var tyrePosition: String?
//    public var highPressure: Int?
//    public var lowPressure: Int?
//    public var recommnededPressure: Int?
//    public var timeStamp: String?
//    public var highTemp: Int?
//
//    init(configId: Int? = nil, vinNumber: String? = nil, macAddress: String? = nil, tyrePosition: String? = nil, highPressure: Int? = nil, lowPressure: Int? = nil, recommnededPressure: Int? = nil, timeStamp: String? = nil, highTemp: Int? = nil) {
//        self.configId = configId
//        self.vinNumber = vinNumber
//        self.macAddress = macAddress
//        self.tyrePosition = tyrePosition
//        self.highPressure = highPressure
//        self.lowPressure = lowPressure
//        self.recommnededPressure = recommnededPressure
//        self.timeStamp = timeStamp
//        self.highTemp = highTemp
//    }
}


//public var macAddress: String!
//public var vinNumber:String!
//public var sensorData: String!
//public var sensorDetectionTimestamp: String!
//public var lowPressureDetectionTimestamp: String?
//public var highPressureDetectionTimestamp: String?
//public var highTemperatureDetectionTimestamp: String?
//public var tirePosition: String?
//public var dataType: String?
//
//public init(macAddress: String? = nil, vinNumber: String? = nil, sensorData: String? = nil, sensorDetectionTimestamp: String? = nil, lowPressureDetectionTimestamp: String? = nil, highPressureDetectionTimestamp: String? = nil, highTemperatureDetectionTimestamp: String? = nil, tirePosition: String? = nil, dataType: String? = nil) {
//    self.macAddress = macAddress
//    self.vinNumber = vinNumber
//    self.sensorData = sensorData
//    self.sensorDetectionTimestamp = sensorDetectionTimestamp
//    self.lowPressureDetectionTimestamp = lowPressureDetectionTimestamp
//    self.highPressureDetectionTimestamp = highPressureDetectionTimestamp
//    self.highTemperatureDetectionTimestamp = highTemperatureDetectionTimestamp
//    self.tirePosition = tirePosition
//    self.dataType = dataType
//}

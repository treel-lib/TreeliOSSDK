    //
    //  SensorDetectionEvent.swift
    //  demoFrame
    //
    //  Created by Treel on 10/12/21.
    //

import Foundation

public class SensorDetectionEvent: NSObject {
    
    
    public var macAddress: String!
    public var vinNumber:String!
    public var sensorData: String!
    public var sensorDetectionTimestamp: String!
    public var lowPressureDetectionTimestamp: String?
    public var highPressureDetectionTimestamp: String?
    public var highTemperatureDetectionTimestamp: String?
    public var tirePosition: String?
    public var dataType: String?
    
    
}


public class SensorDetectionEventDataModel: NSObject {
    
    var vehicleNo: String = ""
    var serverVehicleID: String = ""
    var vehicleType: String?
    
    var detectionTimeStamp: String?
    
    
}

public class SensorDetectionModel: NSObject {

    
    
    public var macAddress: String?
    public var pressure: String?
    public var temperature: String?
    public var battery: String?
    public var position: String?
    public var eventFlag: String?
    public var detectionTimeStamp: String?
    
    public init(macAddress: String? = nil, pressure: String? = nil, temperature: String? = nil, battery: String? = nil, position: String? = nil, eventFlag: String? = nil, detectionTimeStamp: String? = nil) {
        self.macAddress = macAddress
        self.pressure = pressure
        self.temperature = temperature
        self.battery = battery
        self.position = position
        self.eventFlag = eventFlag
        self.detectionTimeStamp = detectionTimeStamp
    }
    
    
}

//
//  TpmsDetectionData.swift
//  TreelB2CTPMSsdk
//
//  Created by Treel on 11/02/22.
//

import Foundation

public class TpmsDetectionData : NSObject {
 
    public var vinNumber: String?
    public var macAddress: String?
    public var tyrePosition: String?
    public var pressure: Int?
    public var temperature: Int?
    public var battery: Int?
    public var timeStamp: String?
    
    public init(vinNumber: String? = nil, macAddress: String? = nil, tyrePosition: String? = nil, pressure: Int? = nil, temperature: Int? = nil, battery: Int? = nil, timeStamp: String? = nil) {
        self.vinNumber = vinNumber
        self.macAddress = macAddress
        self.tyrePosition = tyrePosition
        self.pressure = pressure
        self.temperature = temperature
        self.battery = battery
        self.timeStamp = timeStamp
    }
}

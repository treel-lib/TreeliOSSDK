    //
    //  DetectedTreelTag.swift
    //  demoFrame
    //
    //  Created by Treel on 10/12/21.
    //

import Foundation
public class DetectedTreelTag: NSObject {
    
    
    public var macID = ""
    public var rssi = 0
    public var services : Array<String> = []
    public var temperature = ""
    public var pressure = ""
    public var battery = ""
    public var beaconElapsedTime = 0
    public var beaconTimer: Timer?
    public var dataType = ""
    public var vinNumber = ""
    public var tyrePosition = ""
    public var time : String = "-"
    public var dateTime : String = ""
    public var isLive : Bool = false
    
    init(macID: String = "", rssi: Int = 0, services: Array<String> = [], temperature: String = "", pressure: String = "", battery: String = "", beaconElapsedTime: Int = 0, beaconTimer: Timer? = nil, dataType: String = "", vinNumber: String = "", tyrePosition: String = "", time: String = "-", dateTime: String = "", isLive: Bool = false) {
        self.macID = macID
        self.rssi = rssi
        self.services = services
        self.temperature = temperature
        self.pressure = pressure
        self.battery = battery
        self.beaconElapsedTime = beaconElapsedTime
        self.beaconTimer = beaconTimer
        self.dataType = dataType
        self.vinNumber = vinNumber
        self.tyrePosition = tyrePosition
        self.time = time
        self.dateTime = dateTime
        self.isLive = isLive
    }
    
}

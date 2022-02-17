    //
    //  CommonExtension.swift
    //  TreelB2CTPMSsdk
    //
    //  Created by Treel on 21/12/21.
    //

import Foundation

extension Float {
    func getUnitValueForAlert(key: String, value: Float) -> String {
        switch key {
            case .PSI_U:
                return "\(self.getPsiValue(value: value)) PSI"
            case .BAR_U:
                let barValue = self.getBarValueWithoutRound(value: value)
                if barValue == 0 {
                    return "0 bar"
                }
                return String(format: "%.2f bar", barValue)
            case .KPA_U:
                let kpaValue = self.getKpaValue(value: value)
                return String(format: "%d kPa", kpaValue)
            case .C_U:
                return "\(self.getCeValue(value: value)) °C"
            case .F_U:
                let fValue = self.getFaValue(value: value)
                return String(format: "%d °F", fValue)
                
            default:
                break
        }
        
        return "--"
    }
    
        //Covert pound-force per square inch(psi)
    func getPsiValue(value: Float) -> Int {
        if value == 0{
            return 0
        }
        return Int(value.rounded())
    }
    
        //Covert pound-force per square inch(psi) To Bar(Bar)
    func getBarValue(value: Float) -> Float {
        if value == 0{
            return 0
        }
        let valueDouble = Double(value/14.504)
        return Float(valueDouble.rounded())
    }
    
        //Covert pound-force per square inch(psi) To Bar(Bar)
    func getBarValueWithoutRound(value: Float) -> Float {
        if value == 0{
            return 0
        }
        return (value/14.504)
    }
    
    func getBarToPSIValue(value: Float) -> Int {
        let valueDouble = Double(value * 14.504)
        return Int(valueDouble.rounded())
    }
    
    
        //Covert pound-force per square inch(psi) To Kilopascal(kpa)
    func getKpaValue(value: Float) -> Int {
        if value == 0{
            return 0
        }
        let valueDouble = Double(value * 6.895)
        return Int(valueDouble.rounded())
    }
    func getKpaToPSIValue(value: Float) -> Int {
        let valueDouble = Double(value / 6.895)
        return Int(valueDouble.rounded())
    }
    
        //Covert Celsius (°C) To Fahrenheit (°F)
        //    (0°C × 9/5) + 32 = 32°F
    func getFaValue(value: Float) -> Int {
        if value == 0{
            return 0
        }
        let valueDouble = Double((value * 9/5) + 32)
        return Int(valueDouble.rounded())
    }
    
    
        // Celsius (°C)
    func getCeValue(value: Float) -> Int {
        if value == 0{
            return 0
        }
        return Int(value.rounded())
    }
}

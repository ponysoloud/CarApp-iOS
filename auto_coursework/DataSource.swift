//
//  DataSource.swift
//  auto_coursework
//
//  Created by Александр Пономарев on 04.05.17.
//  Copyright © 2017 Alexander Ponomarev. All rights reserved.
//

import Foundation
import UIKit

class DataSource {
    
    public static var userCar = Car(mark: "", model: "")
    
    public static var consumption: Double?
    
    static func saveCar() {
        UserDefaults.standard.set(userCar.toDictionary(), forKey: "CurrentCar")
        UserDefaults.standard.synchronize()
    }
    
    static func removeCar() {
        userCar = Car(mark: "", model: "")
        UserDefaults.standard.removeObject(forKey: "CurrentCar")
        UserDefaults.standard.synchronize()
    }
    
    static func createCar(completion: @escaping ()->() = {}) {
        
        saveCar()
        
        loadCarIndex()
        loadCarInfo()
        loadCarStatus()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500), execute: {
            completion()
        })

    }
    
    static func loadCar(completion: @escaping ()->() = {}) -> Bool {
        
        if let json = UserDefaults.standard.value(forKey: "CurrentCar") as?  [String:Any]  {
            userCar = Car(json: json)
            recalcMean()
            
            loadCarIndex()
            loadCarInfo()
            loadCarStatus()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500), execute: {
                completion()
            })
            
            return true
        }
        return false
        /*
        let path = NSTemporaryDirectory() + "cars_library.txt"
        
        if FileHandle(forWritingAtPath: path) != nil {
            do {
                let readFile = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                var splitArray = readFile.components(separatedBy: ";")
                userCar = Car(mark: splitArray[0], model: splitArray[1])
                loadCarIndex()
                loadStatsFromFile()
                loadCarInfo()
            } catch  {
                return false
            }
        
            return true
        }
        
        return false
         */
    }
    
    static func loadCarStatus(completion: @escaping ()->() = {}) {
        guard let c = consumption else { return }
        
        DataManager.getCarStatus(mark: userCar.mark, model: userCar.model, consumption: c) { carStatus in
            userCar.status = carStatus
            saveCar()
            completion()
        }
    }
    
    static func loadCarIndex() {
        DataManager.getCarIndex(mark: userCar.mark, model: userCar.model) { carIndex in
            print(carIndex.meanConsumption)
            userCar.index = carIndex
            saveCar()
        }
    }
    
    static func loadCarInfo() {
        DataManager.getCarInfo(mark: userCar.mark, model: userCar.model) { car in
            userCar.descr = car.descr
            userCar.image = car.image
            saveCar()
        }
    }
    
    static func sendConsumption() {
        guard let c = consumption else { return }
        
        DataManager.sendConsumption(mark: userCar.mark, model: userCar.model, consumption: c) { carIndex in
            userCar.index = carIndex
            saveCar()
        }
    }
    
    static func addUserData(measurement: Measurement) {
        userCar.measurements.append(measurement)
        recalcMean()
        saveCar()
        sendConsumption()
        
        print("mean: \(consumption ?? -1)")
    }
    
    private static func recalcMean() {
        var cons = 0.0
        let mArr = userCar.measurements
        for (i, m) in mArr.enumerated() {
            if i == 0 { continue }
            let range = m.range - mArr[i - 1].range
            cons += (m.fuel / range) * 100
        }
        if mArr.count > 1 {
            cons /= Double(mArr.count - 1)
            consumption = cons
        }
    }
    /*
    static func addUserData(range: String, fueld: String) {
        let r = Double(range)!
        let f = Double(fueld)!
        evaluateConsumption(range: r, fueld: f)
        
        updateFiles(range: r)
    }
    */
    /*
    static func loadStatsFromFile() {
        let path = NSTemporaryDirectory() + "stats.txt"
        do {
            let readFile = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            var splitArray = readFile.components(separatedBy: ";")
            consumption = Double(splitArray[0]) ?? 0
            count = Double(splitArray[1]) ?? 0
        } catch  {
            print("error")
        }
    }
    
    static func getPreviousRangeFromFile() -> Double {
        let path = NSTemporaryDirectory() + "previous_range.txt"
        var previousRange: Double
        do {
            let readFile = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            previousRange = Double(readFile)!
            
            return previousRange
        } catch  {
            print("error")
        }
        
        return 0
    }
    
    @discardableResult static func evaluateConsumption(range: Double, fueld: Double) -> Double {
        let newConsumption = fueld/(range-getPreviousRangeFromFile())*100
        
        consumption = (consumption*count+newConsumption)/(count+1)
        count += 1
        
        DataManager.sendConsumption(mark: userCar.mark, model: userCar.model, consumption: consumption) { carIndex in
            userCar.index = carIndex
        }
        
        return consumption
    }
    
    static func updateFiles(range: Double) {
        let pathStats = NSTemporaryDirectory() + "stats.txt"
        
        let input = "\(Double((Int)(consumption * 10000))/10000.0);\(count)"
        print(consumption)
        do {
            try input.write(toFile: pathStats, atomically: false, encoding: String.Encoding.utf8)
        } catch  {
            print("error")
        }
        
        let pathRange = NSTemporaryDirectory() + "previous_range.txt"
        let inputRange = "\(range)"
        do {
            try inputRange.write(toFile: pathRange, atomically: false, encoding: String.Encoding.utf8)
        } catch  {
            print("error")
        }
    }
 */
    
}

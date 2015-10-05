//
//  Export.swift
//  Pods
//
//  Created by Michael Seemann on 02.10.15.
//
//

import Foundation
import HealthKit

public enum ExportError: ErrorType {
    case IllegalArgumentError(String)
}

public enum HealthDataToExportType : String {
    case ALL = "All"
    case ADDED_BY_THIS_APP = "Added by this app"
    case GENERATED_BY_THIS_APP = "Generated by this app"
    
    public static let allValues = [ALL, ADDED_BY_THIS_APP, GENERATED_BY_THIS_APP];
}

public typealias ExportCompletion = (NSError?) -> Void


class ExportOperation: NSOperation {
    
    var exportConfiguration: ExportConfiguration
    
    init(exportConfiguration: ExportConfiguration, healthStore: HKHealthStore, completionBlock: (() -> Void)? ){
        self.exportConfiguration = exportConfiguration
        super.init()
        self.completionBlock = completionBlock

    }
    
    override func main() {
        let jsonWriter = JsonWriter(outputStream: exportConfiguration.outputStream)
        jsonWriter.writeArrayStart()
        
        jsonWriter.writeArrayEnd()
    }
}

public struct ExportConfiguration {
    public var exportType = HealthDataToExportType.ALL
    public var profilName: String?
    public var outputStream: NSOutputStream
    
    public init(outputStream: NSOutputStream){
        self.outputStream = outputStream
    }
}

public class HealthKitDataExporter {
    
    public static let INSTANCE = HealthKitDataExporter()
    
    let exportQueue: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "export queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    let healthStore = HKHealthStore()
    
    let healthKitTypesToRead = Set(arrayLiteral:
        HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!,
        HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!,
        HKObjectType.workoutType()
    )

    
    init() { }
    
    public func export(exportConfiguration: ExportConfiguration, onCompletion: ExportCompletion) throws -> Void {
        if(exportConfiguration.outputStream.streamStatus != .Open){
            throw ExportError.IllegalArgumentError("the outputstream must be open")
        }
        
        let exporter = ExportOperation(exportConfiguration: exportConfiguration, healthStore: healthStore, completionBlock:{
            onCompletion(nil)
        })
        
        healthStore.requestAuthorizationToShareTypes(nil, readTypes: healthKitTypesToRead) {
            (success, error) -> Void in
            
            self.exportQueue.addOperation(exporter)
            
        }
    
    }
}

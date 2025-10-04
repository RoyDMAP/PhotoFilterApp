//
//  FilterService.swift
//  PhotoFilterApp
//
//  Created by Roy Dimapilis on 10/4/25.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

enum FilterType: CaseIterable {
    case none
    case sepia
    case noir
    case vintage
    case chrome
    case fade
    case instant
    case process
    case transfer
    case bloom
    case sharpen
    
    var displayName: String {
        switch self {
        case .none: return "None"
        case .sepia: return "Sepia"
        case .noir: return "Noir"
        case .vintage: return "Vintage"
        case .chrome: return "Chrome"
        case .fade: return "Fade"
        case .instant: return "Instant"
        case .process: return "Process"
        case .transfer: return "Transfer"
        case .bloom: return "Bloom"
        case .sharpen: return "Sharpen"
        }
    }
}

class FilterService {
    static let context = CIContext()
    
    static func applyFilter(to image: UIImage, filterType: FilterType, intensity: Double) -> UIImage? {
        guard let inputImage = CIImage(image: image) else { return nil }
        
        var outputImage: CIImage?
        
        switch filterType {
        case .none:
            return image
            
        case .sepia:
            let filter = CIFilter.sepiaTone()
            filter.inputImage = inputImage
            filter.intensity = Float(intensity)
            outputImage = filter.outputImage
            
        case .noir:
            let filter = CIFilter.photoEffectNoir()
            filter.inputImage = inputImage
            outputImage = filter.outputImage
            
        case .vintage:
            let filter = CIFilter.photoEffectTransfer()
            filter.inputImage = inputImage
            outputImage = filter.outputImage
            
        case .chrome:
            let filter = CIFilter.photoEffectChrome()
            filter.inputImage = inputImage
            outputImage = filter.outputImage
            
        case .fade:
            let filter = CIFilter.photoEffectFade()
            filter.inputImage = inputImage
            outputImage = filter.outputImage
            
        case .instant:
            let filter = CIFilter.photoEffectInstant()
            filter.inputImage = inputImage
            outputImage = filter.outputImage
            
        case .process:
            let filter = CIFilter.photoEffectProcess()
            filter.inputImage = inputImage
            outputImage = filter.outputImage
            
        case .transfer:
            let filter = CIFilter.photoEffectTransfer()
            filter.inputImage = inputImage
            outputImage = filter.outputImage
            
        case .bloom:
            let filter = CIFilter.bloom()
            filter.inputImage = inputImage
            filter.intensity = Float(intensity)
            filter.radius = Float(10 * intensity)
            outputImage = filter.outputImage
            
        case .sharpen:
            let filter = CIFilter.sharpenLuminance()
            filter.inputImage = inputImage
            filter.sharpness = Float(intensity * 2)
            outputImage = filter.outputImage
        }
        
        guard let finalOutput = outputImage else { return nil }
        
        // Apply intensity blending for filters that don't have native intensity
        if filterType != .sepia && filterType != .bloom && filterType != .sharpen {
            if intensity < 1.0 {
                let blendFilter = CIFilter.sourceOverCompositing()
                blendFilter.inputImage = finalOutput
                blendFilter.backgroundImage = inputImage
                
                if let blended = blendFilter.outputImage {
                    let colorFilter = CIFilter.colorMatrix()
                    colorFilter.inputImage = blended
                    colorFilter.aVector = CIVector(x: 0, y: 0, z: 0, w: CGFloat(intensity))
                    outputImage = colorFilter.outputImage
                } else {
                    outputImage = finalOutput
                }
            } else {
                outputImage = finalOutput
            }
        } else {
            outputImage = finalOutput
        }
        
        guard let output = outputImage,
              let cgImage = context.createCGImage(output, from: output.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

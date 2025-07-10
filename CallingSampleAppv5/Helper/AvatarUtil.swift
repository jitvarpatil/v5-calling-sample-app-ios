//
//  AvatarUtil;.swift
//  CallingSampleAppv5
//
//  Created by Suryansh on 13/06/25.
//

import UIKit

public class AvatarUtils {
    
    public static func setImageSnap(
        text: String?,
        color: UIColor,
        textAttributes: [NSAttributedString.Key: Any],
        view: UIImageView
    ) -> UIImage? {
        guard view.bounds.size.width > 0 && view.bounds.size.height > 0 else { return nil }
        
        let scale = Float(UIScreen.main.scale)
        var size = view.bounds.size
        if view.contentMode == .scaleToFill || view.contentMode == .scaleAspectFill || view.contentMode == .scaleAspectFit || view.contentMode == .redraw {
            size.width = CGFloat(floorf((Float(size.width) * scale) / scale))
            size.height = CGFloat(floorf((Float(size.height) * scale) / scale))
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, CGFloat(scale))
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let attributes = textAttributes
        
        // Text
        if let text = text?.initials.uppercased() {
            let textSize = text.size(withAttributes: attributes)
            let bounds = view.bounds
            let rect = CGRect(x: bounds.size.width/2 - textSize.width/2, y: bounds.size.height/2 - textSize.height/2, width: textSize.width, height: textSize.height)
            
            text.draw(in: rect, withAttributes: attributes)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}


extension UIImageView {
    static func downloaded(from url: URL, completion: ((_ image: UIImage?) -> Void)?) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else {
                DispatchQueue.main.async() {
                    completion?(nil)
                }
                return
            }
            DispatchQueue.main.async() {
                completion?(image)
            }
        }.resume()
    }
}

extension String {
    
    var initials: String {
        
        let words = components(separatedBy: .whitespacesAndNewlines)
        
        //to identify letters
        let letters = CharacterSet.alphanumerics
        var firstChar : String = ""
        var secondChar : String = ""
        var firstCharFoundIndex : Int = -1
        var firstCharFound : Bool = false
        var secondCharFound : Bool = false
        
        for (index, item) in words.enumerated() {
            
            if item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }
            
            //browse through the rest of the word
            for (_, char) in item.unicodeScalars.enumerated() {
                
                //check if its a aplha
                if letters.contains(char) {
                    
                    if !firstCharFound {
                        firstChar = String(char)
                        firstCharFound = true
                        firstCharFoundIndex = index
                        
                    } else if !secondCharFound {
                        
                        secondChar = String(char)
                        if firstCharFoundIndex != index {
                            secondCharFound = true
                        }
                        
                        break
                    } else {
                        break
                    }
                }
            }
        }
        if firstChar.isEmpty && secondChar.isEmpty {
            firstChar = "\(self.first ?? "?")"
        }
        return firstChar + secondChar
    }
}

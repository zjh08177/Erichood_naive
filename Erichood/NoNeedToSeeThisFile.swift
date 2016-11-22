//
//  NoNeedToSeeThisFile.swift
//  Erichood
//
//  Created by Jiahao Zhang on 11/21/16.
//  Copyright © 2016 Jiahao Zhang. All rights reserved.
//

import Foundation
func getStocks() {
    if let url = NSURL(string: "ftp://ftp.nasdaqtrader.com/SymbolDirectory/nasdaqlisted.txt") {
        let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                let urlContent = NSString(data: data!, encoding: NSASCIIStringEncoding) as String!
                
                var fragment = urlContent
                
                while fragment.characters.count > 1 {
                    fragment = fragment.substringFromIndex(fragment.rangeOfString("\n")!.endIndex)
                    let stock = fragment.substringToIndex(fragment.rangeOfString("|")!.startIndex)
                    //self.stocks.append(stock)
                }
                
                if let url2 = NSURL(string: "ftp://ftp.nasdaqtrader.com/SymbolDirectory/otherlisted.txt") {
                    let task2 = NSURLSession.sharedSession().dataTaskWithURL(url2, completionHandler: { (data, response, error) in
                        if error != nil {
                            print(error?.localizedDescription)
                        } else {
                            let urlContent = NSString(data: data!, encoding: NSASCIIStringEncoding) as String!
                            
                            var fragment = urlContent
                            
                            while fragment.characters.count > 1 {
                                fragment = fragment.substringFromIndex(fragment.rangeOfString("\n")!.endIndex)
                                let stock = fragment.substringToIndex(fragment.rangeOfString("|")!.startIndex)
                                //self.stocks.append(stock)
                            }
                        }
                    })
                    task2.resume()
                }
            }
        })
        task.resume()
    }
}

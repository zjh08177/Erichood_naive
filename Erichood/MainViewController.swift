//
//  MainViewController.swift
//  Erichood
//
//  Created by Jiahao Zhang on 11/19/16.
//  Copyright © 2016 Jiahao Zhang. All rights reserved.
//

import UIKit
import Alamofire

class MainViewController: UIViewController, UIWebViewDelegate {
    
    var stockInput: TextInput!
    var searchButton: Button!
    var topchartOpinion: TextLabel!
    var webview: UIWebView!
    var stocks = [String] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stockInput = TextInput(frame: CGRect(x: 40, y: 80, width: 150, height: 50), textInputName: "")
        searchButton = Button(frame: CGRect(x: 200, y: 80, width: 80, height: 50), buttonTitle: "Search", target: self, action: #selector(didTapSearchButton))
        
        self.view.addSubview(stockInput)
        self.view.addSubview(searchButton)
        // Do any additional setup after loading the view, typically from a nib.
        loadStocks()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadStocks() {
        var thisFile = file
        while thisFile.containsString(">>") {
            let stock = thisFile.substringToIndex(thisFile.rangeOfString(">>")!.startIndex)
            stocks.append(stock)
            thisFile = thisFile.substringFromIndex(thisFile.rangeOfString(">>")!.endIndex)
        }
        //print(stocks)
        for stockName in stocks {
           getBarchartStockAnalysis(stockName, completionHandler: { (opinion) in
            if opinion.containsString("Buy") {
                let ratio = (opinion.substringToIndex(opinion.rangeOfString("%")!.startIndex) as NSString).intValue
                if ratio > 90 {
                    self.getMarketwatchStockAnalysis(stockName, completionHandler: { (opinion2) in
                        if opinion2 == "ERROR" {
                            print("\(stockName): NA")
                        } else {
                            let num = (opinion2 as NSString).floatValue
                            if num > 80 {
                                //print("\(stockName): \(opinion) \(num)")
                                print(stockName)
                            }
                            
                        }
                    })
                }
                
            }
           })
        }
    }
    
    func didTapSearchButton(sender: UIButton) {
        for stockName in stocks {
            let barchartOpinion = getBarchartStockAnalysis(stockName)
            if barchartOpinion.containsString("Buy") {
                print("\(stockName): \(barchartOpinion)")
            }
        }
        
    }
    
    func urlToBarchart(stockName: String?) -> NSURL? {
        if let name = stockName {
            let urlString = "https://www.barchart.com/stocks/quotes/" + name + "/overview"
            return NSURL(string: urlString)
        } else {
            return nil
        }
    }
    
    func urlToZack(stockName: String?) -> NSURL? {
        if let name = stockName {
            let urlString = "https://www.zacks.com/stock/quote/" + name + "?q=" + name
            return NSURL(string: urlString)
        } else {
            return nil
        }
    }
    
    func urlToMarketwatch(stockName: String?) -> NSURL? {
        if let name = stockName {
            let urlString = "http://www.marketwatch.com/investing/Stock/" + name + "?countrycode=US"
            return NSURL(string: urlString)
        } else {
            return nil
        }

    }
    
    func getBarchartStockAnalysis(stockName: String, completionHandler: ((String) -> Void)) {
        if let url = urlToBarchart(stockName) {
            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    let urlContent = NSString(data: data!, encoding: NSASCIIStringEncoding) as String!
                    let s1 = " rating is a <b>"
                    let s2 = "</b>"
                    if let range = urlContent.rangeOfString(s1) {
                        let opinion = urlContent.substringWithRange(Range<String.Index>(start: range.endIndex, end: urlContent.rangeOfString(s2)!.startIndex))
                        completionHandler(opinion)
                    } else {
                        completionHandler("ERROR")
                    }
                }
            })
            task.resume()
        }
    }
    
    func getBarchartStockAnalysis(stockName: String) -> String {
        var opinion = "ERROR"
        if let url = urlToBarchart(stockName) {
            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    let urlContent = NSString(data: data!, encoding: NSASCIIStringEncoding) as String!
                    let s1 = " rating is a <b>"
                    let s2 = "</b>"
                    if let range = urlContent.rangeOfString(s1) {
                        opinion = urlContent.substringWithRange(Range<String.Index>(start: range.endIndex, end: urlContent.rangeOfString(s2)!.startIndex))
                    }
                }
            })
            task.resume()
        }
        return opinion
    }
    
    func getMarketwatchStockAnalysis(stockName: String, completionHandler: ((String) -> Void)) {
        if let url = urlToMarketwatch(stockName) {
            let request = NSMutableURLRequest(URL: url)
            let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36"
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    let urlContent = NSString(data: data!, encoding: NSASCIIStringEncoding) as String!
                    let s1 = "\"sentiment \" style=\"left: "
                    if let range = urlContent.rangeOfString(s1) {
                        var opinion = urlContent.substringFromIndex(range.endIndex)
                        opinion = opinion.substringToIndex(opinion.rangeOfString("%;")!.startIndex)
                        //let opinion = urlContent.substringWithRange(Range<String.Index>(start: range.endIndex, end: urlContent.rangeOfString("%")!.startIndex))
                        completionHandler(opinion)
                    } else {
                        completionHandler("ERROR")
                    }
                }
            })
            task.resume()
            /*
            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    let urlContent = NSString(data: data!, encoding: NSASCIIStringEncoding) as String!
                    let s1 = "Sentiment on "
                    let s2 = "<div id=\"analystsentiment\" class=\"sentiment \" style=\"left: "
                    if urlContent.rangeOfString(s1) != nil {
                        if let range = urlContent.rangeOfString(s2) {
                            let opinion = urlContent.substringWithRange(Range<String.Index>(start: range.endIndex, end: urlContent.rangeOfString("%")!.startIndex))
                            completionHandler(opinion)
                        }
                    } else {
                        completionHandler("ERROR")
                    }
                }
            })
            task.resume()*/
        }
    }
    
    func getZackStockAnalysis(stockName: String) {
        if let url = urlToZack(stockName) {
            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    var urlContent = NSString(data: data!, encoding: NSASCIIStringEncoding) as String!
                    let s1 = "<div class=\"zr_rankbox\">\n"
                    urlContent = urlContent.substringFromIndex(urlContent.rangeOfString(s1)!.endIndex)
                    urlContent = urlContent.substringFromIndex(urlContent.rangeOfString(s1)!.endIndex)
                    let s2 = "<span class=\"rank_chip rankrect_1\">"
                    if let range = urlContent.rangeOfString(s2) {
                        var opinion = urlContent.substringToIndex(range.startIndex)
                        opinion = opinion.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        print("Zack: \(opinion)")
                    } else {
                        print("Zack: NA")
                    }
                    
                }
            })
            task.resume()
        }
    }
    
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
                        self.stocks.append(stock)
                    }
                    print("finished!!!!!!!!!")
                    
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
                                    self.stocks.append(stock)
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
}


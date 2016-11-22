//
//  MainViewController.swift
//  Erichood
//
//  Created by Jiahao Zhang on 11/19/16.
//  Copyright © 2016 Jiahao Zhang. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import JavaScriptCore

class MainViewController: UIViewController, UIWebViewDelegate {
    
    var stockInput: TextInput!
    var searchButton: Button!
    var topchartOpinion: TextLabel!
    var stocks = [String] ()
    var stockAnalysis = [String] ()
    var p: String!
    var count: Int = 0
    var c: Int = 0
    dynamic var check = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stockInput = TextInput(frame: CGRect(x: 40, y: 80, width: 150, height: 50), textInputName: "")
        searchButton = Button(frame: CGRect(x: 200, y: 80, width: 80, height: 50), buttonTitle: "Search", target: self, action: #selector(didTapSearchButton))
        
        self.view.addSubview(stockInput)
        self.view.addSubview(searchButton)

        self.addObserver(self, forKeyPath: "check", options: .New, context: nil)
        
        loadStocks()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        

        var name: String = ""
        var rating: Double = 5
        var targetPrice: Double
        var currentPrice: Double
        if let range = check.rangeOfString("<title>") {
            var cut = check.substringFromIndex(range.endIndex)
            cut = cut.substringToIndex(cut.rangeOfString(" :")!.startIndex)
            name = cut
            //print(cut)
        }
        if let range = check.rangeOfString("$main-0-Quote.2.1.$ratings.1.0.1\">") {
            var cut = check.substringFromIndex(range.endIndex)
            cut = cut.substringToIndex(cut.rangeOfString("</div>")!.startIndex)
            rating = (cut as NSString).doubleValue
            //print(cut)
        }
        
        if let range = check.rangeOfString("$price-targets.$slider.3.0.2\">") {
            var cut = check.substringFromIndex(range.endIndex)
            cut = cut.substringToIndex(cut.rangeOfString("<")!.startIndex)
            targetPrice = (cut as NSString).doubleValue
            //print(cut)
        }
        
        if let range = check.rangeOfString("$main-0-Quote.0.1.0.$price.0\">") {
            var cut = check.substringFromIndex(range.endIndex)
            cut = cut.substringToIndex(cut.rangeOfString("<")!.startIndex)
            currentPrice = (cut as NSString).doubleValue
            //print(cut)
        }
        if (rating > 2.5) {
            //c = c + 1
            return
        }
        getZackStockAnalysis(name, completionHandler: { (o1) in
            var zackRating: Int32 = 0
            if o1 != "NA" {
                zackRating = (o1.substringToIndex(o1.rangeOfString("-")!.startIndex) as NSString).intValue
                if zackRating > 2 {
                    //self.c = self.c + 1
                    return
                }
            }
            self.getBarchartStockAnalysis(name, completionHandler: { (o2) in
                var barchartRating: Int32 = 0
                if !o2.containsString("Buy") && o2 != "NA" {
                    //self.c = self.c + 1
                    return
                }
                barchartRating = (o2.substringToIndex(o2.rangeOfString("%")!.startIndex) as NSString).intValue
                self.getMarketwatchStockAnalysis(name, completionHandler: { (o3) in
                    var marketwatchRating: Int32 = 0
                    if o3 != "NA" {
                        marketwatchRating = (o3 as NSString).intValue
                        if marketwatchRating < 60 {
                            //self.c = self.c + 1
                            return
                        }
                    }
                    let analysis = "\(name): \(rating) || \(zackRating) || \(barchartRating) || \(marketwatchRating)"
                    print(analysis)
                    self.stockAnalysis.append(analysis)
                    //self.c = self.c + 1
                })
            })
        })
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        p = webView.stringByEvaluatingJavaScriptFromString("document.documentElement.innerHTML")
        if let range = p.rangeOfString("rating-text") {
            check = p
            //this func is called multiple times and only at the last time we got the correct html, so use key-value observer.
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadStocks() {
        var thisFile = currentHold
        while thisFile.containsString(" ") {
            let stock = thisFile.substringToIndex(thisFile.rangeOfString(" ")!.startIndex)
            stocks.append(stock)
            thisFile = thisFile.substringFromIndex(thisFile.rangeOfString(" ")!.endIndex)
        }
        print(stocks)
    }
    
    func didTapSearchButton(sender: UIButton) {
        print(stockAnalysis)

        if c >= stocks.count {
            return
        }
        getYahooStockAnalysis(stocks[c])
        c = c + 1
        
        /* want to use the follow loop
        for stock in stocks {
            getYahooStockAnalysis(stock)
        }
        */
    }
    
    //MARK: get URL from website
    
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
    
    func urlToYahoo(stockName: String?) -> NSURL? {
        if let name = stockName {
            let urlString = "https://finance.yahoo.com/quote/" + name + "?ltr=1"
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
                        completionHandler("NA")
                    }
                }
            })
            task.resume()
        }
    }
    
    // get Analysis from website
    
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
                        completionHandler("NA")
                    }
                }
            })
            task.resume()
        }
    }
    
    func getZackStockAnalysis(stockName: String, completionHandler: ((String) -> Void)) {
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
                        completionHandler(opinion)
                    } else {
                        completionHandler("NA")
                    }
                    
                }
            })
            task.resume()
        }
    }
    
    func getYahooStockAnalysis(stockName: String) {
        if let url = urlToYahoo(stockName) {
            let page = try! String(contentsOfURL: url)
            
            if let range = page.rangeOfString("(function (root)") {
                var jsScript = page.substringFromIndex(range.startIndex)
                jsScript = jsScript.substringToIndex(jsScript.rangeOfString("(this));")!.endIndex)
                
                var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as NSString
                
                let fileName = NSUUID().UUIDString
                path = path.stringByAppendingPathComponent("\(fileName).js")
                try! jsScript.writeToFile(path as String, atomically: true, encoding: NSUTF8StringEncoding)
                
                let jsURL = NSURL(fileURLWithPath: path as String)
                
                let web = UIWebView(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
                web.delegate = self
                
                web.loadHTMLString(page, baseURL: jsURL)
                //try! NSFileManager.defaultManager().removeItemAtURL(jsURL)
                self.view.addSubview(web)
            }
            
        }
    }
    
    
    
}


//
//  LineGraphViewController.swift
//  mHealth
//
//  Created by Loaner on 4/3/17.
//  Copyright © 2017 JTMax. All rights reserved.
//
//RAW DESCRIPTION
//THIS ONLY DISPLAYS THE STATS FOR THE DISTANCE RAN. I WANT TO LOAD THE DATA FROM FIREBASE BUT IM HAVING A BIT OF TROUBLE. TRAVIS MUST INSTALL A POD TO VIEW THE GRAPHS: pod ‘JBChartView’

import Foundation
import UIKit
import JBChartView
import Firebase

class LineGraphViewController: UIViewController, JBLineChartViewDelegate, JBLineChartViewDataSource {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var lineChart: JBLineChartView!
    @IBOutlet weak var informationLabel: UILabel!
    
    let user = FIRAuth.auth()?.currentUser
    let rootRef = FIRDatabase.database().reference()
    
    //MARK: Array of Runs
    var runs = [FirebaseRun]()
    
    //RANDOM NUMBERS TO DISPLAY GRAPH
    var chartLegend = ["03-14", "03-15", "03-16", "03-17", "03-18", "03-19", "03-20"]
    var chartData = [700, 800, 760, 880, 900, 690, 740]
    //var lastYearChartData = [75, 88, 79, 95, 72, 55, 90]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor.darkGray
        
        // line chart setup
        lineChart.backgroundColor = UIColor.darkGray
        lineChart.delegate = self
        lineChart.dataSource = self
        lineChart.minimumValue = 55
        lineChart.maximumValue = 100
        
        lineChart.reloadData()
        
        lineChart.setState(.collapsed, animated: false)
        
        //MARK: FIREBASE start up
        let id: String = Util.removePeriod(s: (user?.email)!)
        let runRef = FIRDatabase.database().reference(withPath: "users//\(id)/")
        
        runRef.observe(.value, with: { snapshot in
            self.load()
            self.lineChart.reloadData()
        })
        print(distanceArray())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: lineChart.frame.width, height: 16))
        
        //printviewDidLoad;:  (lineChart.frame.width)")
        
        let footer1 = UILabel(frame: CGRect(x: 0, y: 0, width: lineChart.frame.width/2 - 8, height: 16))
        footer1.textColor = UIColor.white
        footer1.text = "\(chartLegend[0])"
        
        let footer2 = UILabel(frame: CGRect(x: lineChart.frame.width/2 - 8, y: 0, width: lineChart.frame.width/2 - 8, height: 16))
        footer2.textColor = UIColor.white
        footer2.text = "\(chartLegend[chartLegend.count - 1])"
        footer2.textAlignment = NSTextAlignment.right
        
        footerView.addSubview(footer1)
        footerView.addSubview(footer2)
        
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: lineChart.frame.width, height: 50))
        header.textColor = UIColor.white
        header.font = UIFont.systemFont(ofSize: 24)
        header.text = "Stats for my runs"
        header.textAlignment = NSTextAlignment.center
        
        lineChart.footerView = footerView
        lineChart.headerView = header
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // RELOAD DATA PLS ;)
        lineChart.reloadData()
        
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(LineGraphViewController.showChart), userInfo: nil, repeats: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hideChart()
    }
    
    func hideChart() {
        lineChart.setState(.collapsed, animated: true)
    }
    
    func showChart() {
        lineChart.setState(.expanded, animated: true)
    }
    
    // MARK: JBlineChartView
    
    func numberOfLines(in lineChartView: JBLineChartView!) -> UInt {
        return 1
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
            return UInt(chartData.count)
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
            return CGFloat(chartData[Int(horizontalIndex)])
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.lightGray
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, showsDotsForLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, colorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.lightGray
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return false
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, didSelectLineAt lineIndex: UInt, horizontalIndex: UInt) {
            let data = chartData[Int(horizontalIndex)]
            let key = chartLegend[Int(horizontalIndex)]
            informationLabel.text = "Run on \(key): \(data)"
    }
    
    func didDeselectLine(in lineChartView: JBLineChartView!) {
        informationLabel.text = ""
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, fillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        
        return UIColor.clear
    }
        //HAVING TROUBLE LOADING THE DATA PLS HELP
    private func load(){
        let id: String = Util.removePeriod(s: (user?.email)!)
        let runRef = FIRDatabase.database().reference(withPath: "users//\(id)/Runs/")
        
        
        runRef.observe(.value, with: { snapshot in
            var currentRuns = [FirebaseRun]()
            //var distanceRuns = [String]()
            for run in snapshot.children{
                let oldRun = FirebaseRun(snapshot: run as! FIRDataSnapshot)
                currentRuns.append(oldRun)
                //distanceRuns.append(String((oldRun.distnce)),
            }
            self.runs = currentRuns;
            self.lineChart.reloadData()
        })
        
        //cell.dateLabel.text = Util.dateFirebaseTitle(date: Util.stringToDate(date: run.timestamp))
        //cell.timeLabel.text = Util.dateToPinString(date: Util.stringToDate(date: run.timestamps.last!))
    }
    
    func distanceArray() -> Array<String>{
        var distanceRuns = [String]()
        for dist in runs{
            distanceRuns.append(String(dist.distance))
        }
        return distanceRuns
    }

    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

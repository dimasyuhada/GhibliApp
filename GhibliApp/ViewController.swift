//
//  ViewController.swift
//  GhibliApp
//
//  Created by macuser on 28/06/2021.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnPicker: UIButton!
    private let apiRepo = Repository()
    private var disposeBag = DisposeBag()
    
    var ghibli: GhibliStats?
    var ghibliList = [GhibliStats]()
    var sortedList = [GhibliStats]()
    var yearList : [String] = ["Semua"]
    var pickedGhibli: GhibliStats?
    
    let screenWidth = UIScreen.main.bounds.width - 10
    let screenHeight = UIScreen.main.bounds.height / 2
    var selectedRow = 0
    
    var dataSource = BehaviorRelay(value: [GhibliStats]())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(GhibliTableViewCell.nib(), forCellReuseIdentifier: GhibliTableViewCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = nil
        
//        getDataByRx()
        
        getJSON{
            print("Success!")
            self.tableView.reloadData()
        };
        
    }
    
    //request by Rx
    func getDataByRx(){
        let reposObservable = apiRepo.getRepos().share()
        
        reposObservable.map { repos -> [GhibliStats] in
            for index in 0..<repos.count{
                self.ghibliList.append(repos[index])
                let year = repos[index].release_date
                self.yearList.append(year)
            }
            self.sortedList = self.ghibliList
            self.yearList = self.yearList.uniqued()
            return self.sortedList
        }.bind(to: tableView.rx.items) { (tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: GhibliTableViewCell.identifier) as! GhibliTableViewCell
            cell.configure(with: element)
            return cell
        }
        
    }
    
    func getJSON(completed: @escaping() -> ()){
        let url = URL (string: "https://ghibliapi.herokuapp.com/films")
        URLSession.shared.dataTask(with: url!) { (data,response,error) in
            if error == nil {
                do{
                    self.ghibliList = try JSONDecoder().decode([GhibliStats].self, from: data!)
                    self.sortedList = self.ghibliList
                    for index in self.ghibliList{
                        self.ghibli = index
                        let year = self.ghibli!.release_date
                        self.yearList.append(year)
                    }
                    let result = self.yearList.uniqued()
                    print("hasilnya : \(result)")

                    DispatchQueue.main.async {
                        completed()
                    }
                }catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }
            }
        }.resume()
    }
    
    @IBAction func selectYear(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerView.selectRow(selectedRow, inComponent: 0, animated: true)
        
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "Select Release Year", message: nil, preferredStyle: .actionSheet)
        
        alert.popoverPresentationController?.sourceView = btnPicker
        alert.popoverPresentationController?.sourceRect = btnPicker.bounds
        
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: {
            (UIAlertAction) in
            self.selectedRow = pickerView.selectedRow(inComponent: 0)
            let selected = Array(self.yearList)[self.selectedRow]
            self.btnPicker.setTitle(selected, for: .normal)
            
            if self.selectedRow==0 {
                self.sortedList = self.ghibliList
            }else{
                self.sortedList.removeAll()
                for i in 0..<self.ghibliList.count{
                    if selected == self.ghibliList[i].release_date {
                        self.sortedList.append(self.ghibliList[i])
                    }
                }
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (UIAlertAction) in
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // table set
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GhibliTableViewCell.identifier, for: indexPath) as! GhibliTableViewCell
        cell.configure(with: sortedList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("clicked \(indexPath.row)")
        
        pickedGhibli = sortedList[(indexPath.row)]
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToDetails", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetails"{
            let vc = segue.destination as! DetailsViewController
            vc.detailGhibli = pickedGhibli
        }else {
            print("check again")
        }
    }
    
    //picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        label.text = Array(yearList)[row]
        label.sizeToFit()
        
        return label
    }
}

class Repository{
    private let networkService = NetworkService()
    private let baseUrl = "https://ghibliapi.herokuapp.com"
    
    func getRepos() -> Observable<[GhibliStats]>{
        return networkService.execute(url: URL(string: baseUrl + "/films")!)
    }
    
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}


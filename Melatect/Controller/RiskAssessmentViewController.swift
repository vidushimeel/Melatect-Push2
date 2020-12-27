//
//  ProfileViewController.swift
//  MoleScan
//
//  Created by Asritha Bodepudi on 11/18/20.
//


//MAKE CODE CLEANER TO INHERITENCE
import UIKit
import SideMenu

protocol updateTableViewProtocol: class {
    func updateTableView()
}

protocol calculateAndDisplayRiskProtocol: class {
    func calculateRisk()
}

protocol displayRaceWarningAlertProtocol: class {
    func displayRaceWarningAlert()
}
class RiskAssessmentViewController: UIViewController, updateTableViewProtocol, calculateAndDisplayRiskProtocol, displayRaceWarningAlertProtocol {
    func displayRaceWarningAlert() {
        let alert = UIAlertController(title: "Data on non-caucasian people is sparse", message: "As a result, this tool can only accurately calculate melanoma risk for caucasian patients.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        self.present(alert, animated: true)
    }

    let defaults = UserDefaults.standard
    var menu = UISideMenuNavigationController(rootViewController: SideMenuViewController())

    @IBOutlet weak var riskAssessmentTableView: UITableView!
    @IBOutlet weak var riskAssessmentDisplayTextView: UILabel!
    @IBOutlet weak var riskAssessmentDisplayBackgroundBoxView: UIView!
    @IBOutlet weak var riskAssessmentDisplaySubTextView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        riskAssessmentTableView.dataSource = self
        riskAssessmentTableView.separatorStyle = .none
        riskAssessmentDisplayBackgroundBoxView.layer.cornerRadius = 15
        
        if defaults.integer(forKey: "AgeBothTableViewCell")  == 0{
            defaults.set(20, forKey: "AgeBothTableViewCell")
        }
        calculateRisk()
        menu.leftSide = true
        SideMenuManager.default.menuLeftNavigationController = menu
        SideMenuManager.default.menuFadeStatusBar = false
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.9488552213, green: 0.9487094283, blue: 0.9693081975, alpha: 1)
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    @IBAction func openSideMenuButtonPressed(_ sender: UIButton) {
        present(menu, animated: true)
        navigationController?.navigationBar.barStyle = .default
    }
    
    func updateTableView() {
        riskAssessmentTableView.reloadData() // you do have an outlet of tableView I assume
    }
    
    func calculateRisk(){
        var r:Double = 1
        let age:Double = Double(defaults.integer(forKey: "AgeBothTableViewCell"))

        if defaults.integer(forKey: "GenderBothTableViewCell") == 0{ //male
            r *= MratConstants().SUNBURN[Int(Double(defaults.integer(forKey: "HistoryOfSunburnMaleTableViewCell")))]
            r *= MratConstants().MALE_COMPLEXION[Int(defaults.integer(forKey: "ComplexionBothTableViewCell"))]
            r *= MratConstants().BIG_MOLES[Int(defaults.integer(forKey: "MolesLargerThan5mmMaleTableViewCell"))]
            r *= MratConstants().MALE_SMALL_MOLES[Int(defaults.integer(forKey: "MolesLessThan5mmBothTableViewCell"))]
            r *= MratConstants().MALE_FRECKLING[Int(defaults.integer(forKey: "ExtensiveFrecklingBothTableViewCell"))]
            r *= MratConstants().DAMAGE[(defaults.integer(forKey: "SevereSolarDamageMaleTableViewCell"))]
        }
        else{ //female
            r *=  MratConstants().TAN[(defaults.integer(forKey: "ExposureToSunlightFemaleTableViewCell"))]
            r *= MratConstants().FEMALE_COMPLEXION[(defaults.integer(forKey: "ComplexionBothTableViewCell"))]
            r *= MratConstants().FEMALE_SMALL_MOLES[(defaults.integer(forKey: "MolesLessThan5mmBothTableViewCell"))]
            r *= MratConstants().FEMALE_FRECKLING[Int(defaults.integer(forKey: "ExtensiveFrecklingBothTableViewCell"))]
        }
        let ageIndex = Int((age-20)/5)
        let t1:Double = Double(ageIndex*5+20)
        let t2: Double = t1+5

      
       let h11 = MratConstants().SEX[defaults.integer(forKey: "GenderBothTableViewCell")] * MratConstants().INCIDENCE[defaults.integer(forKey: "GenderBothTableViewCell")][ageIndex][defaults.integer(forKey: "RegionBothTableViewCell")]

        let h21 = MratConstants().MORTALITY[defaults.integer(forKey: "GenderBothTableViewCell")][ageIndex]

        let firstRisk: Double = (h11*Double(r)+h21)
        let secondRisk: Double = (Double(age)-Double(t2))
        let thirdRisk: Double = (1-exp(secondRisk*firstRisk))
        let fourthRisk: Double = thirdRisk/(h11*Double(r)+h21)
        var risk = h11*r*fourthRisk
        if age != t1{
           let h12 = (MratConstants().SEX[defaults.integer(forKey: "GenderBothTableViewCell")]) * (MratConstants().INCIDENCE[defaults.integer(forKey: "GenderBothTableViewCell")][ageIndex+1][defaults.integer(forKey: "RegionBothTableViewCell")])
           let h22 = MratConstants().MORTALITY[defaults.integer(forKey: "GenderBothTableViewCell")][ageIndex+1]
            risk += h12*r*exp((age-t2)*(h11*r+h21))*(1-exp((t1-age)*(h12*r+h22)))/(h12*r+h22)
        }
        risk = round(risk*10000)/100
        let ratio = round((risk * 0.01) * 1000)

        riskAssessmentDisplayTextView.text = String(risk) + "% risk of developing melanoma"
        
        riskAssessmentDisplaySubTextView.text = "This means that out of every 1000 people living with your information, " + String(ratio) + " are expected to develop melanoma over the next 5 years."
        
        if risk < 3 {
            riskAssessmentDisplayBackgroundBoxView.backgroundColor = #colorLiteral(red: 0.9241562486, green: 0.9777113795, blue: 0.9197322726, alpha: 1)
            riskAssessmentDisplayTextView.textColor = #colorLiteral(red: 0.1120262668, green: 0.4272618592, blue: 0.1718538105, alpha: 1)
            riskAssessmentDisplaySubTextView.textColor = #colorLiteral(red: 0.1120262668, green: 0.4272618592, blue: 0.1718538105, alpha: 1)
        }
        else if 3 < risk && risk < 6{
            riskAssessmentDisplayBackgroundBoxView.backgroundColor = #colorLiteral(red: 0.8375113606, green: 0.880190134, blue: 1, alpha: 1)
            riskAssessmentDisplayTextView.textColor = #colorLiteral(red: 0.1824026671, green: 0.238421675, blue: 0.3575997047, alpha: 1)
            riskAssessmentDisplaySubTextView.textColor = #colorLiteral(red: 0.1824026671, green: 0.238421675, blue: 0.3575997047, alpha: 1)
        }
        else {
            riskAssessmentDisplayBackgroundBoxView.backgroundColor = #colorLiteral(red: 0.9947573543, green: 0.8819299936, blue: 0.8808438182, alpha: 1)
            riskAssessmentDisplayTextView.textColor = #colorLiteral(red: 1, green: 0.4787230492, blue: 0.4714557528, alpha: 1)
            riskAssessmentDisplaySubTextView.textColor = #colorLiteral(red: 1, green: 0.4787230492, blue: 0.4714557528, alpha: 1)
        }
        
    }
   
}

//MARK: - Table View Datasource Methods

extension RiskAssessmentViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if defaults.integer(forKey: "GenderBothTableViewCell") == 0{ //male
            return 13
        }
        else{ //female
            return 11
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DemographicsCategoryTableViewCell") as! DemographicsCategoryTableViewCell

            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RaceBothTableViewCell") as! RaceBothTableViewCell
            cell.calculateAndDisplayRiskProtocolDelegate = self
            cell.displayRaceWarningAlertProtocolDelegate = self
            cell.selectionStyle = .none
            
            return cell
        }
        else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GenderBothTableViewCell") as! GenderBothTableViewCell
            cell.calculateAndDisplayRiskProtocolDelegate = self
            cell.updateTableViewProtocolDelegate = self
            cell.selectionStyle = .none
            
            return cell
        }
        else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegionBothTableViewCell") as! RegionBothTableViewCell
            cell.delegate = self
            cell.selectionStyle = .none
            
            return cell
        }
        else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AgeBothTableViewCell") as! AgeBothTableViewCell
            cell.delegate = self

            cell.selectionStyle = .none
            
            return cell
        }
        else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SkinCharacteristicsCategoryTableViewCell") as! SkinCharacteristicsCategoryTableViewCell

            cell.selectionStyle = .none
            
            return cell
        }
        
        else if indexPath.row == 6 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ComplexionBothTableViewCell") as! ComplexionBothTableViewCell
            cell.delegate = self

            cell.selectionStyle = .none
            
            return cell
        }
        
        else if indexPath.row == 7 {
            if defaults.integer(forKey: "GenderBothTableViewCell") == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryOfSunburnMaleTableViewCell") as! HistoryOfSunburnMaleTableViewCell
                cell.delegate = self

                cell.selectionStyle = .none
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ExposureToSunlightFemaleTableViewCell") as! ExposureToSunlightFemaleTableViewCell
                cell.delegate = self

                cell.selectionStyle = .none
                return cell
                
            }
        }
        else if indexPath.row == 8  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhysicalExamCategoryTableViewCell") as! PhysicalExamCategoryTableViewCell

            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.row == 9  {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MolesLessThan5mmBothTableViewCell") as! MolesLessThan5mmBothTableViewCell
            if defaults.integer(forKey: "GenderBothTableViewCell") == 0{ //male
                cell.molesLessThan5SegmentedControl.setTitle("Less than 7", forSegmentAt: 0)
                cell.molesLessThan5SegmentedControl.setTitle("7-16", forSegmentAt: 1)
                cell.molesLessThan5SegmentedControl.setTitle("17+", forSegmentAt: 2)
            }
            else{ //female
                cell.molesLessThan5SegmentedControl.setTitle("Less than 5", forSegmentAt: 0)
                cell.molesLessThan5SegmentedControl.setTitle("5-11", forSegmentAt: 1)
                cell.molesLessThan5SegmentedControl.setTitle("12+", forSegmentAt: 2)
            }
            cell.delegate = self

            cell.selectionStyle = .none
            
            
            
            return cell
        }
        
        else if indexPath.row == 10  {
            if defaults.integer(forKey: "GenderBothTableViewCell") == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MolesLargerThan5mmMaleTableViewCell") as! MolesLargerThan5mmMaleTableViewCell
                cell.delegate = self

                cell.selectionStyle = .none
                return cell
                
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ExtensiveFrecklingBothTableViewCell") as! ExtensiveFrecklingBothTableViewCell
                cell.delegate = self

                cell.selectionStyle = .none
                return cell
            }
        }
        else if indexPath.row == 11  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExtensiveFrecklingBothTableViewCell") as! ExtensiveFrecklingBothTableViewCell
            cell.delegate = self

            cell.selectionStyle = .none
            return cell
        }
        else  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SevereSolarDamageMaleTableViewCell") as! SevereSolarDamageMaleTableViewCell
            cell.delegate = self

            cell.selectionStyle = .none
            return cell
        }
        
    }
    
}




//MARK: - Risk Assessment Cell Classes


class DemographicsCategoryTableViewCell: UITableViewCell{
    let defaults = UserDefaults.standard

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


class RaceBothTableViewCell: UITableViewCell{
    let defaults = UserDefaults.standard
    weak var calculateAndDisplayRiskProtocolDelegate: calculateAndDisplayRiskProtocol?
    weak var displayRaceWarningAlertProtocolDelegate: displayRaceWarningAlertProtocol?
    @IBOutlet weak var raceSegmentedControl: UISegmentedControl!
    @IBAction func raceSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        defaults.set(raceSegmentedControl.selectedSegmentIndex, forKey: "RaceBothTableViewCell")
        if raceSegmentedControl.selectedSegmentIndex == 1{
            displayRaceWarningAlertProtocolDelegate?.displayRaceWarningAlert()
        }
        calculateAndDisplayRiskProtocolDelegate?.calculateRisk()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let font = UIFont (name: "Avenir Light", size: 12) ?? UIFont.systemFont(ofSize: 16)
        raceSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        raceSegmentedControl.selectedSegmentIndex = defaults.integer(forKey: "RaceBothTableViewCell")
    }
}



class GenderBothTableViewCell: UITableViewCell{
    let defaults = UserDefaults.standard
    weak var updateTableViewProtocolDelegate: updateTableViewProtocol?
    weak var calculateAndDisplayRiskProtocolDelegate: calculateAndDisplayRiskProtocol?

    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    @IBAction func genderSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        defaults.set(genderSegmentedControl.selectedSegmentIndex, forKey: "GenderBothTableViewCell")
        updateTableViewProtocolDelegate?.updateTableView()
        calculateAndDisplayRiskProtocolDelegate?.calculateRisk()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let font = UIFont (name: "Avenir Light", size: 12) ?? UIFont.systemFont(ofSize: 16)
        genderSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        genderSegmentedControl.selectedSegmentIndex = defaults.integer(forKey: "GenderBothTableViewCell")

    }
}


class RegionBothTableViewCell: UITableViewCell{
    let defaults = UserDefaults.standard
    weak var delegate: calculateAndDisplayRiskProtocol?

    @IBOutlet weak var regionSegmentedControl: UISegmentedControl!
    @IBAction func regionSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        defaults.set(regionSegmentedControl.selectedSegmentIndex, forKey: "RegionBothTableViewCell")
        delegate?.calculateRisk()


    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let font = UIFont (name: "Avenir Light", size: 12) ?? UIFont.systemFont(ofSize: 16)
        regionSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        regionSegmentedControl.selectedSegmentIndex = defaults.integer(forKey: "RegionBothTableViewCell")
    }
}


class AgeBothTableViewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate{
    let defaults = UserDefaults.standard
    weak var delegate: calculateAndDisplayRiskProtocol?

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 51
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont (name: "Avenir Light", size: 13.5) ?? UIFont.systemFont(ofSize: 16)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = String(row + 20)
        return pickerLabel!
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        defaults.set(String(row + 20), forKey: "AgeBothTableViewCell")
        delegate?.calculateRisk()

    }
    @IBOutlet weak var agePickerView: UIPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        agePickerView.dataSource = self
        agePickerView.delegate = self
        agePickerView.selectRow(defaults.integer(forKey: "AgeBothTableViewCell") - 20, inComponent: 0, animated: true)
    }
}



class SkinCharacteristicsCategoryTableViewCell: UITableViewCell{
    let defaults = UserDefaults.standard

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}



class ComplexionBothTableViewCell: UITableViewCell{
    let defaults = UserDefaults.standard
    weak var delegate: calculateAndDisplayRiskProtocol?

    @IBOutlet weak var complexionSegmentedControl: UISegmentedControl!
    
    @IBAction func complexionSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        defaults.set(complexionSegmentedControl.selectedSegmentIndex, forKey: "ComplexionBothTableViewCell")
        delegate?.calculateRisk()

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let font = UIFont (name: "Avenir Light", size: 12) ?? UIFont.systemFont(ofSize: 16)
        complexionSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        complexionSegmentedControl.selectedSegmentIndex = defaults.integer(forKey: "ComplexionBothTableViewCell")

    }
}



class HistoryOfSunburnMaleTableViewCell: UITableViewCell{
    let defaults = UserDefaults.standard
    weak var delegate: calculateAndDisplayRiskProtocol?

    @IBOutlet weak var historyOfSunburnSegmentedControl: UISegmentedControl!
    
    @IBAction func historyOfSunburnSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        defaults.set(historyOfSunburnSegmentedControl.selectedSegmentIndex, forKey: "HistoryOfSunburnMaleTableViewCell")
        delegate?.calculateRisk()

    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let font = UIFont (name: "Avenir Light", size: 12) ?? UIFont.systemFont(ofSize: 16)
        historyOfSunburnSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        historyOfSunburnSegmentedControl.selectedSegmentIndex = defaults.integer(forKey: "HistoryOfSunburnMaleTableViewCell")

    }
}



class ExposureToSunlightFemaleTableViewCell: UITableViewCell{
    let defaults = UserDefaults.standard
    weak var delegate: calculateAndDisplayRiskProtocol?

    @IBOutlet weak var exposureToSunlightSegmentedControl: UISegmentedControl!
    
    @IBAction func exposureToSunlightSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        defaults.set(exposureToSunlightSegmentedControl.selectedSegmentIndex, forKey: "ExposureToSunlightFemaleTableViewCell")
        delegate?.calculateRisk()

    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let font = UIFont (name: "Avenir Light", size: 12) ?? UIFont.systemFont(ofSize: 16)
        exposureToSunlightSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        exposureToSunlightSegmentedControl.selectedSegmentIndex = defaults.integer(forKey: "ExposureToSunlightFemaleTableViewCell")

    }
}


class PhysicalExamCategoryTableViewCell: UITableViewCell{
    let defaults = UserDefaults.standard

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


class MolesLessThan5mmBothTableViewCell: UITableViewCell{
    let defaults = UserDefaults.standard
    weak var delegate: calculateAndDisplayRiskProtocol?

    @IBOutlet weak var molesLessThan5SegmentedControl: UISegmentedControl!
    
    @IBAction func molesLessThan5SegmentedControlValueChanged(_ sender: UISegmentedControl) {
        defaults.set(molesLessThan5SegmentedControl.selectedSegmentIndex, forKey: "MolesLessThan5mmBothTableViewCell")
        delegate?.calculateRisk()

    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let font = UIFont (name: "Avenir Light", size: 12) ?? UIFont.systemFont(ofSize: 16)
        molesLessThan5SegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        molesLessThan5SegmentedControl.selectedSegmentIndex = defaults.integer(forKey: "MolesLessThan5mmBothTableViewCell")
        
        
        if defaults.integer(forKey: "GenderBothTableViewCell") == 0 { //male
            molesLessThan5SegmentedControl.setTitle("Less than 7", forSegmentAt: 0)
            molesLessThan5SegmentedControl.setTitle("7-16", forSegmentAt: 1)
            molesLessThan5SegmentedControl.setTitle("17+", forSegmentAt: 2)
        }
    }
}


class MolesLargerThan5mmMaleTableViewCell: UITableViewCell{
    let defaults = UserDefaults.standard
    weak var delegate: calculateAndDisplayRiskProtocol?

    @IBOutlet weak var molesLargerThan5SegmentedControl: UISegmentedControl!
    
    @IBAction func molesLargerThan5SegmentedControlValueChanged(_ sender: UISegmentedControl) {
        defaults.set(molesLargerThan5SegmentedControl.selectedSegmentIndex, forKey: "MolesLargerThan5mmMaleTableViewCell")
        delegate?.calculateRisk()

    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let font = UIFont (name: "Avenir Light", size: 12) ?? UIFont.systemFont(ofSize: 16)
        molesLargerThan5SegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        molesLargerThan5SegmentedControl.selectedSegmentIndex = defaults.integer(forKey: "MolesLargerThan5mmMaleTableViewCell")

    }
}



class ExtensiveFrecklingBothTableViewCell: UITableViewCell{
    let defaults = UserDefaults.standard
    weak var delegate: calculateAndDisplayRiskProtocol?

    @IBOutlet weak var extensiveFrecklingSegmentedControl: UISegmentedControl!
    
    @IBAction func extensiveFrecklingSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        defaults.set(extensiveFrecklingSegmentedControl.selectedSegmentIndex, forKey: "ExtensiveFrecklingBothTableViewCell")
        delegate?.calculateRisk()

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let font = UIFont (name: "Avenir Light", size: 12) ?? UIFont.systemFont(ofSize: 16)
        extensiveFrecklingSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        extensiveFrecklingSegmentedControl.selectedSegmentIndex = defaults.integer(forKey: "ExtensiveFrecklingBothTableViewCell")

    }
}


class SevereSolarDamageMaleTableViewCell: UITableViewCell{
    let defaults = UserDefaults.standard
    weak var delegate: calculateAndDisplayRiskProtocol?

    @IBOutlet weak var severeSolarDamageSegmentedControl: UISegmentedControl!
    
    @IBAction func severeSolarDamageSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        defaults.set(severeSolarDamageSegmentedControl.selectedSegmentIndex, forKey: "SevereSolarDamageMaleTableViewCell")
        delegate?.calculateRisk()

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let font = UIFont (name: "Avenir Light", size: 12) ?? UIFont.systemFont(ofSize: 16)
        severeSolarDamageSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        severeSolarDamageSegmentedControl.selectedSegmentIndex = defaults.integer(forKey: "SevereSolarDamageMaleTableViewCell")

    }
}




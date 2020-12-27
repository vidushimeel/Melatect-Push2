//
//  MyDoctorsViewController.swift
//  MoleScan
//
//  Created by Asritha Bodepudi on 11/7/20.
//

import UIKit
import RealmSwift
import MapKit
import MessageUI
import SideMenu

class MyDoctorsViewController: UIViewController{
   
    /* used for dynamic hieght of text view inside table view cell:
     https://www.swiftdevcenter.com/the-dynamic-height-of-uitextview-inside-uitableviewcell-swift/ */
    let realm = try! Realm()
    var locationManager:CLLocationManager!
    var currentLocationStr = "Current location"
    var mRegion: MKCoordinateRegion!
    var menu = UISideMenuNavigationController(rootViewController: SideMenuViewController())

    @IBOutlet weak var myDoctorsScrollView: UIScrollView!
    @IBOutlet weak var searchForDermatologistsNearMeSearchBar: UISearchBar!
    @IBOutlet weak var addNewDoctorButton: UIButton!
    @IBOutlet weak var myDoctorsTableView: UITableView!
    @IBOutlet weak var myDoctorsTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var searchForDermatologistsNearMeMapView: MKMapView!
    @IBAction func addNewDoctorButtonPressed(_ sender: Any) {
        createNewDoctor()
        myDoctorsTableView.reloadData()
        let bottomOffset = CGPoint(x: 0, y: myDoctorsScrollView.contentSize.height - myDoctorsScrollView.bounds.size.height)
        myDoctorsScrollView.setContentOffset(bottomOffset, animated: true)
    }
    func createNewDoctor(){
        let newDoctor = Doctor()
        do {
            try realm.write{
                realm.add(newDoctor)
            }
        }
        catch {
            print (error)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenUserTapsElsewhereOnScreen()
         if realm.objects(Doctor.self).count == 0{
            createNewDoctor()
         }
        tabBarController?.tabBar.backgroundColor = .white
        searchForDermatologistsNearMeSearchBar.delegate = self
        let nib = UINib(nibName: "DoctorTableViewCell", bundle: nil)
        self.myDoctorsTableView.register(nib, forCellReuseIdentifier: "DoctorTableViewCell")
        self.myDoctorsTableView.dataSource = self
        self.myDoctorsTableView.tableFooterView = UIView()
        self.myDoctorsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.myDoctorsTableView.backgroundColor = UIColor.clear

        searchForDermatologistsNearMeSearchBar.backgroundImage = UIImage()
        addNewDoctorButton.layer.cornerRadius = 10
        
        
        myDoctorsTableView.reloadData()
        searchForDermatologistsNearMeMapView.layer.cornerRadius = 15
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        menu.leftSide = true
        SideMenuManager.default.menuLeftNavigationController = menu
        SideMenuManager.default.menuFadeStatusBar = false
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.9488552213, green: 0.9487094283, blue: 0.9693081975, alpha: 1)
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    override func viewDidAppear(_ animated: Bool) {
        determineCurrentLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        myDoctorsTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        myDoctorsTableView.reloadData()
        registerNotifications()

    }
    override func viewWillDisappear(_ animated: Bool) {
        myDoctorsTableView.removeObserver(self, forKeyPath: "contentSize")
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize"{
                if let newvalue = change?[.newKey]{
                    let newsize = newvalue as! CGSize
                    self.myDoctorsTableViewHeight.constant = newsize.height
                }
        }
    }
    @IBAction func openSideMenuButtonPressed(_ sender: UIButton) {
        present(menu, animated: true)
        navigationController?.navigationBar.barStyle = .default
    }
    
    
}
    //MARK: - MapKit Methods
    
    /*
     - load up screen based on user location (ask for permission as well)
     - if you scroll through the map it should show more doctors more than like the 5k radius
     - fix search bar functionality so don't just have to type in a specific address
     - when you click on pin, pop up with details
     - add button in pop up so you can add to list of doctors
     - when click on map, goes into own view controller (2nd update)
     */
extension MyDoctorsViewController: UISearchBarDelegate, CLLocationManagerDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
            print("end searching --> Close Keyboard")
            self.searchForDermatologistsNearMeSearchBar.endEditing(true)
         
           
           let address = searchForDermatologistsNearMeSearchBar.text ?? "40 Tower Road"

               let geoCoder = CLGeocoder()
              print( geoCoder.geocodeAddressString(address) { (placemarks, error) in
                   guard
                       let placemarks = placemarks,
                       let location = placemarks.first?.location
                   else {
                       // handle no location found
                       return
                   }
                   print (location)
               self.searchForDermatologistsNearMeMapView.centerToLocation(location)
               self.findDermatologistsNearMe()
                   // Use your location
               })
        }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error - locationManager: \(error.localizedDescription)")
    }
    func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let mUserLocation:CLLocation = locations[0] as CLLocation
        let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
        mRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        //mMapView.setRegion(mRegion, animated: true)
        searchForDermatologistsNearMeMapView.centerToLocation(CLLocation(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude))
        print (CLLocation(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude))
        findDermatologistsNearMe()
    }
    
    
    func findDermatologistsNearMe(){
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "Dermatology"
        print (searchForDermatologistsNearMeMapView.region)
        searchRequest.region = searchForDermatologistsNearMeMapView.region
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            
            for item in response.mapItems {
                self.searchForDermatologistsNearMeMapView.addAnnotation(item.placemark)
            }
        }
    }
    
    
    //Search Bar Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MyDoctorsViewController.reload), object: nil)
        self.perform(#selector(MyDoctorsViewController.reload), with: nil, afterDelay: 0.5)
    }
    @objc func reload(){
        
    }
}


private extension MKMapView {
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 100000) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}




//MARK: - Table View Datasource Methods

extension MyDoctorsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
       /* if realm.objects(Doctor.self).count == 0{
            return 1
        }*/
        return realm.objects(Doctor.self).count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorTableViewCell", for: indexPath) as! DoctorTableViewCell
        cell.selectionStyle = .none
        cell.phoneDelegate = self
        cell.emailDelegate = self
        cell.doctorTypeTextView.delegate = self
        cell.doctorTypeTextView.accessibilityIdentifier = "doctorTypeTextView"
        cell.nameTextView.delegate = self
        cell.nameTextView.accessibilityIdentifier = "nameTextView"
        cell.phoneNumberTextView.delegate = self
        cell.phoneNumberTextView.accessibilityIdentifier = "phoneNumberTextView"
        cell.emailTextView.delegate = self
        cell.emailTextView.accessibilityIdentifier = "emailTextView"
        
        
        if (realm.objects(Doctor.self).count != 0){
            if realm.objects(Doctor.self)[indexPath.row].doctorType != ""{
                cell.doctorTypeTextView.text = realm.objects(Doctor.self)[indexPath.row].doctorType
                
            }
            else {
                cell.doctorTypeTextView.text = "Primary Care Doctor"
                
            }
            if realm.objects(Doctor.self)[indexPath.row].name != ""{
                cell.nameTextView.text = realm.objects(Doctor.self)[indexPath.row].name
                
            }
            else {
                cell.nameTextView.text = ""
                
            }
            if realm.objects(Doctor.self)[indexPath.row].email != ""{
                cell.emailTextView.text = realm.objects(Doctor.self)[indexPath.row].email
                
            }
            else {
                cell.emailTextView.text = ""
                
            }
            if realm.objects(Doctor.self)[indexPath.row].phone != ""{
                cell.phoneNumberTextView.text = realm.objects(Doctor.self)[indexPath.row].phone
                
            }
            else {
                cell.phoneNumberTextView.text = ""
                
            }
        }
        return cell
    }
}

//MARK: - Text View Delegate

extension MyDoctorsViewController: UITextViewDelegate{
    
    
    func textViewDidChange(_ textView: UITextView) {
       // updateRealm(textView)
        if textView.text == ""{
            myDoctorsTableView.reloadData()
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        updateRealm(textView)
    }
    
    func updateRealm(_ textView: UITextView) {
        let buttonPosition:CGPoint = textView.convert(CGPoint.zero, to:self.myDoctorsTableView)
        if let indexPath = self.myDoctorsTableView.indexPathForRow(at: buttonPosition){
            do {
                try! realm.write {

                    if textView.accessibilityIdentifier == "doctorTypeTextView"{
                        realm.objects(Doctor.self)[indexPath[1]].doctorType = (textView.text!)
                    }
                    else if textView.accessibilityIdentifier == "nameTextView"{
                        //print (realm.obje)
                        realm.objects(Doctor.self)[indexPath[1]].name = (textView.text!)
                        print ("hellooo")
                    }
                    else if textView.accessibilityIdentifier == "phoneNumberTextView"{
                        realm.objects(Doctor.self)[indexPath[1]].phone = (textView.text!)
                    }
                    else if textView.accessibilityIdentifier == "emailTextView"{
                        realm.objects(Doctor.self)[indexPath[1]].email = (textView.text!)
                    }
                }
            }
        }
        print ("THIS METHODS IS FINE")
        if textView.text == ""
        {
            myDoctorsTableView.reloadData()
        }
    }
    
   
}



//MARK: - Keyboard Methods

extension MyDoctorsViewController
{
    func hideKeyboardWhenUserTapsElsewhereOnScreen()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(MyDoctorsViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        myDoctorsScrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }

    @objc private func keyboardWillHide(notification: NSNotification){
        myDoctorsScrollView.contentInset.bottom = 0
    }
}


//MARK: - Phone Number and Email Methods
extension MyDoctorsViewController: MFMailComposeViewControllerDelegate, PhoneNumberDelegate, EmailDelegate{
    func emailButtonTapped(cell: DoctorTableViewCell) {
        guard let indexPath = self.myDoctorsTableView.indexPath(for: cell) else {
            return
        }
        if isValidEmail(email: realm.objects(Doctor.self)[indexPath.row].email){
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
              //  mail.setToRecipients(["hi@zerotoappstore.com"])
                mail.setToRecipients([realm.objects(Doctor.self)[indexPath.row].email])

                mail.setMessageBody("<p>CHANGE THIS</p>", isHTML: true)
                
                present(mail, animated: true)
            }
            else{
                let alert = UIAlertController(title: "Your iPhone settings are preventing you from sending an email.", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                self.present(alert, animated: true)
            }
        }
        else{
            let alert = UIAlertController(title: "Please enter a proper email", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    func phoneButtonTapped(cell: DoctorTableViewCell) {
        guard let indexPath = self.myDoctorsTableView.indexPath(for: cell) else {
            return
        }
        if let url = URL(string: "tel://\(realm.objects(Doctor.self)[indexPath.row].phone)"),
        UIApplication.shared.canOpenURL(url) {
            print("no one cares about me")
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        else{
            let alert = UIAlertController(title: "Please enter a proper phone number.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            
        }
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}





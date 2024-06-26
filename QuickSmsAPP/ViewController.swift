import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var phoneNumberTextField: UITextField!

    var templates: [SmsTemplate] = []
    var selectedTemplate: SmsTemplate?

    // Your Twilio credentials
    let accountSID = "AC4abc64a715c56268b38e475b4ec92f35"
    let authToken = "47b5979f78fe9055a473091f7db65d24"
    let twilioPhoneNumber = "+17178648051"
    let destinationPhoneNumber = "+905312395556"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SmsTemplateCell")
        loadTemplates()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - UITableViewDataSource
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "AddTemplateSegue",
               let addTemplateVC = segue.destination as? AddSmsTemplateViewController {
                addTemplateVC.newTemplate = { [weak self] template in
                    self?.templates.append(template)
                    self?.saveTemplates()
                    self?.tableView.reloadData()
                }
            }
        }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SmsTemplateCell", for: indexPath)
        cell.textLabel?.text = templates[indexPath.row].message
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTemplate = templates[indexPath.row]
    }
    
    // Enable swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            templates.remove(at: indexPath.row)
            saveTemplates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    @IBAction func sendSMS(_ sender: UIButton) {
            guard let selectedTemplate = selectedTemplate else {
                print("No template selected")
                return
            }
            
            guard var phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty else {
                print("No phone number entered")
                return
            }
            phoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
            phoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            
            // Ensure the phone number starts with "+90"
            if !phoneNumber.hasPrefix("+90") {
                phoneNumber = "+90" + phoneNumber
            }
            
            sendSMSTwilio(message: selectedTemplate.message, to: phoneNumber)
        }
    
    func sendSMSTwilio(message: String, to phoneNumber: String) {
        let parameters: [String: Any] = [
            "From": twilioPhoneNumber,
            "To": phoneNumber,
            "Body": message
        ]
        
        let url = "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages.json"
        
        AF.request(url, method: .post, parameters: parameters)
            .authenticate(username: accountSID, password: authToken)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("Message sent successfully: \(value)")
                case .failure(let error):
                    print("Error sending message: \(error)")
                }
            }
    }
    
    @objc private func refreshTemplates() {
        tableView.reloadData()
    }
    
    // MARK: - Persistence

    private func saveTemplates() {
        let templatesData = templates.map { try? JSONEncoder().encode($0) }
        UserDefaults.standard.set(templatesData, forKey: "smsTemplates")
    }

    private func loadTemplates() {
        guard let savedTemplatesData = UserDefaults.standard.array(forKey: "smsTemplates") as? [Data] else { return }
        templates = savedTemplatesData.compactMap { try? JSONDecoder().decode(SmsTemplate.self, from: $0) }
    }
}

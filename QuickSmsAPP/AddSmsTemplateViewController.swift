import UIKit

class AddSmsTemplateViewController: UIViewController {

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!

    var newTemplate: ((SmsTemplate) -> Void)?
    var errorTimer: Timer?
    
    @IBAction private func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

    private func showErrorLabel() {
        errorLabel.isHidden = false
        errorTimer?.invalidate()
        
        messageTextField.layer.borderWidth = 1.0
        messageTextField.layer.borderColor = UIColor.red.cgColor
        
        errorTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.hideErrorLabel()
        }
    }
    
    private func hideErrorLabel() {
        errorLabel.isHidden = true
        messageTextField.layer.borderWidth = 0.0
        messageTextField.layer.borderColor = UIColor.clear.cgColor
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let message = messageTextField.text, !message.isEmpty else {
            showErrorLabel()
            return
        }
        
        hideErrorLabel()
        
        let template = SmsTemplate(message: message)
        newTemplate?(template)
                
        dismiss(animated: true, completion: nil)
    }
    
}

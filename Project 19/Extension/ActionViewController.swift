//
//  ActionViewController.swift
//  Extension
//
//  Created by Евгения Зорич on 06.03.2023.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController, LoaderDelegate {
    
    @IBOutlet var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""
    
    var savedCode = [UserCode]()
    var nameCode = ""
    
    var codeToLoad = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addition))
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
                if let itemProvider = inputItem.attachments?.first {
                    itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                        guard let itemDictionary = dict as? NSDictionary else { return }
                        guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                        
                        self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                        self?.pageURL = javaScriptValues["URL"] as? String ?? ""

                        DispatchQueue.main.async { [weak self] in
                            self?.title = self?.pageTitle
                        }
                    }
                }
            }
    }

    func loader(_ loader: DetailViewController, didSelect script: String) {
        codeToLoad = script
    }
    
    @IBAction func done() {
        let item = NSExtensionItem()
            let argument: NSDictionary = ["customJavaScript": script.text]
            let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
            let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
            item.attachments = [customJavaScript]

            extensionContext?.completeRequest(returningItems: [item])
    }
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        script.scrollIndicatorInsets = script.contentInset

        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    
    @objc func addition() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.addAction(UIAlertAction(title: "Examples", style: .default) { [weak self] _ in
            self?.showExamples()
        })
        ac.addAction(UIAlertAction(title: "Save code", style: .default) { [weak self] _ in
            self?.saveCode()
        })
        ac.addAction(UIAlertAction(title: "Download code", style: .default) { [weak self] _ in
            self?.downloadCode()
        })

        present(ac, animated: false)
    }
    
    func saveCode() {
        let ac = UIAlertController(title: "Script name", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let name = ac?.textFields?[0].text else { return }
            self?.savedCode.append(UserCode(name: name, code: self?.script.text ?? ""))
            self?.performSelector(inBackground: #selector(self?.saveCodeJSON), with: nil)
        })

        present(ac, animated: false)
    }
    @objc func saveCodeJSON() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(savedCode) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(savedData, forKey: nameCode)
        }
    }
    
    func showExamples() {
        let ac = UIAlertController(title: "Examples", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        for (title, example) in scriptExamples {
            ac.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.script.text = example
            })
        }
        
        present(ac, animated: false)
    }
    
    func downloadCode() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.savedCode = savedCode
            vc.nameCode = nameCode
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

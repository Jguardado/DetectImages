//
//  MainViewController.swift
//  Detect Images
//
//  Created by Juan Guardado on 2/14/19.
//  Copyright © 2019 Juan Guardado. All rights reserved.
//

import UIKit
import CoreML
import Vision

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var restnetModel = Resnet50()
    
    var results = [VNClassificationObservation]()
    var pickerController = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        pickerController.delegate = self
        
        if let image = imageView.image {
            processPicture(image: image)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            processPicture(image: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func fileTapped(_ sender: Any) {
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        pickerController.sourceType = .camera
        present(pickerController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let result = results[indexPath.row]
        
        let name = result.identifier.prefix(30)
        cell.textLabel?.text = "\(name) : \(Int(result.confidence * 100))%"
        return cell
    }
    
    func processPicture (image: UIImage) {
        if let model = try? VNCoreMLModel(for: restnetModel.model) {
            let request = VNCoreMLRequest(model: model) { (request, err) in
                if let results = request.results as? [VNClassificationObservation] {
                    self.results = Array(results.prefix(20))
                    self.tableView.reloadData()

                }
            }
            
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
            }
        }
    }
}

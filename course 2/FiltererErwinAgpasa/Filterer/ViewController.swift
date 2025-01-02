//
//  ViewController.swift
//  Filterer
//
//  Created by Developer on 02/01/2025.
//

import UIKit
import CoreImage
import Foundation

enum TypeFilter: Int {
    case saturation = 0
    case brightness = 1
    case contrast   = 2
}

class ViewController: UIViewController {
    
    var filteredImage: UIImage?
    
    @IBOutlet var profileImage: UIImageView!
    
    @IBOutlet var bottomView: UIView!
    @IBOutlet var secondaryView: UIView!
    
    @IBOutlet var comparedView: UIView!
    
    @IBOutlet var newPhotoButton: UIButton!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var compareButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    
    // Secondary Menu
    @IBOutlet var opt1SecButton: UIButton! // saturation
    @IBOutlet var opt2SecButton: UIButton! // brightness
    @IBOutlet var opt3SecButton: UIButton! // contrast
    @IBOutlet var opt4SecButton: UIButton! // "Edit"
    
    @IBOutlet var opt1Image: UIImageView!  // preview saturation
    @IBOutlet var opt2Image: UIImageView!  // preview brightness
    @IBOutlet var opt3Image: UIImageView!  // preview contrast
    
    @IBOutlet var secondarySliderView: UIView!
    @IBOutlet var titleSlider: UILabel!
    @IBOutlet var slider: UISlider!
    @IBOutlet var closeSliderButton: UIButton!
    
    @IBOutlet var imageView: UIView!
    
    var originalImage = UIImage()
    var filterImage = UIImage()
    
    var isSelecteImage = false
    
    var currentEffectSelected = TypeFilter.saturation
    var isCompareShow = false
    var lastSelected = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    // MARK: - UI Initialization
    func initUI() {
        shareButton.addTarget(self, action: #selector(onShare), for: .touchUpInside)
        newPhotoButton.addTarget(self, action: #selector(onNewPhoto), for: .touchUpInside)
        filterButton.addTarget(self, action: #selector(onFilter), for: .touchUpInside)
        compareButton.addTarget(self, action: #selector(onCompare), for: .touchUpInside)
        
        opt1SecButton.addTarget(self, action: #selector(onSaturation), for: .touchUpInside)
        opt2SecButton.addTarget(self, action: #selector(onBrightness), for: .touchUpInside)
        opt3SecButton.addTarget(self, action: #selector(onContrast), for: .touchUpInside)
        opt4SecButton.addTarget(self, action: #selector(onEdit), for: .touchUpInside)
        
        opt4SecButton.setTitle("Edit", for: .normal)
        
        opt1SecButton.tag = 0
        opt2SecButton.tag = 1
        opt3SecButton.tag = 2
        
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.isContinuous = false
        slider.value = 50
        slider.addTarget(self, action: #selector(sliderValueDidChange), for: .valueChanged)
        
        closeSliderButton.addTarget(self, action: #selector(onCloseSlider), for: .touchUpInside)
        
        compareButton.isEnabled = false
    }
    
}

// MARK: - Slider View
extension ViewController {
    
    @objc func sliderValueDidChange(sender: UISlider!) {
        let percent = Int(sender.value)
        applyFilterToImage(percent: percent)
    }
    
    func applyFilterToImage(percent: Int) {
        switch currentEffectSelected {
        case .saturation:
            let filter = Filter(image: originalImage)
            let newImage = filter.saturation(percent: percent)
            updateImage(image: newImage)
        case .brightness:
            let filter = Filter(image: originalImage)
            let newImage = filter.brightness(percent: percent)
            updateImage(image: newImage)
        case .contrast:
            let filter = Filter(image: originalImage)
            let newImage = filter.contrast(percent: percent)
            updateImage(image: newImage)
        }
    }
    
    func updateImage(image: UIImage) {
        DispatchQueue.main.async {
            // Clear existing subviews from imageView
            self.imageView.subviews.forEach({ $0.removeFromSuperview() })
            
            let newView = UIImageView(frame: self.imageView.bounds)
            newView.contentMode = .scaleAspectFit
            newView.image = image
            self.imageView.addSubview(newView)
            
            self.filterImage = image
            
            // Cross-dissolve animation
            self.imageView.alpha = 0
            UIView.transition(with: self.view,
                              duration: 0.6,
                              options: .transitionCrossDissolve,
                              animations: {
                self.imageView.alpha = 1
            })
        }
    }
    
    func updateImageNoFilter(image: UIImage) {
        DispatchQueue.main.async {
            self.imageView.subviews.forEach({ $0.removeFromSuperview() })
            
            let newView = UIImageView(frame: self.imageView.bounds)
            newView.contentMode = .scaleAspectFit
            newView.image = image
            self.imageView.addSubview(newView)
            
            self.imageView.alpha = 0
            UIView.transition(with: self.view,
                              duration: 0.6,
                              options: .transitionCrossDissolve,
                              animations: {
                self.imageView.alpha = 1
            })
        }
    }
}

// MARK: - Bottom View
extension ViewController {
    
    // MARK: Actions
    @objc func onNewPhoto(sender: UIButton!) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.showCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: { _ in
            self.showAlbum()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func onFilter(sender: UIButton!) {
        guard isSelecteImage else { return }
        
        if sender.isSelected {
            // Hide filter menu
            hideSecondaryMenu()
            sender.isSelected = false
            
            // Reset image to original
            updateImage(image: originalImage)
            
            // Hide compare view
            hideComparedView()
            compareButton.isEnabled = false
        } else {
            // Deselect existing filter buttons
            opt1SecButton.isSelected = false
            opt2SecButton.isSelected = false
            opt3SecButton.isSelected = false
            defaultImages()
            
            // Show filter menu
            showSecondaryMenu()
            sender.isSelected = true
        }
    }
    
    @objc func onCompare(sender: UIButton!) {
        if isCompareShow {
            // Show filtered image
            updateImageNoFilter(image: filterImage)
            hideComparedView()
            isCompareShow = false
        } else {
            // Show original image
            updateImageNoFilter(image: originalImage)
            showComparedView()
            isCompareShow = true
        }
    }
    
    @objc func onShare(sender: UIButton!) {
        let activityController = UIActivityViewController(
            activityItems: ["Check out our really cool app", filterImage],
            applicationActivities: nil
        )
        present(activityController, animated: true, completion: nil)
    }
    
    func defaultImages() {
        let filter1 = Filter(image: originalImage)
        opt1Image.image = filter1.saturation(percent: 50)
        
        let filter2 = Filter(image: originalImage)
        opt2Image.image = filter2.brightness(percent: 50)
        
        let filter3 = Filter(image: originalImage)
        opt3Image.image = filter3.contrast(percent: 50)
    }
    
    // MARK: Compare View
    func showComparedView() {
        self.view.addSubview(comparedView)
        comparedView.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = comparedView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
        let leftConstraint = comparedView.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = comparedView.rightAnchor.constraint(equalTo: view.rightAnchor)
        let heightConstraint = comparedView.heightAnchor.constraint(equalToConstant: 90)
        
        NSLayoutConstraint.activate([topConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        self.comparedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.comparedView.alpha = 1.0
        }
    }
    
    func hideComparedView() {
        UIView.animate(withDuration: 0.4, animations: {
            self.comparedView.alpha = 0
        }) { completed in
            if completed {
                self.comparedView.removeFromSuperview()
            }
        }
    }
}

// MARK: - Secondary View
extension ViewController {
    
    // MARK: Actions
    @objc func onSaturation(sender: UIButton!) {
        manageSenderButton(sender: sender)
        currentEffectSelected = .saturation
        applyFilterToImage(percent: 50)
        lastSelected = 0
    }
    
    @objc func onBrightness(sender: UIButton!) {
        manageSenderButton(sender: sender)
        currentEffectSelected = .brightness
        applyFilterToImage(percent: 50)
        lastSelected = 1
    }
    
    @objc func onContrast(sender: UIButton!) {
        manageSenderButton(sender: sender)
        currentEffectSelected = .contrast
        applyFilterToImage(percent: 50)
        lastSelected = 2
    }
    
    func manageSenderButton(sender: UIButton!) {
        if lastSelected != -1, lastSelected != sender.tag {
            switch lastSelected {
            case 0:
                opt1SecButton.isSelected = false
            case 1:
                opt2SecButton.isSelected = false
            case 2:
                opt3SecButton.isSelected = false
            default:
                break
            }
        }
        
        if sender.isSelected {
            sender.isSelected = false
            compareButton.isEnabled = false
        } else {
            sender.isSelected = true
            compareButton.isEnabled = true
        }
    }
    
    @objc func onEdit(sender: UIButton!) {
        if sender.isSelected {
            hideSliderMenu()
            sender.isSelected = false
        } else {
            showSliderMenu()
            sender.isSelected = true
        }
    }
    
    // MARK: Show / Hide Secondary Menu
    func showSecondaryMenu() {
        view.addSubview(secondaryView)
        secondaryView.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = secondaryView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
        let leftConstraint = secondaryView.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = secondaryView.rightAnchor.constraint(equalTo: view.rightAnchor)
        let heightConstraint = secondaryView.heightAnchor.constraint(equalToConstant: 90)
        
        NSLayoutConstraint.activate([topConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        self.secondaryView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.secondaryView.alpha = 1.0
        }
    }
    
    func hideSecondaryMenu() {
        UIView.animate(withDuration: 0.4, animations: {
            self.secondaryView.alpha = 0
        }) { completed in
            if completed {
                self.secondaryView.removeFromSuperview()
            }
        }
    }
    
    // MARK: Show / Hide Secondary Slider
    func showSliderMenu() {
        self.view.addSubview(secondarySliderView)
        secondarySliderView.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = secondarySliderView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
        let leftConstraint = secondarySliderView.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = secondarySliderView.rightAnchor.constraint(equalTo: view.rightAnchor)
        let heightConstraint = secondarySliderView.heightAnchor.constraint(equalToConstant: 90)
        
        NSLayoutConstraint.activate([topConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        self.secondarySliderView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.secondarySliderView.alpha = 1.0
        }
        
        switch currentEffectSelected {
        case .saturation:
            titleSlider.text = "Saturation"
        case .brightness:
            titleSlider.text = "Brightness"
        case .contrast:
            titleSlider.text = "Contrast"
        }
    }
    
    func hideSliderMenu() {
        UIView.animate(withDuration: 0.4, animations: {
            self.secondarySliderView.alpha = 0
        }) { completed in
            if completed {
                self.secondarySliderView.removeFromSuperview()
            }
        }
    }
    
    @objc func onCloseSlider(sender: UIButton!) {
        hideSliderMenu()
        self.opt4SecButton.isSelected = false
    }
}

// MARK: - Image Picker
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            // Optionally show alert that camera is not available
            return
        }
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        present(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            isSelecteImage = true
            self.originalImage = pickedImage
            updateImage(image: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//
//  DiscDetailViewController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 3/5/21.
//
import SafariServices
import UIKit

class DiscDetailViewController: UIViewController {
    
    //  MARK: - Properties
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var bagItButton: UIButton!
    
    var bagID: String = "No Bag."
    var selectedDisc: Disc? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        guard let disc = selectedDisc else { return }
        
        if disc.linkURLString == "" || disc.linkURLString.isEmpty {
            linkButton.isHidden = true
            return
        }
    }
    
    //  MARK: - Actions
    
    @IBAction func linkButtonTapped(_ sender: Any) {
        guard let disc = selectedDisc,
              let linkURL = URL(string: disc.linkURLString) else { return }
        
        let vc = SFSafariViewController(url: linkURL)
        
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func bagItButtonTapped(_ sender: Any) {
        print("bagged")
        
        guard let disc = selectedDisc else { return }
        BagManager.addDiscWith(discID: disc.uid, discModel: disc.model, toBagWith: bagID)

        self.dismiss(animated: true, completion: nil)
    }
    
    //  MARK: - Configure Views
    func configureView() {
        
        guard let disc = selectedDisc else { return }
        
        let mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.alignment = .center
        mainStack.distribution = .equalSpacing
        mainStack.frame = CGRect(x: 8, y: view.frame.height*0.2, width: view.frame.width-16, height: 200)
        view.addSubview(mainStack)
        
        let labelStack = UIStackView()
        labelStack.axis = .vertical
        labelStack.alignment = .center
        labelStack.distribution = .fillEqually
        labelStack.spacing = 16
        labelStack.frame = CGRect(x: 0, y: 0, width: mainStack.frame.width, height: mainStack.frame.height/3*2)
        mainStack.addArrangedSubview(labelStack)
        
        for index in 1...4 {
            let label = UILabel()
            labelStack.addArrangedSubview(label)
            label.textAlignment = .center
            
            switch index {
            case 1:
                label.text = "Model: \(disc.model)"
            case 2:
                label.text = "Brand: \(disc.make)"
            case 3:
                label.text = "Type: \(disc.type)"
            case 4:
                label.text = "In Poduction: \(disc.inProduction)"
            default:
                return
            }
        }
        
        let flightNumsStack = UIStackView()
        flightNumsStack.axis = .horizontal
        flightNumsStack.alignment = .fill
        flightNumsStack.distribution = .fillEqually
        labelStack.frame = CGRect(x: 0, y: 0, width: mainStack.frame.width, height: mainStack.frame.height/3)
        flightNumsStack.spacing = 24
        mainStack.addArrangedSubview(flightNumsStack)
        
        for index in 1...4 {
            
            let ratingStack = UIStackView()
            ratingStack.axis = .vertical
            ratingStack.spacing = 8
            flightNumsStack.addArrangedSubview(ratingStack)
            
            let titleLabel = UILabel()
            titleLabel.textAlignment = .center
            ratingStack.addArrangedSubview(titleLabel)
            
            let ratingLabel = UILabel()
            ratingLabel.textAlignment = .center
            ratingStack.addArrangedSubview(ratingLabel)
            
            switch index {
            case 1:
                titleLabel.text = "Speed"
                if let speed = disc.speed {
                    ratingLabel.text = "\(speed)"
                } else {
                    ratingLabel.text = "N/A"
                }
            case 2:
                titleLabel.text = "Glide"
                if let glide = disc.glide {
                    ratingLabel.text = "\(glide)"
                } else {
                    ratingLabel.text = "N/A"
                }
            case 3:
                titleLabel.text = "Turn"
                if let turn = disc.turn {
                    ratingLabel.text = "\(turn)"
                } else {
                    ratingLabel.text = "N/A"
                }
            case 4:
                titleLabel.text = "Fade"
                if let fade = disc.fade {
                    ratingLabel.text = "\(fade)"
                } else {
                    ratingLabel.text = "N/A"
                }
            default:
                return
            }
        }
    }
}    //  End of Class

//
//  MainViewController2.swift
//  NetHawk
//
//  Created by mobicom on 9/10/24.
//

import UIKit
import FSPagerView

class MainViewController: UIViewController, FSPagerViewDataSource, FSPagerViewDelegate {

    // MARK: - FSPagerView
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")

            // 화면 크기에 비례한 아이템 크기 설정
            let screenWidth = UIScreen.main.bounds.width
            let itemWidth = screenWidth * 0.65
            let itemHeight = itemWidth * 135/155
            self.pagerView.itemSize = CGSize(width: itemWidth, height: itemHeight)
            self.pagerView.interitemSpacing = 50

            self.pagerView.isInfinite = true
            self.pagerView.transformer = FSPagerViewTransformer(type: .ferrisWheel)
        }

    }

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return images.count // 총 4개의 페이지
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)

        // SF Symbol 이미지 설정
        if let imageView = cell.imageView {
            imageView.image = UIImage(named: images[index])
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 8 // 이미지도 모서리를 둥글게
            imageView.layer.masksToBounds = true
        }

        return cell
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true) // 선택된 상태 해제

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch index {
        case 0:
            // 첫 번째 페이지로 이동
            if let firstVC = storyboard.instantiateViewController(withIdentifier: "LogViewController") as? LogViewController {
                firstVC.modalPresentationStyle = .fullScreen
                present(firstVC, animated: true, completion: nil)
            }
        case 1:
            // 두 번째 페이지로 이동
            if let secondVC = storyboard.instantiateViewController(withIdentifier: "StatViewController") as? StatViewController {
                secondVC.modalPresentationStyle = .fullScreen
                present(secondVC, animated: true, completion: nil)
            }
        case 2:
            // 세 번째 페이지로 이동
            if let thirdVC = storyboard.instantiateViewController(withIdentifier: "AccessViewController") as? AccessViewController {
                thirdVC.modalPresentationStyle = .fullScreen
                present(thirdVC, animated: true, completion: nil)
            }
        case 3:
            // 세 번째 페이지로 이동
            if let fourVC = storyboard.instantiateViewController(withIdentifier: "OptionViewController") as? OptionViewController {
                fourVC.modalPresentationStyle = .fullScreen
                present(fourVC, animated: true, completion: nil)
            }
        default:
            break
        }
    }

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    let images = ["loger", "stat", "bw", "option"]

    // MARK: - UI
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pagerView.dataSource = self
        self.pagerView.delegate = self

        if let credentials = KeychainManager.shared.load() {
            // let serialNumber = credentials.serialNumber
            let alias = credentials.alias

            deviceLabel.text = "My Device : \(alias)"
        }

        frameConfig(to: statusView)

        // MQTTService에서 상태 콜백 등록
        setupMQTTStatusCallbacks()

        // MQTT 초기 상태 업데이트
        updateStatusLabel()
    }
    func frameConfig(to view: UIView) {
        let cornerRadius: CGFloat = 10
        let shadowColor: UIColor = .black
        let shadowOpacity: Float = 0.3
        let shadowOffset: CGSize = CGSize(width: 0, height: 2)
        let shadowRadius: CGFloat = 4

        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = false
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOpacity = shadowOpacity
        view.layer.shadowOffset = shadowOffset
        view.layer.shadowRadius = shadowRadius
    }

    // MARK: - MQTT 상태 설정
    func setupMQTTStatusCallbacks() {
        MQTTService.shared.onPingReceived = { [weak self] in
            DispatchQueue.main.async {
                self?.statusLabel.text = "Checking connection..."
                self?.statusLabel.textColor = .gray
            }
        }

        MQTTService.shared.onPongReceived = { [weak self] in
            DispatchQueue.main.async {
                self?.statusLabel.text = "Server Online 🟢"
                self?.statusLabel.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            }
        }

        MQTTService.shared.onDisconnected = { [weak self] in
            DispatchQueue.main.async {
                self?.statusLabel.text = "Server Offline 🔴"
                self?.statusLabel.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            }
        }
    }

    func updateStatusLabel() {
        if MQTTService.shared.isConnected() {
            statusLabel.text = "Server Online 🟢"
            statusLabel.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        } else {
            statusLabel.text = "Server Offline 🔴"
            statusLabel.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        }
    }
}

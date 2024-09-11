//
//  MainViewController2.swift
//  NetHawk
//
//  Created by mobicom on 9/10/24.
//

import UIKit
import FSPagerView

class MainViewController: UIViewController, FSPagerViewDataSource, FSPagerViewDelegate {

    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")

            // 화면 크기에 비례한 아이템 크기 설정
            let screenWidth = UIScreen.main.bounds.width
            let itemWidth = screenWidth * 0.55
            let itemHeight = itemWidth * 125/155
            self.pagerView.itemSize = CGSize(width: itemWidth, height: itemHeight)
            self.pagerView.interitemSpacing = 50

            self.pagerView.isInfinite = true
            self.pagerView.transformer = FSPagerViewTransformer(type: .invertedFerrisWheel)
        }

    }
    @IBOutlet weak var statusView: UIView!
    
    let images = ["loger", "stat", "bw", "option"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pagerView.dataSource = self
        self.pagerView.delegate = self

        frameConfig(to: statusView)
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
    // FSPagerViewDataSource methods
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return images.count // 총 4개의 페이지
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)

        // SF Symbol 이미지 설정
        if let imageView = cell.imageView {
            imageView.image = UIImage(named: images[index])
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 10 // 이미지도 모서리를 둥글게
            imageView.layer.masksToBounds = true
        }

        return cell
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true) // 선택된 상태 해제
        print("Selected page index: \(index)")

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
}

//
//  MainViewController2.swift
//  NetHawk
//
//  Created by mobicom on 9/10/24.
//

import UIKit
import FSPagerView

class MainViewController2: UIViewController, FSPagerViewDataSource, FSPagerViewDelegate {

    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.pagerView.itemSize = CGSize(width:230, height: 140)
            self.pagerView.interitemSpacing = 16
            self.pagerView.isInfinite = true // 무한 스크롤 가능
            self.pagerView.transformer = FSPagerViewTransformer(type: .ferrisWheel)
        }
    }

    let images = ["list.bullet.clipboard", "chart.bar.xaxis", "shield.lefthalf.filled.slash", "gearshape"]
    let titles = ["Log", "Statistics", "Black/White List", "Option"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.pagerView.dataSource = self
        self.pagerView.delegate = self
    }

    // FSPagerViewDataSource methods
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return images.count // 총 4개의 페이지
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)

        // SF Symbol 이미지 설정
        if let imageView = cell.imageView {
            imageView.image = UIImage(systemName: images[index])
            imageView.contentMode = .scaleAspectFit // 이미지의 비율을 유지하면서 셀에 맞춤
        }

        // 레이블 설정
        if let textLabel = cell.textLabel {
            textLabel.text = titles[index]
            textLabel.textAlignment = .center
            textLabel.textColor = .darkGray

            if let superview = textLabel.superview {
                superview.backgroundColor = UIColor.clear // 배경색을 투명하게 설정
                superview.translatesAutoresizingMaskIntoConstraints = false

                // 슈퍼뷰의 새로운 제약 조건 설정 (아래로 20 포인트 이동)
                NSLayoutConstraint.activate([
                    superview.topAnchor.constraint(equalTo: superview.superview!.topAnchor, constant: 140), // 상단에서 20포인트 떨어짐
                    superview.leadingAnchor.constraint(equalTo: superview.superview!.leadingAnchor),
                    superview.trailingAnchor.constraint(equalTo: superview.superview!.trailingAnchor),
                    superview.heightAnchor.constraint(equalToConstant: textLabel.frame.size.height)
                ])
            }
        }

        return cell
    }

    func pagerView(_ pagerView: FSPagerView, shouldHighlightItemAt index: Int) -> Bool {
        return false // 음영 효과를 없앰
    }
}

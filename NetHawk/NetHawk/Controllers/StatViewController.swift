//
//  StatViewController.swift
//  PackeTracker
//
//  Created by mobicom on 6/4/24.
//
import UIKit
import SwiftUI
import Charts

// 차트 데이터 모델
struct ChartData {
    let title: String
    let chartView: AnyView
}

struct PieChartView: View {
    let attackCounts: [String: Int]

    var body: some View {
        // 가장 많이 발생한 공격 유형과 횟수 계산
        let mostDangerousAttack = attackCounts(target: attackCounts)



        VStack(alignment: .leading) {
            HStack {  // 제목을 왼쪽으로 배치
                Text("Attack Distribution")
                    .font(.title2)
                    .bold()
                    .padding(.leading, 10)
                Spacer()  // 오른쪽에 빈 공간 추가
            }

            Chart(attackCounts.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                SectorMark(
                    angle: .value("횟수", value),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5
                )
                .cornerRadius(5)
                .foregroundStyle(by: .value("공격 유형", key))
            }
            .frame(height: 350)
            .chartLegend(alignment: .center)

            // 차트 중앙에 가장 많이 발생한 공격 유형과 횟수 표시
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    let frame = geometry[chartProxy.plotFrame!]
                    VStack {
                        Text("Most Attacked Type")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Text("\(mostDangerousAttack)")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                    }
                    .position(x: frame.midX, y: frame.midY)
                }
            }
            Text("")
        }
    }

    // 공격 카운트
    private func attackCounts(target: [String: Int]) -> String {
        print(target)
        if target["Domain phishing"] == 0 && target["TCP-Flooding"] == 0 && target["UDP-Flooding"] == 0 {
            return "Its just Clean 😎"
        }
        return target.max { a, b in a.value < b.value }?.key ?? "Unknown"
    }
}


struct VictimBarChartView: View {
    let victimCounts: [String: Int]

    var body: some View {
        VStack(alignment: .leading) {
            Text("")
            HStack {  // 제목을 왼쪽으로 배치
                Text("Attacked Devices")
                    .font(.title2)
                    .bold()
                    .padding(.leading, 10)
                Spacer()  // 오른쪽에 빈 공간 추가
            }

            Chart {
                ForEach(victimCounts.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                    BarMark(
                        x: .value("Number of Attacks", value),
                        y: .value("Device", key)
                    )
                    .foregroundStyle(by: .value("Device", key))  // 디바이스별 색상 다르게
                    .annotation(position: .overlay, alignment: .leading) {
                        Text("\(value)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .bold()
                    }
                }
            }
            .chartLegend(alignment: .center)
            .frame(height: 400) // 차트를 더 크게
            .padding()
            .padding(.top, -20)
            .chartXAxis { AxisMarks(values: .automatic(desiredCount: 6)) } // 축 값 자동 조정
            .chartYAxis { AxisMarks(values: .automatic(desiredCount: 6)) } // 축 값 자동 조정
        }
    }
}

//struct BubbleChartView: View {
//    let invaderCounts: [String: Int]
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {  // 제목을 왼쪽으로 배치
//                Text("Attack Distribution")
//                    .font(.title3)
//                    .bold()
//                    .padding(.leading, 10)
//                Spacer()  // 오른쪽에 빈 공간 추가
//            }
//
//            Chart {
//                ForEach(invaderCounts.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
//                    PointMark(
//                        x: .value("Invader IP", key),
//                        y: .value("Number of Attacks", value)
//                    )
//                    .foregroundStyle(.blue)  // 통일된 색상
//                    .symbol(by: .value("Invader IP", key))  // IP별로 모양 다르게
//                    .annotation(position: .overlay, alignment: .center) {
//                        Text("\(value)")
//                            .font(.caption)
//                            .foregroundColor(.white)
//                            .bold()
//                    }
//                }
//            }
//            .frame(height: 400) // 크기 증가
//            .padding()
//        }
//    }
//}


class StatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBAction func dismissBtnTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // 차트 데이터를 저장할 배열
    var chartsData: [ChartData] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // 스와이프 제스처 추가
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.direction = .right // 오른쪽으로 스와이프하면 닫힘
        self.view.addGestureRecognizer(swipeGesture)

        // 테이블뷰 설정
        tableView.delegate = self
        tableView.dataSource = self

        // 차트 데이터를 설정
        setupChartData()

        // 테이블뷰 리로드
        tableView.reloadData()
    }

    // 차트 데이터 설정
    func setupChartData() {
        let logs = LoggingService.shared.getLogs()

        // 1. 공격 유형별 발생 비율 Pie Chart
        let attackCounts = StatisticsService.shared.getAttackTypeCounts(from: logs)
        print(attackCounts)
        chartsData.append(ChartData(title: "공격 유형별 발생 비율", chartView: AnyView(PieChartView(attackCounts: attackCounts))))

        // 2. 피해자별 공격 횟수 Bar Chart
        let victimCounts = StatisticsService.shared.getVictimAttackCounts(from: logs)
        chartsData.append(ChartData(title: "피해자별 공격 횟수", chartView: AnyView(VictimBarChartView(victimCounts: victimCounts))))

        // 3. 공격자 IP별 발생 빈도 Bubble Chart
//        let invaderCounts = StatisticsService.shared.getInvaderAttackCounts(from: logs)
//        chartsData.append(ChartData(title: "공격자 IP별 발생 빈도", chartView: AnyView(BubbleChartView(invaderCounts: invaderCounts))))
    }

    // 테이블뷰 데이터 소스: 섹션당 셀 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chartsData.count
    }

    // 테이블뷰 데이터 소스: 셀 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChartCell", for: indexPath) as! ChartTableViewCell
        let chartData = chartsData[indexPath.row]
        cell.configure(with: chartData)
        return cell
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        // 현재 모달 화면 닫기
        self.dismiss(animated: true, completion: nil)
    }
}

//
//  LogViewController.swift
//  PackeTracker
//
//  Created by mobicom on 6/4/24.
//

import UIKit

class LogViewController: UIViewController {

    @IBOutlet weak var logTableView: UITableView!

    let contentArray = [
           "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the",
           "ng, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including",
           "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of ",
        "he standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from  ",
        "adable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites st",
        "There are many variations of passages of Lorem Ipsum available, but t"
        ]

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad : LogView")
        let myTableViewCellNib = UINib(nibName: "DetectionMessage", bundle: nil)
        self.logTableView.register(myTableViewCellNib, forCellReuseIdentifier: "DetectionMessageCell")

        self.logTableView.rowHeight = UITableView.automaticDimension
        self.logTableView.estimatedRowHeight = 177

        self.logTableView.delegate = self
        self.logTableView.dataSource = self
    }
    
    @IBAction func dismissBtnTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension LogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = logTableView.dequeueReusableCell(withIdentifier: "DetectionMessageCell", for: indexPath) as! DetectionMessageCell

        return cell
    }
}

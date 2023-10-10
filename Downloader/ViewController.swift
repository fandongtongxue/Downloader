//
//  ViewController.swift
//  Downloader
//
//  Created by isoftstone on 2023/10/10.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var sessionManager = appDelegate.sessionManager

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sessionManager.logger.option = .default
        
        sessionManager.progress { manager in
            
        }.completion { manager in
            if manager.status == .succeeded {
                debugPrint("下载完成")
            }else{
                
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBtnAction))
        
        view.addSubview(tableView)
    }
    
    @objc func addBtnAction() {
        let alert = UIAlertController(title: "输入下载地址", message: nil, preferredStyle: .alert)
        
        alert.addTextField { tf in
            tf.placeholder = "http://example.com/file.zip"
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
            let downloadURLStrings = self.sessionManager.tasks.map { $0.url.absoluteString }
            guard let text = alert.textFields?.first?.text else { return }
            if downloadURLStrings.contains(text) {
                return
            }
            
            self.sessionManager.download(text) { [weak self] _ in
                guard let self = self else { return }
                let index = self.sessionManager.tasks.count - 1
                self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }))
        present(alert, animated: true)
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderTopPadding = 0
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(UINib(nibName: "DownloadTaskCell", bundle: Bundle.main), forCellReuseIdentifier: DownloadTaskCell.reuseIdentifier)
        return tableView
    }()

}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sessionManager.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DownloadTaskCell.reuseIdentifier, for: indexPath) as! DownloadTaskCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let task = sessionManager.tasks.safeObject(at: indexPath.row),
              let cell = cell as? DownloadTaskCell
        else { return }
        
        cell.task?.progress { _ in }.success { _ in }.failure { _ in }
        
        cell.task = task
        
        cell.titleLabel.text = task.fileName
        
        cell.updateProgress(task)
        
        cell.tapClosure = { [weak self] cell in
            guard let task = self?.sessionManager.tasks.safeObject(at: indexPath.row) else { return }
            switch task.status {
                case .waiting, .running:
                    self?.sessionManager.suspend(task)
                case .suspended, .failed:
                    self?.sessionManager.start(task)
                default:
                    break
            }
        }
        
        task.progress { [weak cell] task in
            cell?.updateProgress(task)
        }
        .success { [weak cell] (task) in
            cell?.updateProgress(task)
            // 下载任务成功了
            
        }
        .failure { [weak cell] task in
            cell?.updateProgress(task)
            if task.status == .suspended {
                // 下载任务暂停了
            }
            
            if task.status == .failed {
                // 下载任务失败了
            }
            if task.status == .canceled {
                // 下载任务取消了
            }
            if task.status == .removed {
                // 下载任务移除了
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let task = sessionManager.tasks.safeObject(at: indexPath.row) else { return }
            sessionManager.remove(task, completely: false) { [weak self] _ in
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        sessionManager.moveTask(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


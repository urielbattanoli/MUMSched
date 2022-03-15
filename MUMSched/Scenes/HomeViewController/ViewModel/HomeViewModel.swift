//
//  HomeViewModel.swift
//  MUMSched
//
//  Created by Uriel Battanoli on 3/14/22.
//

import UIKit

enum HomeItem {
    case courses, facultyCourses, blocks, facultyBlocks, users, registration, schedule, logout
    
    static func getItemList() -> [HomeItem] {
        guard let type = User.current?.role else { return [.logout] }
        switch type {
        case .ADMIN: return [.courses, .blocks, .users, .logout]
        case .FACULTY: return [.courses, .facultyCourses, .facultyBlocks, .schedule, .logout]
        case .STUDENT: return [.courses, .registration, .schedule, .logout]
        case .ERROR: return [.logout]
        }
    }
    
    var cellData: HomeCellData {
        switch self {
        case .courses: return HomeCellData(title: "Courses", icon: .checkmark)
        case .facultyCourses: return HomeCellData(title: "Manage", icon: .checkmark)
        case .blocks: return HomeCellData(title: "Blocks", icon: .checkmark)
        case .facultyBlocks: return HomeCellData(title: "Blocks", icon: .checkmark)
        case .users: return HomeCellData(title: "Users", icon: .checkmark)
        case .registration: return HomeCellData(title: "Registration", icon: .checkmark)
        case .schedule: return HomeCellData(title: "Schedule", icon: .checkmark)
        case .logout: return HomeCellData(title: "Log Out", icon: .checkmark)
        }
    }
    
    func present(in view: UIViewController) {
        switch self {
        case .courses:
            CoursesViewController.present(in: view, viewModel: CoursesViewModel())
        case .registration:
            RegistrationViewController.present(in: view, viewModel: RegistrationViewModel())
        default: break
        }
    }
}

protocol HomeViewModelDelegate: BaseProtocolDelegate {
    
    
}

final class HomeViewModel: HomeViewDelegate {
    
    private let list = HomeItem.getItemList()
    
    weak var view: HomeViewModelDelegate?
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return list.count
    }
    
    func cellForItem(at indexPath: IndexPath) -> CellComponent? {
        let data = list[indexPath.row].cellData
        return CellComponent(reuseId: HomeCollectionViewCell.reuseId, data: data)
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        guard let view = view as? UIViewController else { return }
        list[indexPath.row].present(in: view)
    }
}

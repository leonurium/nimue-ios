// 
//  MobileNavInteractor.swift
//  SunibCurhat
//
//  Created by Rangga Leo on 05/03/24.
//  Copyright © 2024 Rangga Leo. All rights reserved.
//

import Foundation

class MobileNavInteractor: MobileNavPresenterToInteractor {
    weak var presenter: MobileNavInteractorToPresenter?
    
    func hitActionApi(path: String) {
        MobileNavService.shared.hitAPI(path: path) { [weak self] (result) in
            switch result {
            case .failure(let err):
                self?.presenter?.failHitActionApi(message: err.localizedDescription)
            case .success(let res):
                if res.success {
                    self?.presenter?.didHitActionApi()
                } else {
                    self?.presenter?.failHitActionApi(message: res.message)
                }
            }
        }
    }
}

//
//  SplashViewModel.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 5/12/21.
//

import Foundation

class SplashViewModel: ObservableObject {
    @Published var hideSplash:Bool = false
    @Published var downloadStatus:DownloadModelStatus = .none
    
    let recognisionController = ImageRecognisionManager()

    init() {
        
    }
    
    func downloadAIModel(onStatus: @escaping (String)->Void) {
        recognisionController.initAutoVision(downloadingModel: { [self] in
            downloadStatus = .loading
            onStatus("Downloading model from the server")
        }, onSuccess: { [self] in
            downloadStatus = .donwload
            onStatus("Model loaded successfully")
        }, onError: { [self] error in
            downloadStatus = .error
            onStatus(error)
        })
    }
}

enum DownloadModelStatus {
    case none
    case loading
    case donwload
    case error
}

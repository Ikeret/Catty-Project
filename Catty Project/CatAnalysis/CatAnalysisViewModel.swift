//
//  CatAnalysisViewModel.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 24.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation
import RxSwift

final class CatAnalysisViewModel {
    
    private let image_id: String
    let image_url: URL?
    
    let displayRows = BehaviorSubject(value: [DetailRowView]())
    let provider = UploadProvider()
    
    init(image_id: String, image_url: URL?) {
        self.image_id = image_id
        self.image_url = image_url
        
        loadAnalisys()
    }
    
    private let disposeBag = DisposeBag()
    
    private func loadAnalisys() {
        provider.getImageAnalysis(image_id: image_id).map { $0.labels }
            .subscribe(onSuccess: { [weak self] labels in
                let displayLabels = labels.map {
                    DetailRowView(leading: $0.Name, trailing: String(format: "%5.2f %%", $0.Confidence))
                }
                self?.displayRows.onNext(displayLabels)
            }).disposed(by: disposeBag)
    }
}

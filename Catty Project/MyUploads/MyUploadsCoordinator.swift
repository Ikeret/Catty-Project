//
//  MyUploadsCoordinator.swift
//  Catty Project
//
//  Created by Сергей Коршунов on 24.07.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import UIKit
import RxSwift

final class MyUploadsCoordinator: BaseCoordinator<CoordinationResult> {
    
    let viewModel = MyUploadsViewModel()
    let viewController: MyUploadsController
    
    let picker = UIImagePickerController()
    
    override init(navigationController: UINavigationController? = nil) {
        viewController = MyUploadsController(viewModel: viewModel)
        super.init(navigationController: navigationController)
    }
    
    override func start() -> Observable<CoordinationResult> {
        picker.delegate = self
        
        viewModel.onFileLoaded.filter { !$0.success }.map { $0.message }
            .subscribe(onNext: { [weak self] in self?.showAlert($0) }).disposed(by: bag)

        viewModel.modelSelected.subscribe(onNext: { [weak self] in self?.showAnalysis($0) })
            .disposed(by: bag)
        
            viewModel.showPicker.subscribe(onNext: { [weak self] in
                self?.showPicker(sourceType: $0)
            }).disposed(by: bag)
        
        return .never()
    }
    
    private func showPicker(sourceType: UIImagePickerController.SourceType) {
        picker.sourceType = sourceType
        viewController.present(picker, animated: true)
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Image Rejected", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .default, handler: nil))
        viewController.present(alert, animated: true)
    }
    
    private func showAnalysis(_ viewModel: CatAnalysisViewModel) {
        let coordinator = CatAnalysisCoordinator(viewModel: viewModel, navigationController: navigationController)
        coordinate(to: coordinator).subscribe().disposed(by: bag)
    }
}

extension MyUploadsCoordinator: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            let size = image.size
            if size.height > 1920 || size.width > 1080 {
                let resizedImage = image.kf.resize(to: CGSize(width: 1920,
                                                              height: 1080),
                                                   for: .aspectFit)
                if let data = resizedImage.jpegData(compressionQuality: 0.8) {
                    viewModel.onFilePicked.onNext(data)
                }
            } else if let data = image.jpegData(compressionQuality: 0.8) {
                viewModel.onFilePicked.onNext(data)
            }
        }
        picker.dismiss(animated: true)
    }
}

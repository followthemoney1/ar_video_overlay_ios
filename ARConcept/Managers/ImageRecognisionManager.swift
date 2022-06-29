//
//  ImageRecognisionManager.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 11/13/20.
//

import Firebase
import UIKit
import SceneKit
import ARKit
import MLKit
import FirebaseFirestoreSwift
import MLKitObjectDetection
import Combine

class ImageRecognisionManager{
    
    let db = Firestore.firestore()
    let firebaseManager = FirebaseManager()
    
    let PRECOGNITION_PERSENTAGE = 0.6
    let objectDetectionOptions = ObjectDetectorOptions()
    
    private var imageLabeler:ImageLabeler?
    var recognitionData: [ARData:UIImage] = [:]
    var latestModelName:String = "";
    
    func initAutoVision(downloadingModel:@escaping ()->Void,
                        onSuccess:@escaping ()->Void,
                        onError:@escaping (String)->Void) {
        
        getLatestModel(done: { modelName in
            
            self.latestModelName = modelName;
            let remoteModel = AutoMLImageLabelerRemoteModel(
                name:self.latestModelName
            )
            
            let downloadConditions = ModelDownloadConditions(
                allowsCellularAccess: true,
                allowsBackgroundDownloading: true
            )
            
            //MARK: check if model is downloaded
            if (ModelManager.modelManager().isModelDownloaded(remoteModel)) {
                self.applyModelOptions(remoteModel: remoteModel)
                onSuccess()
            } else {
                //MARK: downloading model
                downloadingModel()
                let downloadProgress = ModelManager.modelManager().download(
                    remoteModel,
                    conditions: downloadConditions
                )
                self.downloadingModelCallback(onSuccess: { model in
                    //MARK: update downloaded model state
                    self.applyModelOptions(remoteModel: remoteModel)
                    onSuccess()
                }, onError: {er in
                    onError(er)
                })
                
            }
            
        })
        
    }
    
    func applyModelOptions(remoteModel : AutoMLImageLabelerRemoteModel) {
        let options: AutoMLImageLabelerOptions = AutoMLImageLabelerOptions(remoteModel: remoteModel)
        options.confidenceThreshold = NSNumber(value: self.PRECOGNITION_PERSENTAGE)
        objectDetectionOptions.shouldEnableClassification = false
        self.imageLabeler = ImageLabeler.imageLabeler(options: options)
    }
    
    func getLatestModel(done:@escaping (String)->Void){
        if latestModelName.isEmpty {
            db.collection("model_releases").order(by:"last_updated").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    done("")
                } else {
                    ///################
                    ///
                    ///REMOVED BY LICENSE
                    ///
                    ///################
                }
                    let deployedModel = try? querySnapshot!.documents.last?.data(as: DeployedModels.self)
                    print(deployedModel?.model_name);
                    done(deployedModel!.model_name!)
                }
            }
        }else{
            done(latestModelName)
        }
    }
    
    let dispatchQueueML = DispatchQueue(label: "dispatchqueueml1", attributes: .concurrent, autoreleaseFrequency: .inherit) // A Serial Queue
    

    func startUpdatingRecognition(withScene sceneView: UIImage,
                                  _ withConmplection:@escaping(String?,ARData?,UIImage?)->()
    ){
        
        let visionImage =  VisionImage.init(image: sceneView)
        let group = DispatchGroup()
        group.enter()
        if let imageLabeler = imageLabeler {
            imageLabeler.process(visionImage) { [self] lab, error in
                dispatchQueueML.async{
                   
                    guard error == nil, let lab = lab, !lab.isEmpty else {
                        group.leave()
                        withConmplection(nil,nil,nil)
                        return
                    }
                    
                    // MARK: sorted result elements
                    if let el = lab.sorted(by: { $0.confidence > $1.confidence }).first {
                        
                        print("\(self.recognitionData.keys.count) - \(el.text)")
                        
                        if(!recognitionData.keys.contains(where: {$0.keyName == el.text})){
//                            //FirebaseManager.log(message:"loading reference for name = \(el.text)")
                            //MARK: notify that something are found
                            withConmplection(el.text,nil,nil)
                            firebaseManager.getDataForElement(withPath: el.text,complete: { result in
//                                //FirebaseManager.log(message:"loaded image for element = \(el.text)")
                                group.leave()
                                guard (result != nil), ((result?.img) != nil) else{
                                    
                                    withConmplection(nil,nil,nil)
                                    return
                                }
                                //MARK: - download image and give back it
                                loadImage(withUrl:URL(string: result!.img!)!,completionHandler: { image in
                                    if let result = result {
                                       
                                        guard  (result != nil) , (result.downloadVideoUrl != nil) else {
                                            withConmplection(nil,nil,nil)
                                            return;
                                        }
                                        withConmplection(nil,result,image)
                                        recognitionData.updateValue(image, forKey: result)
                                    }else{
                                        ///################
                                        ///
                                        ///REMOVED BY LICENSE
                                        ///
                                        ///################
                                    }
                                  
                                   
                                    return
                                })

                            })
                        }else{
                            let res = recognitionData.first(where: {$0.key.keyName == el.text})
                            print("already exists")
                            group.leave()
                            withConmplection(nil,nil,nil)
                           return
                        }
                    }
                    
                }
            }
        }else{
            group.leave()
            withConmplection(nil,nil,nil)
            print("imageLabeler is nil")
            return
        }
        group.wait()
    }
    
    func updateDetectObject(withScene sceneView: UIImage, _ promise:@escaping(Object?)->() ){
       
        let visionImage =  VisionImage.init(image: sceneView)
        let group = DispatchGroup()
        group.enter()
        let objectDetector = ObjectDetector.objectDetector(options: self.objectDetectionOptions)
        objectDetector.process(visionImage) { [self] detectedObjects, error in
            dispatchQueueML.async {
                
            
            if let firstDetect =  detectedObjects?.first{
                var mostClosest = firstDetect;
                detectedObjects?.forEach({ el in
                    if(mostClosest.frame.height < el.frame.height){
                        mostClosest = el
                    }
                })
                promise(mostClosest)
            }else{
                promise(nil)
            }
            group.leave()
            }
        }
        group.wait()
    }
    
    func loadImage(withUrl: URL, completionHandler:@escaping(UIImage)->()) {
        ///################
        ///
        ///REMOVED BY LICENSE
        ///
        ///################
    }
    
    
    func downloadingModelCallback(onSuccess:@escaping (RemoteModel)->Void,
                                  onError:@escaping (String)->Void){
        
        NotificationCenter.default.addObserver(
            forName: .mlkitModelDownloadDidSucceed,
            object: nil,
            queue: nil
        ) { [weak self] notification in
           
            guard let strongSelf = self,
                  let userInfo = notification.userInfo,
                  let model = userInfo[ModelDownloadUserInfoKey.remoteModel.rawValue]
                    as? RemoteModel
            else {
                return
            }
            onSuccess(model)
            print("downloading model success")
        }
        
        NotificationCenter.default.addObserver(
            forName: .mlkitModelDownloadDidFail,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            
            guard let strongSelf = self,
                  let userInfo = notification.userInfo,
                  let model = userInfo[ModelDownloadUserInfoKey.remoteModel.rawValue]
                    as? RemoteModel
            else { return }
            let error = userInfo[ModelDownloadUserInfoKey.error.rawValue]
            onError(error.debugDescription)
            print("downloading model error \(error)")
        }
    }
    
}

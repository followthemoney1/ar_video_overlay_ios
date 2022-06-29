//
//  ViewController.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 10/25/20.
//

import UIKit
import SceneKit
import ARKit
import MLKit
import Firebase
import UICircularProgressRing
import Combine
import SwiftUI
import AVKit
import ReplayKit
import Foundation

class ARController: UIViewController, ARSCNViewDelegate, ReplayKitScreenRecorder, RPScreenRecorderDelegate {
    
    var onNodeClick:((AVPlayer,ARData)->Void)?
    
    @IBOutlet weak var progressHud: UICircularProgressRing!{
        didSet {
            progressHud.isHidden = true
        }
    }
    
    @IBOutlet weak var cameraLebel: UIButton!{
        didSet{
            cameraLebel.cornerer()
            cameraLebel.setTitle("Screen recording".uppercased(), for: .normal)
            cameraLebel.setTitle("Stop recording".uppercased(), for: .selected)
            cameraLebel.addTarget(self, action: #selector(cameraButtonClick), for:  .touchUpInside)
        }
    }
    //MARK: - view var binding
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var overlayView: UIView!
    
    internal var recorder = RPScreenRecorder.shared(){
        didSet{
            recorder.delegate = self
        }
    }
    
    var configuration: ARImageTrackingConfiguration!
    
    //MARK: - recognition and logic var
    var openedDetailScreen = false
    var unlockRecognition = true
    var canAnimateMove = true
    var canUpdateRecognition = true
    var screenRecording = false
    var recognitionData: [ARData:UIImage] = [:]
    var videoContainers:[String:ARVideoContainer] = [:]
    var arImageReference:Set<ARReferenceImage> = Set<ARReferenceImage>();
    let recognisionController = ImageRecognisionManager()
    var latestCameraSnapshot:UIImage?
    let dispatchQueueML = DispatchQueue(label: "dispatchqueueml", attributes: .concurrent, autoreleaseFrequency: .inherit) // A Serial Queue
    let dispatchQueueDT = DispatchQueue(label: "dispatchqueuedt", autoreleaseFrequency: .inherit) // A Serial Queue
    
    //MARK: - animation var
    var animationInfo: AnimationInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initScene()
    }
    
    func initScene(){
        //        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin,.showSkeletons,.showConstraints,.showCameras,.renderAsWireframe,.showBoundingBoxes,.showConstraints,.showCreases,.showPhysicsFields,.showPhysicsShapes]
        let scene = SCNScene()
        sceneView.scene = scene
        
        sceneView.delegate = self
        // Create a new scene
        self.sceneView.autoenablesDefaultLighting = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        openedDetailScreen = false
        canUpdateRecognition = true
        let configurationAR = ARImageTrackingConfiguration()
        configurationAR.trackingImages = arImageReference
        configurationAR.maximumNumberOfTrackedImages = 2
        
        configuration = configurationAR
        
        sceneView.antialiasingMode = .multisampling2X
        sceneView.isJitteringEnabled = false
        //
        resetTracking()
        initRecognition()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
          
            node.removeFromParentNode()
        }
        
        //MARK: get data for next screen
        self.openedDetailScreen = true
        self.canUpdateRecognition = false
        //MARK: clear all views data
        for  (key,value) in videoContainers{
            value.empty()
        }
        videoContainers.removeAll()
        sceneView.session.pause()
        
        
    }
    
}

//MARK: - image recognition
extension ARController{
    
    func initRecognition(){
        recognisionController.initAutoVision(downloadingModel: { [self] in
            
        }, onSuccess: { [self] in
            updateSnapshot()
            updateDetection()
            updateRecognition()
        }, onError: { error in
            
        })
    }
    
    func updateSnapshot(){
        if(openedDetailScreen){
            return
        }
        
        if(canUpdateRecognition){
            latestCameraSnapshot = self.sceneView.snapshot()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3){ [self] in
            updateSnapshot()
        }
    }
    
    
    //MARK:  Object recognition
    // recognize what images you currently wanna track
    func updateRecognition(){
        
        if(openedDetailScreen){
            return
        }
        
        if (canUpdateRecognition){
            dispatchQueueML.async { [self] in
                processRecognision(snapshot: latestCameraSnapshot!, {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [self] in
                        updateRecognition()
                    }
                })
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){ [self] in
                updateRecognition()
            }
            
        }
    }
    
    // Continuously run ML Kit whenever it's ready. (Preventing 'hiccups' in Frame Rate)
    //MARK:  1. Run Update Process image Recognition.
    func processRecognision(snapshot:UIImage, _ withConmplection:@escaping()->()){
        recognisionController.startUpdatingRecognition(withScene:snapshot){ [self] foundData,arData,image in
            if let el = foundData {
                canUpdateRecognition = false
                showProgressBar()
                infinitProgress()
                changeDebugLabel(text: "LOADING REFERENCE FOR ELEMENT - \(el)")
                //FirebaseManager.log(message: "loading reference \(el)")
                return;
            }
            
            hideProgressBar()
            canUpdateRecognition = true
            
            guard  (arData != nil) ,(image != nil), (arData?.downloadVideoUrl != nil) else {
                withConmplection()
               
                return;
            }
            
            changeDebugLabel(text: "DOWNLOADED - \(String(describing: arData!.name))")
            //MARK:  only reset data if we don't have one
            recognitionData.updateValue(image!, forKey: arData!)
            
            addNewImageToScene()
            changeDebugLabel(text: "ADDED TO SCENE - \(String(describing: arData!.name))")
            withConmplection()
            
        }
        
    }
    
    //MARK:  Object detection
    // recognize what you detect and add simple overlay into object
    func updateDetection(){
        
        if(openedDetailScreen){
            return
        }
        
        if (unlockRecognition){
            dispatchQueueDT.async { [self] in
                processObjectDetection(snapshot: latestCameraSnapshot!,{
                    updateDetection()
                })
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){ [self] in
                //MARK: remove detection views
                if(!overlayView.subviews.isEmpty){
                    for annotationView in overlayView.subviews {
                        annotationView.removeFromSuperview()
                    }
                }
                updateDetection()
            }
            
        }
        
    }
    
    //MARK: run update process detection
    func processObjectDetection(snapshot:UIImage,_ withConmplection:@escaping()->()){
        recognisionController.updateDetectObject(withScene: snapshot){ [self] object in
            DispatchQueue.main.async {
                if (!unlockRecognition || openedDetailScreen){
                    withConmplection()
                    return
                }
                if let object = (object) {
                    
                    let transformedMatrix = transformMatrix(from:overlayView,with: snapshot)
                    
                    let transformedRect = object.frame.applying(transformedMatrix)
                    
                    if let viewWithTag =  self.overlayView.viewWithTag(11){
                        translateUnfillDetectImage( transformedRect,
                                                    to: overlayView)
                        
                    }else{
                        for annotationView in overlayView.subviews {
                            annotationView.removeFromSuperview()
                        }
                        getUnfillDetectImage(
                            transformedRect,
                            to: self.overlayView
                        )
                    }
                    withConmplection()
                }else{
                    withConmplection()
                }
            }
        }
    }
}


//MARK: - progress image detection
extension ARController {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor){
        //FirebaseManager.log(message:"adding element to scene")
        if(openedDetailScreen){
            return
        }
        guard anchor is ARImageAnchor
        else { return }
        
        guard let currentReferenceImageName = ((anchor as? ARImageAnchor)?.referenceImage) else {
            return
        }
        print("size of tracked images \(currentReferenceImageName.name)")
        
        if let arElement = recognitionData.keys.first(where: {$0.name == currentReferenceImageName.name}) {
            //FirebaseManager.log(message:"try to add element = \(arElement.name)")
            addVideoScene(withImage: currentReferenceImageName, didAdd: node,arData: arElement)
        }
    }
    
    private func addVideoScene(withImage referenceImage: ARReferenceImage,didAdd node: SCNNode, arData:ARData){
        changeDebugLabel(text: "loading video..")
        let el = recognitionData.first(where: {$0.key.name == arData.name})
        
        guard (el != nil),(el?.value.cgImage != nil), (referenceImage.name != nil), (arData.downloadVideoUrl != nil) else {
            //FirebaseManager.log(message:"error load video, some reference is empty")
            changeDebugLabel(text: "error load video, some reference is empty..")
            return
        }
        do{
            let image = el!.value.cgImage!
            var addedNode:SCNNode = SCNNode()
            var videoContainer = ARVideoContainer(arData: arData)
            
            print(arData.downloadVideoUrl!)
            let player = AVPlayer(url: arData.downloadVideoUrl!)
            //            player.isMuted = true
            videoContainer.player = player
            //FirebaseManager.log(message:"player created for ref = \(arData.name)")
            //
            try addNodeTo(videoContainer: videoContainer, withArData: arData, referenceImage: referenceImage,overlayImage: image,callback: { [self] videoPlane in
                //FirebaseManager.log(message:"loaded vide success for ref = \(arData.name)")
                let arVC = UIHostingController<ARVideoContainer>(rootView: videoContainer)
                
                videoContainer.hostingController = arVC
                
                let overlayPlane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
                
                ///################
                ///
                ///SOME CODE REMOVED | LICENSE
                ///
                ///################
                addedNode.addChildNode(overlayNode)
                addedNode.addChildNode(videoPlane)
                
                node.addChildNode(addedNode)
                
                videoContainers.updateValue(videoContainer, forKey: referenceImage.name!)
              
            })
        } catch {
            //FirebaseManager.log(message:"error adding node = \(arData.name)")
            showResetTrackingDialog(error: "Error was:\(error.localizedDescription). Would you like to update your session?", yesAction: {
                self.resetTracking()
            })
        }
    }
    
    func addNodeTo(videoContainer:ARVideoContainer, withArData arData:ARData, referenceImage: ARReferenceImage, overlayImage img:CGImage, callback:@escaping (SCNNode)-> Void) throws  {
        do{
            let videoNode = SKVideoNode(avPlayer: videoContainer.player!)
            
            calculateVideoSize(url: arData.downloadVideoUrl!, callback: { size in
                ///################
                ///
                ///SOME CODE REMOVED | LICENSE
                ///
                ///################
                var videoScene:SKScene = SKScene(size:CGSize(width:size.width / videoSizeAspect, height: size.height / videoSizeAspect))
                videoNode.size = CGSize(width:size.width / videoSizeAspect, height: size.height / videoSizeAspect)
                videoScene.scaleMode = .resizeFill
                videoScene.backgroundColor = .black
                // center our video to the size of our video scene
                videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
                videoNode.yScale = -1.0
                videoScene.addChild(videoNode)
                let plane2 = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
                plane2.firstMaterial?.diffuse.contents = videoScene
                let planeNode2 = SCNNode(geometry: plane2)
                planeNode2.eulerAngles.x = -Float.pi / 2
                
                callback(planeNode2)
                
            })
        }
    }
    
    private func calculateVideoSize(url:URL, callback:@escaping (CGSize)-> Void){
        DispatchQueue.global(qos: .background).async {
            //MARK:calculate aspect ration
            let videoAsset = AVURLAsset(url : url)
            let videoAssetTrack = videoAsset.tracks(withMediaType: .video).first
            if let size = videoAssetTrack?.naturalSize{
                callback(size)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first as! UITouch
       
        let viewTouchLocation:CGPoint = touch.location(in: sceneView)
        let hitTestOptions: [SCNHitTestOption : Any] = [
            .boundingBoxOnly: true,
        ]
        guard let result = sceneView.hitTest(viewTouchLocation, options: hitTestOptions).first else {
            print("hitTest: \(viewTouchLocation)")
            return
        }
      
        
        if let nodeName = result.node.name{
            
            let content = videoContainers[nodeName]
            if let content = content{
                print(content.arData.name)
                onNodeClick!(content.player!, content.arData)
            }
        }else{
            for n in result.node.childNodes{
                if let nodeName = n.name{
                    
                    let content = videoContainers[nodeName]
                    if let content = content{
                        print(content.arData.name)
                        onNodeClick!(content.player!, content.arData)
                    }
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = (anchor as? ARImageAnchor)
        else { return }
        guard (imageAnchor.name != nil)
        else{
            return
        }
        DispatchQueue.main.async { [self] in
            if openedDetailScreen {
                if let imageAnchor = anchor as? ARImageAnchor {
                    unlockRecognition = false
                    //sceneView.session.remove(anchor: imageAnchor)
                    return
                }
            }
            
            if imageAnchor.isTracked && !openedDetailScreen{
                if videoContainers.keys.contains(imageAnchor.name!) {
                    videoContainers[imageAnchor.name!]?.play()
                }else{
                    ///################
                    ///
                    ///SOME CODE REMOVED | LICENSE
                    ///
                    ///################
                }
                unlockRecognition = false
                
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                    videoContainers[imageAnchor.name!]?.pause()
                    unlockRecognition = true
                    //                updateDetection()
                }
            }
        }
    }
    
    func addNewImageToScene(){
        unlockRecognition = false
        canUpdateRecognition = false
        for  (arData, image) in recognitionData {
            let arImage = ARReferenceImage(image.cgImage!, orientation: CGImagePropertyOrientation.up, physicalWidth: 1)
            arImage.name = arData.name
            arImageReference.insert(arImage);
        }
       
        configuration.trackingImages = arImageReference
        sceneView.session.run(configuration)
        canUpdateRecognition = true
        unlockRecognition = true
        
    }
    
    func resetTracking(){
        sceneView.session.pause()
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.geometry?.materials.first?.diffuse.contents = nil
            node.removeFromParentNode()
        }
        sceneView.session.run(configuration,options: [.resetTracking, .removeExistingAnchors])
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        ///################
        ///
        ///SOME CODE REMOVED | LICENSE
        ///
        ///################
        if let arError = error as? ARError {
            resetTracking()
        }
    }
}

extension ARController{
    func showResetTrackingDialog(error:String,  yesAction: @escaping ()->Void){
        let alert = UIAlertController(title: "Recognition Error",
                                      message: error,
                                      preferredStyle: .alert)
        
        let no = UIAlertAction(title:"No", style: .destructive) { _ in
            
        }
        
        let yes = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            yesAction()
        })
        
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - progress bar
extension ARController {
    func showProgressBar(){
        DispatchQueue.main.async {
            self.progressHud.isHidden = false;
            self.progressHud.resetProgress()
        }
    }
    
    func infinitProgress(){
        DispatchQueue.main.async {
            self.progressHud.startProgress(to: 100.0, duration:  10.0)
        }
    }
    func setProgress(progress:Double){
        DispatchQueue.main.async {
            self.progressHud.startProgress(to: 100.0, duration:  2.0)
        }
    }
    
    func hideProgressBar(){
        DispatchQueue.main.async {
            self.progressHud.isHidden = true;
        }
    }
}

extension ARController {
    
    func changeDebugLabel(text:String){
        DispatchQueue.main.async {
            print(text)
            self.view.hideAllToasts()
            var style = ToastStyle()
            style.messageColor = UIColor.black.withAlphaComponent(0.8)
            style.messageFont = UIFont.boldSystemFont(ofSize: 12.0)
            self.view.makeToast(text.lowercased(), duration: 1.0, position: .top, style: style)
        }
    }
    
    @objc func cameraButtonClick(_ sender: UIButton){
        if(!screenRecording){
            startRecording(canceled: { [self] in
                screenRecording = false
                cameraLebel.isSelected = screenRecording
            })
        }else{
            stopRecording()
        }
        screenRecording = !screenRecording
        cameraLebel.isSelected = screenRecording
    }
    
    public func getUnfillDetectImage(_ rectangle: CGRect, to view: UIView) {
        DispatchQueue.main.async {
            let recognisionOverlay = RecognitionOverlay();
            let overlay = UIHostingController(rootView: recognisionOverlay.body)
            
            overlay.view.frame = rectangle
            overlay.view.backgroundColor = .clear
            overlay.view.tag = 11
            
            view.addSubview(overlay.view)
        }
    }
    
    public func translateUnfillDetectImage(_ rectangle: CGRect, to view: UIView) {
        DispatchQueue.main.async {[self] in
            if canAnimateMove {
                if let view = view.viewWithTag(11){
                    let overlay = view as UIView
                    canAnimateMove = false
                    UIView.animate(withDuration: 0.4) {
                        overlay.frame = rectangle
                        //MARK: ???????
                        overlay.layoutIfNeeded()
                        
                    } completion: { finished in
                        self.canAnimateMove = true
                    }
                }
            }
        }
    }
    
    public func transformMatrix(from overlayView: UIView,with image:UIImage) -> CGAffineTransform {
        let imageViewWidth = overlayView.frame.size.width
        let imageViewHeight = overlayView.frame.size.height
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        let imageViewAspectRatio = imageViewWidth / imageViewHeight
        let imageAspectRatio = imageWidth / imageHeight
        let scale = (imageViewAspectRatio > imageAspectRatio) ?
            imageViewHeight / imageHeight :
            imageViewWidth / imageWidth
        
        let scaledImageWidth = imageWidth * scale
        let scaledImageHeight = imageHeight * scale
        let xValue = (imageViewWidth - scaledImageWidth) / CGFloat(2.0)
        let yValue = (imageViewHeight - scaledImageHeight) / CGFloat(2.0)
        
        var transform = CGAffineTransform.identity.translatedBy(x: xValue, y: yValue)
        transform = transform.scaledBy(x: scale, y: scale)
        return transform
    }
}

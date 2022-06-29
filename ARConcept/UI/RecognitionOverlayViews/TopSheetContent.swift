//
//  BottomSheetContent.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 1/16/21.
//
import SwiftUI

struct TopSheetContent: View {
    @State private var bottomSheetShown = true
    
    private var name:String
    private var link:String
    private var phone:String
    
    private var instagramLink:String
    private var facebookLink:String
    private var youtubeLink:String
    init(name:String,link:String,phone:String,instagramLink:String,facebookLink:String,youtubeLink:String) {
        self.name = name
        self.link = link
        self.phone = phone
        self.instagramLink = instagramLink
        self.facebookLink = facebookLink
        self.youtubeLink = youtubeLink
    }
    
    var body: some View {
        GeometryReader { geometry in
            TopSheetView(
                isOpen: self.$bottomSheetShown,
                maxHeight: geometry.size.height > geometry.size.width ? geometry.size.height * 0.8 : geometry.size.height
            ) {
                ZStack{
                    BlurView(style: .dark)
                    VStack{
                        Spacer().frame(maxHeight: 80)
                        Group{
                            Text("Info about the object")
                                .bold()
                                .font(.title)
                                .foregroundColor(.white)
                            Divider().background(Color.white)
                            Spacer().frame(maxHeight: 30)
                        }
                        Group{
                            
                            if(!name.isEmpty){
                                HBlock(image: "elipse_icon", sectionName: name)
                            }
                            if(!link.isEmpty){
                                HBlock(image: "earth_icon", sectionName: link).onTapGesture {
                                    openURL(url: link)
                                }
                            }
                            
                            if(!phone.isEmpty){
                                HBlock(image: "phone_icon", sectionName: phone).onTapGesture {
                                    guard let number = URL(string: "tel://" + phone) else { return }
                                    UIApplication.shared.open(number)
                                }
                            }
                        }.padding(EdgeInsets.init(top: 0.0, leading: 40.0, bottom: 0.0, trailing: 40.0))
                        Spacer()
                        Group{
                            HStack{
                                if(!instagramLink.isEmpty){
                                    SIcon(name: "instagram_icon", geometry: geometry).onTapGesture {
                                        openURL(url: instagramLink)
                                    }
                                }
                                if(!facebookLink.isEmpty){
                                    SIcon(name: "fcb_icon", geometry: geometry).onTapGesture {
                                        openURL(url: facebookLink)
                                    }
                                }
                                if(!youtubeLink.isEmpty){
                                    SIcon(name: "youtube_icon", geometry: geometry).onTapGesture {
                                        openURL(url: youtubeLink)
                                    }
                                }
                            }.padding(.bottom,50)
                        }
                        if(geometry.size.height > geometry.size.width){
                            Spacer().frame(maxHeight: 50)
                        }
                    }
                }
            }
        }.edgesIgnoringSafeArea(.all)
    }
    
    func HBlock(image:String,sectionName:String) -> some View {
        Group{
            VStack{
                HStack(alignment: .center){
                    Image(uiImage: UIImage(named: image)!)
                        .fixedSize()
                        .padding(.trailing, 8)
                    Text(sectionName)
                        .lineLimit(1)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity,alignment: .leading)
                }.padding(.top,12)
                Divider().background(Color.white)
                Spacer().frame(minHeight:4,maxHeight: 10)
            }
        }
    }
    
    func SIcon(name:String,geometry:GeometryProxy)-> some View{
        HStack{
            Image(uiImage: UIImage(named: name)!)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.height / 20,
                       height: geometry.size.height / 20,
                       alignment: .center)
            
        }.padding()
    }
    
    func openURL(url:String){
        UIApplication.shared.open(URL(string: url)!)
    }
}

struct TopSheetContent_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TopSheetContent(name: "Name", link: "erf", phone: "",instagramLink: "",facebookLink: "",youtubeLink: "")
                .previewDevice("iPhone 12 Pro Max")
            
            TopSheetContent(name: "Name", link: "com.ua.iu-testtttttttttttttttttttttttttttttttttttttttttttttttt", phone: "066 20 77 555",instagramLink: "",facebookLink: "ferf",youtubeLink: "erferf")
                .previewDevice("iPhone X")
                .preferredColorScheme(.light)
            
        }
        
    }
}

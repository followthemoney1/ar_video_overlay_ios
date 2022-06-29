//
//  LoginUIView.swift
//  ARConcept
//
//  Created by Dmytro Dryl on 10.03.2021.
//

import SwiftUI

struct LoginUIView: View {
    @State var email = ""
    @State var password = ""
    var body: some View {
        NavigationView{
        VStack(spacing: 15){
            Image("logo")
//                .padding(.top, 150)
                .padding(EdgeInsets(top: 150, leading: 0, bottom: 50, trailing: 0))
            TextField("Email",text: $email)
                .frame(height: 48)
                .padding(.horizontal, 20)
                .background(Color(UIColor(hex: 0xFFEAEAEA)))
                .cornerRadius(8)
                .padding(.horizontal, 20)
            SecureField("Password",text: $email)
                .frame(height: 48)
                .padding(.horizontal, 20)
                .background(Color.gray)
                .cornerRadius(8)
                .padding(.horizontal, 20)
            NavigationLink(
                destination: ARView()
            ){
//                Button(action: {}, label: {
                Text("Submit".uppercased())
                    .foregroundColor(.white)
                    .font(.system(size: 24))
            //.frame(width: .infinity, height: 48, alignment: .center)
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color(UIColor(hex: 0xFFF9536B)), Color(UIColor(hex: 0xFFC162AE)),Color(UIColor(hex: 0xFF7F6CF7))]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(8)
            .padding(.horizontal, 20)
        Spacer()
        }.background(Color.black)
        .edgesIgnoringSafeArea(.all)
        }.hideNavigationBar()
        
    }
}

struct LoginUIView_Previews: PreviewProvider {
    static var previews: some View {
        LoginUIView()
    }
}


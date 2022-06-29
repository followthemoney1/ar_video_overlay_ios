//
//  PageTabView.swift
//  ARConcept
//
//  Created by Dmytro Dryl on 12.03.2021.
//

import SwiftUI

struct PageTabView: View {
    @Binding var selection: Int
    
    init(selection: Binding<Int>) {
        self._selection = selection
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(hex: 0xFFFE6472)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(hex: 0xFFEAEAEA)
    }
    
    var body: some View {
        TabView(selection: $selection){
            ForEach(onboardingTabs.indices, id: \.self){ index in
                TabDetailsView(index: index, currentIndex: selection)
            }
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

struct PageTabView_Previews: PreviewProvider {
    static var previews: some View {
        PageTabView(selection: Binding.constant(0))
    }
}

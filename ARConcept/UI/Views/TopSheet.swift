import SwiftUI

fileprivate enum Constants {
    static let radius: CGFloat = 16
    static let indicatorHeight: CGFloat = 20
    static let indicatorWidth: CGFloat = 30
    static let snapRatio: CGFloat = 0.25
    static let minHeightRatio: CGFloat = 0.3
}

struct TopSheetView<Content: View>: View {
    @Binding var isOpen: Bool
    
    let maxHeight: CGFloat
    let minHeight: CGFloat
    let content: Content

    @GestureState private var translation: CGFloat = 0

    private var offset: CGFloat {
        isOpen ? -maxHeight + Constants.indicatorHeight * 5 : minHeight + Constants.indicatorHeight
    }
    private var uiImage: UIImage {
        !isOpen ? UIImage(named: "arrow_up")! : UIImage(named: "arrow_down")!
    }
    
    private var indicator: some View {
//        RoundedRectangle(cornerRadius: Constants.radius)
//            .fill(Color.secondary)
//            .frame(
//                width: Constants.indicatorWidth,
//                height: Constants.indicatorHeight
//        ).onTapGesture {
//            self.isOpen.toggle()
//        }
        
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .frame(width: Constants.indicatorWidth, height:  Constants.indicatorHeight)
    }

    init(isOpen: Binding<Bool>, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self.minHeight = maxHeight * Constants.minHeightRatio
        self.maxHeight = maxHeight
        self.content = content()
        self._isOpen = isOpen
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                self.content
                self.indicator
                    .padding()
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .cornerRadius(Constants.radius,corners:[.bottomLeft,.bottomRight])
            .frame(height: geometry.size.height, alignment: .top)
            .offset(y: min(self.offset + self.translation,0))
            .animation(.interactiveSpring())
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    let snapDistance = self.maxHeight * Constants.snapRatio
//                    guard abs(value.translation.height) > snapDistance else {
//                        return
//                    }
                    self.isOpen = value.translation.height < 0
                }
            )
        }
    }
}

struct TopSheetView_Previews: PreviewProvider {
    static var previews: some View {
        TopSheetView(isOpen: .constant(true), maxHeight: 600) {
            Rectangle().fill(Color.red)
        }.previewDevice("iPhone 12 Pro Max")
    }
}

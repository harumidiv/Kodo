//
//  CreatureDetailView.swift
//  Kodo
//
//  Created by 佐川 晴海 on 2022/10/21.
//

import SwiftUI

struct CreatureDetailView: View {
    @Binding var isShowDetail: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                let length = min(geometry.size.width, geometry.size.height)
                VStack {
                    HStack {
                        Button(action: {
                            isShowDetail.toggle()
                        }, label: {
                            Image(systemName: "xmark")
                                .font(Font.system(size: 28, weight: .regular))
                                .padding()
                        })
                        Spacer()
                    }

                    ImageSliderView()
                        .background(.red)
                }

//                Image("human_1")
//                    .resizable()
//                    .frame(width: length, height: length)
            }
        }
    }
}

struct CreatureDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CreatureDetailView(isShowDetail: .constant(true))
    }
}

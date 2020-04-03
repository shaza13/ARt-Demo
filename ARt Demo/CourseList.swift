//
//  CourseList.swift
//  ARt Demo
//
//  Created by Salman on 3/24/20.
//  Copyright © 2020 shaza. All rights reserved.
//

import SwiftUI

struct CourseList: View {
    var body: some View {
        HStack {
            ScrollView(.horizontal) {
                HStack(spacing: 30) {
                CourseView()
                //CourseView()
                }
            }
            .frame(height: 1000)
            .padding(.top, 30)
        }
    }                         
}

struct CourseList_Previews: PreviewProvider {
    static var previews: some View {
        CourseList()
    }
}

struct CourseView: View {
    @State var show = false
    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 30.0) {
            Text("Painted in a mental  hospital blah blah van gogh")
            Text("This lens will transform to blah blah")
            }
            .padding(30)
            .frame(maxWidth: show ? .infinity : 290, maxHeight: show ? .infinity : 270, alignment: .top)
            .offset(y: show ? 460 : 0)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 20)
            .opacity(show ? 1 : 0)
            
            VStack {
                Image("wheat")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 430, height: 270)
                Text("Vincent van Gogh")
                    .font(.system(size: 24, weight: .bold))
                    .frame(width: 300, alignment: .leading)
                    .foregroundColor(.black)
                    .padding(.top, 50)
                
                
                Text("wheat field in cypress".uppercased())
                    .frame(width: 300, alignment: .leading)
                    .foregroundColor(.black)
                    .padding(.top, 10)
                Spacer()
            }
                //.padding(.top, 20)
                
                .padding(.horizontal, 20)
                //.frame(width: show ? 420 : 340, height: show ? 900 : 380)
                .frame(maxWidth: 340, maxHeight: show ?  800 : 440)
                .background(Color(.white))
                .cornerRadius(30)
                .shadow(color: .gray, radius: 10, x: 0, y: 20)
               
                .onTapGesture {
                    self.show.toggle()
            }
            
        }
         .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
        .edgesIgnoringSafeArea(.all)
    }
}

//
//  RecipeRowView.swift
//  KivySwiftLink-GUI
//
//  Created by MusicMaker on 23/05/2022.
//

import SwiftUI
import Combine
import RealmSwift

struct RecipeRowView: View {

    @ObservedRealmObject var recipe_data: KivyRecipeData

    var body: some View {

        Toggle(isOn: $recipe_data.last_selection) {
                Text(recipe_data.name)
                    .frame(maxWidth: .infinity)
                    .padding(4)
                    
            }.toggleStyle(.switch)
                .border(Color.gray)

    }
}

struct RecipeRowView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeRowView(recipe_data: KivyRecipeData())
    }
}

//
//  EditItemDetailsView.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 8/27/22.
//

import SwiftUI

struct EditItemDetailsView: View {
    @Binding var marketItem: MarketItemV2
        
    init(marketItem: Binding<MarketItemV2>) {
        self._marketItem = marketItem
    }
    
    var prices: [Int] {
        let currentPrice = $marketItem.price.wrappedValue
        var prices: [Int] = [currentPrice]
        
        for i in 0..<10 {
            let higherPrice = currentPrice + i + 1
            let lowerPrice = currentPrice - i - 1
            
            prices.append(higherPrice)
            
            if lowerPrice > 0 {
                prices.insert(lowerPrice, at: 0)
            }
        }
        
        return prices
    }
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    FormTitle("Headline")
                    TextField("Enter headline...", text: $marketItem.headline)
                }
                
                VStack(alignment: .leading) {
                    FormTitle("Selling Location")
                    TextField("Enter zip code of the selling location...", text: $marketItem.location.zipCode)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    FormTitle("Item Category")
                    Picker(selection: $marketItem.itemType) {
                        ForEach(MarketItemV2Type.allCases, id: \.self) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    } label: {
                        Text("Select the item category...")
                    }
                    .pickerStyle(.segmented)
                    
                }
            }
            
            Section {
                VStack(alignment: .leading) {
                    HStack {
                        FormTitle("Price")
                        
                        Spacer()
                        
                        Text("quick set: $")
                            .font(.subheadline)
                            .foregroundColor(Color(uiColor: AppTheme.Colors.mainAccent.uiColor))
                        
                        TextField("$", value: $marketItem.price, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: 60)
                    }
                    
                    Picker("Select a New Price", selection: $marketItem.price) {
                        ForEach(prices, id: \.self) {
                            Text("$\($0)")
                        }
                    }
                    .labelStyle(.titleOnly)
                    .pickerStyle(.wheel)
                }
            }
            
            Section {
                VStack(alignment: .leading) {
                    FormTitle("Manufacturer")
                    TextField("Enter manufacturer...", text: $marketItem.manufacturer)
                }
                
                VStack(alignment: .leading) {
                    FormTitle("Model")
                    TextField("Enter model...", text: $marketItem.model)
                }
                
                if $marketItem.itemType.wrappedValue == .disc {
                    VStack(alignment: .leading) {
                        FormTitle("Plastic")
                        TextField("Enter plastic type...", text: $marketItem.plastic)
                    }
                    
                    VStack(alignment: .leading) {
                        FormTitle("Weight (grams)")
                        TextField("Enter disc weight...", value: $marketItem.weight, format: .number)
                    }
                }
            }
            
            Section {
                FormTitle("Description")
                TextEditor(text: $marketItem.description)
            }
        }
    }
}

struct FormTitle: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.headline)
            .foregroundColor(Color(uiColor: AppTheme.Colors.mainAccent.uiColor))
    }
}

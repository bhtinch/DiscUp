//
//  SellNewItemView.swift
//  DiscUpV2
//
//  Created by Benjamin Tincher on 6/8/22.
//

import SwiftUI

struct SellNewItemView: View {
    @ObservedObject var viewModel: SellNewItemViewModel

    var body: some View {
        VStack {
            Spacer()

            HStack {
                Spacer()

                Spacer()

                Text("Create New Item")
                    .bold()
                    .foregroundColor(AppTheme.Colors.mainAccent.color)

                Spacer()

                Button("Cancel") {
                    viewModel.send(.cancelTapped)
                }
            }
            .padding(.top, 8)
            .padding(.trailing, 20)

            SellNewPageTabView()

            PageControlButtonStackView()
        }
        .environmentObject(viewModel)
    }
}

struct PageControlButtonStackView: View {
    @EnvironmentObject var newItemViewModel: SellNewItemViewModel

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Spacer()

            BackButtonView()
                .tint(Color(AppTheme.Colors.mainAccent.uiColor))
                .disabled(newItemViewModel.pageIndex == 0)

            Spacer()

            NextButtonView()
                .tint(Color(AppTheme.Colors.mainAccent.uiColor))
                .disabled(
                    {
                        switch newItemViewModel.pageIndex {
                        case 0:
                            return newItemViewModel.item.headline.isEmpty ||
                            newItemViewModel.item.location.zipCode.isEmpty ||
                            newItemViewModel.item.description == "Please add a description..."

                        case 1:
                            return newItemViewModel.item.images.isEmpty

                        default: return false
                        }
                    }()
                )

            Spacer()
        }
        .padding()
    }
}

struct BackButtonView: View {
    @EnvironmentObject var newItemViewModel: SellNewItemViewModel

    private var buttonText: String {
        ButtonText.allCases[newItemViewModel.pageIndex].backText
    }

    var body: some View {
        Button(action: {
            switch newItemViewModel.pageIndex {
            case 0:
                break

            default:
                newItemViewModel.pageIndex -= 1
            }
        }, label: {
            Text(buttonText)
                .bold()
        })
    }
}

struct NextButtonView: View {
    @EnvironmentObject var newItemViewModel: SellNewItemViewModel

    private var buttonText: String {
        ButtonText.allCases[newItemViewModel.pageIndex].nextText
    }

    var body: some View {
        Button(action: {
            switch newItemViewModel.pageIndex {
            case 2:
                newItemViewModel.send(.saveTapped)

            default:
                newItemViewModel.pageIndex += 1
            }
        }, label: {
            Text(buttonText)
                .bold()
        })
    }
}

fileprivate enum ButtonText: CaseIterable {
    case pageOne
    case pageTwo
    case pageThree

    var backText: String { "Back" }

    var nextText: String {
        switch self {
        case .pageOne:      return "Add Photos"
        case .pageTwo:      return "Preview"
        case .pageThree:    return "Save"
        }
    }

    var title: String {
        "Create New Item"
    }
}

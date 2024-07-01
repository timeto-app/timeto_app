import SwiftUI
import shared

private let checkboxSize = 21.0
private let checklistItemMinHeight = HomeView__MTG_ITEM_HEIGHT

struct ChecklistView: View {

    @EnvironmentObject private var nativeSheet: NativeSheet

    @State private var vm: ChecklistVM

    private let onDelete: () -> Void
    private let bottomPadding: CGFloat

    //

    @State private var vScroll = 0

    init(
        checklistDb: ChecklistDb,
        onDelete: @escaping () -> Void,
        bottomPadding: CGFloat = 0
    ) {
        self._vm = State(initialValue: ChecklistVM(checklistDb: checklistDb))
        self.onDelete = onDelete
        self.bottomPadding = bottomPadding
    }

    var body: some View {

        VMView(vm: vm) { state in

            VStack {

                HStack(alignment: .top) {

                    ScrollViewWithVListener(showsIndicators: false, vScroll: $vScroll) {

                        VStack {

                            ForEach(state.checklistUI.itemsUI, id: \.item.id) { itemUI in

                                Button(
                                    action: {
                                        itemUI.toggle()
                                    },
                                    label: {
                                        HStack {

                                            Image(systemName: itemUI.item.isChecked ? "checkmark.square.fill" : "square")
                                                .foregroundColor(c.white)
                                                .font(.system(size: checkboxSize, weight: .regular))
                                                .padding(.trailing, 10)

                                            Text(itemUI.item.text)
                                                .padding(.vertical, 4)
                                                .foregroundColor(.white)
                                                .font(.system(size: HomeView__PRIMARY_FONT_SIZE))
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .frame(minHeight: checklistItemMinHeight)
                                    }
                                )
                            }
                        }

                        Spacer()
                    }

                    let stateUI = state.checklistUI.stateUI
                    let stateIconResource: String = {
                        if stateUI is ChecklistStateUI.Completed {
                            return "checkmark.square.fill"
                        }
                        if stateUI is ChecklistStateUI.Empty {
                            return "square"
                        }
                        if stateUI is ChecklistStateUI.Partial {
                            return "minus.square.fill"
                        }
                        fatalError()
                    }()
                    Button(
                        action: {
                            stateUI.onClick()
                        },
                        label: {
                            VStack {

                                Image(systemName: stateIconResource)
                                    .foregroundColor(Color.white)
                                    .font(.system(size: checkboxSize, weight: .regular))
                                    .frame(height: checklistItemMinHeight)

                                Button(
                                    action: {
                                        nativeSheet.show { isEditPresented in
                                            ChecklistFormSheet(
                                                checklistDb: state.checklistUI.checklistDb,
                                                isPresented: isEditPresented,
                                                onDelete: {
                                                    onDelete()
                                                }
                                            )
                                        }
                                    },
                                    label: {
                                        Image(systemName: "pencil")
                                            .foregroundColor(Color.white)
                                            .font(.system(size: checkboxSize, weight: .regular))
                                            .frame(height: checklistItemMinHeight)
                                    }
                                )

                                Spacer()
                            }
                        }
                    )
                }
                .padding(.horizontal, H_PADDING - 2)
            }
        }
    }
}

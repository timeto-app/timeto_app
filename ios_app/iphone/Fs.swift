import SwiftUI

class Fs: ObservableObject {

    @Published var items = [Fs__Item<AnyView>]()

    func show<Content: View>(
        @ViewBuilder content: @escaping (Binding<Bool>) -> Content
    ) {
        items.append(
            Fs__Item(
                content: { isPresented in
                    AnyView(content(isPresented))
                }
            )
        )
    }
}

extension View {

    func attachFs() -> some View {
        modifier(Fs__Modifier())
    }
}

private let fsAnimation = Animation.easeInOut(duration: 0.20)

///
///

struct Fs__Item<Content: View>: View, Identifiable {

    @ViewBuilder var content: (Binding<Bool>) -> Content

    @EnvironmentObject private var fs: Fs
    @State private var isPresented = false

    let id = UUID().uuidString

    var body: some View {

        ZStack {

            if isPresented {
                content($isPresented)
                    .transition(.opacity)
                    .ignoresSafeArea()
                    .onDisappear {
                        fs.items.removeAll {
                            $0.id == id
                        }
                    }
            }
        }
        .animation(fsAnimation, value: isPresented)
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .onAppear {
            isPresented = true
        }
    }
}

private struct Fs__Modifier: ViewModifier {

    @StateObject private var fs = Fs()

    func body(content: Content) -> some View {
        ZStack {
            content
            ForEach(fs.items) { wrapper in
                wrapper
            }
        }
        .environmentObject(fs)
    }
}

///

struct Fs__Header<Content: View>: View {

    let scrollToHeader: Int
    @ViewBuilder var content: () -> Content

    private var bgAlpha: Double {
        (Double(scrollToHeader) / 30).limitMinMax(0, 1)
    }

    var body: some View {

        // .bottom for divider
        ZStack(alignment: .bottom) {

            content()

            DividerBg()
                .opacity(bgAlpha)
                .padding(.horizontal, H_PADDING)
        }
        .safeAreaPadding(.top)
    }
}


struct Fs__HeaderAction: View {

    let title: String
    let actionText: String
    let scrollToHeader: Int
    let onCancel: () -> Void
    let onDone: () -> Void

    private var bgAlpha: Double {
        (Double(scrollToHeader) / 30).limitMinMax(0, 1)
    }

    var body: some View {

        Fs__Header(
            scrollToHeader: scrollToHeader
        ) {

            VStack(alignment: .leading) {

                Button(
                    action: {
                        onCancel()
                    },
                    label: {
                        Text("Cancel")
                            .foregroundColor(c.textSecondary)
                            .font(.system(size: 15, weight: .light))
                            .padding(.leading, H_PADDING)
                    }
                )
                .padding(.bottom, 4)

                HStack {

                    Text(title)
                        .font(.system(size: 26, weight: .semibold))
                        .padding(.leading, H_PADDING)

                    Spacer()

                    Button(
                        action: {
                            onDone()
                        },
                        label: {
                            Text(actionText)
                                .foregroundColor(c.white)
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(roundedShape.fill(c.blue))
                        }
                    )
                    .padding(.trailing, H_PADDING)
                }
                .padding(.bottom, 8)
            }
        }
    }
}

import SwiftUI
import Combine
import shared

extension View {

    func attachTimerFullScreenView() -> some View {
        modifier(TimerFullScreen__ViewModifier())
    }
}

///
///

private struct TimerFullScreen__ViewModifier: ViewModifier {

    @State private var isPresented = false

    private let statePublisher: AnyPublisher<KotlinBoolean, Never> = FullScreenUI.shared.state.toPublisher()

    func body(content: Content) -> some View {

        content
                /// Скрывание status bar в .statusBar(...)
                .fullScreenCover(isPresented: $isPresented) {
                    TimerFullScreen__FullScreenCoverView()
                }
                .onReceive(statePublisher) { newValue in
                    isPresented = newValue.boolValue
                }
    }
}

private struct TimerFullScreen__FullScreenCoverView: View {

    @State private var vm = FullScreenVM()

    var body: some View {

        VMView(vm: vm, stack: .ZStack()) { state in

            Color.black.edgesIgnoringSafeArea(.all)
                    .statusBar(hidden: true)

            VStack(spacing: 0) {

                VStack(spacing: 0) {

                    Button(
                            action: {
                                vm.toggleIsTaskCancelVisible()
                            },
                            label: {
                                Text(state.title)
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                            }
                    )

                    if (state.isTaskCancelVisible) {

                        Button(
                                action: {
                                    vm.cancelTask()
                                },
                                label: {
                                    Text(state.cancelTaskText)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 8)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                            .background(
                                                    RoundedRectangle(cornerRadius: 99, style: .circular)
                                                            .fill(.blue)
                                            )
                                            .padding(.vertical, 12)
                                }
                        )
                    }
                }

                let timerData = state.timerData

                if let subtitle = timerData.subtitle {
                    Text(subtitle)
                            .font(.system(size: 26, weight: .heavy))
                            .tracking(5)
                            .foregroundColor(timerData.subtitleColor.toColor())
                            .padding(.top, 36)
                            .offset(y: 3)
                }

                Text(timerData.title)
                        .font(.system(size: 70, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(timerData.titleColor.toColor())
                        .opacity(0.9)

                if timerData.subtitle != nil || !state.isCountdown {
                    Button(
                            action: {
                                vm.restart()
                            },
                            label: {
                                Text("Restart")
                                        .font(.system(size: 25, weight: .light))
                                        .foregroundColor(.white)
                                        .tracking(1)
                            }
                    )
                            .padding(.top, 10)
                }

                let checklistUI = state.checklistUI
                // todo test .clipToBounds()
                ZStack(alignment: .bottom) {

                    ///
                    /// Compact Tasks Mode

                    VStack(spacing: 0) {

                        if !state.isTaskListShowed, let checklistUI = checklistUI {

                            VStack {

                                ScrollView {

                                    ForEach(checklistUI.itemsUI, id: \.item.id) { itemUI in

                                        Button(
                                                action: {
                                                    itemUI.toggle()
                                                },
                                                label: {
                                                    Text(itemUI.item.text + (itemUI.item.isChecked ? "  ✅" : ""))
                                                            .padding(.vertical, 4)
                                                            .foregroundColor(.white)
                                                            .font(.system(size: 18))
                                                }
                                        )
                                    }

                                    Spacer()
                                }
                            }
                        }

                        if !state.isTaskListShowed {

                        }
                    }
                }
                        .frame(height: .infinity)

                HStack(spacing: 0) {

                    let menuIconAlpha = 0.5

                    Button(
                            action: {
                                //
                            },
                            label: {
                                Image(systemName: "pencil.circle")
                                        .foregroundColor(Color.white)
                                        .opacity(menuIconAlpha)
                                        .font(.system(size: 30, weight: .thin))
                                        .frame(maxWidth: .infinity)
                            }
                    )

                    Button(
                            action: {
                                FullScreenUI.shared.close()
                            },
                            label: {
                                Image(systemName: "xmark.circle")
                                        .foregroundColor(Color.white)
                                        .opacity(menuIconAlpha)
                                        .font(.system(size: 30, weight: .thin))
                                        .frame(maxWidth: .infinity)
                            }
                    )
                }
                        .frame(width: .infinity)
            }
        }
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
                .onDisappear {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
    }
}

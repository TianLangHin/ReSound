//
//  MainMenuViews.swift
//  ReSound
//
//  Extracted window content for the main menu so it can be previewed in Canvas.
//

import SwiftUI

struct MainMenuContentView: View {
    @Binding var viewingState: MainMenuState
    var speechRec: SpeechRec
    var onClinicianTap: () -> Void

    var body: some View {
        VStack(spacing: ReSoundLayout.sectionSpacing) {
            Text("ReSound Hearing Test")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text("Test your hearing using spatial audio with the Apple Vision Pro")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: ReSoundLayout.stackSpacing) {
                Button {
                    viewingState = .chooseTest
                } label: {
                    Text("Start Hearing Test")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: 500)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)

                Button(action: onClinicianTap) {
                    Text("Clinician View")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: 500)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)

                Button {
                    // Go to view history page which is not currently implemented.
                } label: {
                    Text("View History")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: 500)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
            }
            .padding(ReSoundLayout.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: ReSoundLayout.cardCornerRadius)
                    .fill(.ultraThinMaterial)
            )
        }
        .padding(.vertical, ReSoundLayout.outerVerticalPadding)
        .task {
            let _ = await speechRec.authoriseRequest()
        }
    }
}

struct ChooseEnvironmentView: View {
    @Binding var viewingState: MainMenuState
    @Binding var selectedOption: Int
    @Binding var hearingTest: HearingTest
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: ReSoundLayout.sectionSpacing) {
            HStack {
                Button {
                    viewingState = .main
                } label: {
                    Label("Back", systemImage: "chevron.backward")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .buttonStyle(.bordered)
                .accessibilityHint("Returns to the main menu")
                Spacer()
            }

            Text("Select Environment")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Choose your immersive testing environment")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: ReSoundLayout.stackSpacing) {
                HStack(spacing: ReSoundLayout.stackSpacing) {
                    presetButton(buttonIndex: 0, title: "TEST")
                    presetButton(buttonIndex: 1, title: "Train Station")
                }
                HStack(spacing: ReSoundLayout.stackSpacing) {
                    presetButton(buttonIndex: 2, title: "Do Not Use")
                    presetButton(buttonIndex: 3, title: "Shuffle")
                }
            }
            .padding(ReSoundLayout.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: ReSoundLayout.cardCornerRadius)
                    .fill(.ultraThinMaterial)
            )

            Button(action: onNext) {
                Text("Next")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(minWidth: 150)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedOption == -1)
        }
        .padding(ReSoundLayout.cardPadding)
    }

    @ViewBuilder
    private func presetButton(buttonIndex: Int, title: String) -> some View {
        let isSelected = selectedOption == buttonIndex
        Button {
            selectedOption = buttonIndex
            var selectedPreset = buttonIndex
            if selectedPreset > 1 {
                selectedPreset = Int.random(in: 0...1)
            }
            hearingTest = Presets.hearingTests[selectedPreset]
        } label: {
            Text(title)
                .font(.title3)
                .fontWeight(isSelected ? .semibold : .regular)
                .frame(maxWidth: 500)
                .padding(.vertical, 12)
        }
        .buttonStyle(.bordered)
        .tint(isSelected ? Color.accentColor : Color.secondary)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#if DEBUG
#Preview("Main menu") {
    MainMenuContentView(
        viewingState: .constant(.main),
        speechRec: SpeechRec(),
        onClinicianTap: {}
    )
}

#Preview("Choose environment") {
    ChooseEnvironmentView(
        viewingState: .constant(.chooseTest),
        selectedOption: .constant(0),
        hearingTest: .constant(Presets.hearingTests[0]),
        onNext: {}
    )
}
#endif

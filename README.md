# ReSound: Visualising Everyday Sound on the Apple Vision Pro

A practical, portable, and accessible spatial hearing application built for the Apple Vision Pro,
bringing realistic, immersive, and self-directed spatial audio experiences
to raise awareness about challenges in hearing loss and increase engagement in preliminary hearing loss screening.
This solution is made for this emerging need of [National Acoustic Laboratories](https://www.nal.gov.au) (NAL)
in the UTS subject **40006 iOS Industry Studio**,
as an alternative to their existing spatial audio delivery solutions.

The GitHub repository for this project solution can be found [here](https://github.com/TianLangHin/ReSound).

## Student Team

* Tian Lang Hin (Student ID: 24766127, Team Lead)
* Duong Anh Tran (Student ID: 24775456, Backend Lead)
* Isabella Watt (Student ID: 24843322, Testing Lead)
* Chloe Truong (Student ID: 24961967, Assets Lead)
* Jessie Rachman (Student ID: 25306200, Design Lead)
* Yu-Han Chang (Student ID: 14542423, Human Interface Guidelines Lead)

## Frameworks and Tools Used

The following frameworks native to Apple are used for the application's development.
* [`SwiftUI`](https://developer.apple.com/documentation/swiftui)
  forms the basis of all windows and UI element configurations,
  allowing the application to be built with intuitive components in line with other visionOS applications.
* [`RealityKit`](https://developer.apple.com/documentation/realitykit/)
  is used to manage and configure the positioning of visual assets
  and their corresponding spatial audio components to build the immersive environments.
* [`Speech`](https://developer.apple.com/documentation/speech)
  is used to enable speech recognition and the triggering of button selections via voice control.
* [`AVFoundation`](https://developer.apple.com/documentation/avfoundation/)
  is used to load media files into the environment if required.

For the creation of visual 3D assets,
**Reality Composer Pro** is used to orient imported USDZ files to adjust their positioning relative to the user.
Additionally, the assets used to display the three preset environment themes are sourced as follows:
* For the **home** environment, the `Home.usdz` file was created in **Blender**.
* For the **cafe** environment, the `Cafe_Resized.usdz` file was sourced from **ConversaCoach**,
  a previous project made available to us courtesy of our subject coordinator.
* For the **train station** environment, the `Station_Resized.usdz` file was converted from FBX format
  and originally sourced from [TurboSquid](https://www.turbosquid.com/3d-models/subway-station-modern-1-726486),
  purchased by **National Acoustic Laboratories** for the purpose of this project.

## Code and Folder Structure

The code repository is based off of the [playing spatial audio](https://developer.apple.com/documentation/visionOS/playing-spatial-audio-in-visionos)
introductory visionOS sample provided by the Apple Developer documentation.
As a result, within the main `ReSound` folder, there are four folders: `App`, `Models`, `Resources`, and `Views`.
The `Models` folder is the only one which was not initially in the initial visionOS sample repository.

* The `App` folder contains the main application information crucial
  for XCode to recognise settings of the repository including asset and basic configuration information,
  as well as `EntryPoint.swift`, which is the SwiftUI `Scene` instance that gets launched upon startup
  acting as the entry point for the application.
* The `Models` folder contains the data structures used to represent fundamental elements of the application
  and classes managing the application's interaction with required backend frameworks and other functionalities.
  * `HearingTest.swift` and `CustomTest.swift` define the internal data structures for
    hearing experiences and customised audio experiences adjustable by the clinician using the application respectively.
    The suffix "Test" on the ends of the structures and all files do not indicate regulatory standardisation or validation,
    but instead serve as a shorter, convenient way to refer to the method through which this application displays *spatial hearing experiences*.
  * `Presets.swift` provide the configurations for the preset **home**, **cafe**, and **train station** environments
    available as part of the **"Start Experience"** option from the main menu.
  * `SpeechRec.swift` implements the functionality of voice-activated buttons throughout the application,
    accessing the underlying `AVFoundation` framework to record voice commands through the Apple Vision Pro.
  * `StringExtension.swift` implements helper functions to assist the usage of voice commands to activate buttons,
    to account for the different ways `AVFoundation` will naturally detect and convert word sequences.
  * `PersistStorage.swift` implements the wrapper used to store `CustomTest` instances
    using the `UserDefaults` framework persistently on the Apple Vision Pro device,
    allowing clinicians to save settings of customised hearing experiences.
* The `Resources` folder contains all the visual and audio assets used in the application,
  placed in sub-folders named `Visuals` and `Sounds` respectively.
* The `Views` folder contains the SwiftUI `Scene` and SwiftUI `View` definitions used in the application.
  * `HearingTestScene.swift` is the main SwiftUI `Scene` instance through which a *spatial hearing experience* is delivered.
    It uses the `RealityKit` framework and the immersive space natively available to the Apple Vision Pro
    to place visually identifiable sources in a realistic, immersive environment,
    while also managing the logical flow of a *spatial hearing experience* where a set of audio plays,
    followed by the user being prompted with a question, and this cycle continuing until all questions have been answered,
    at which a score will be displayed.
    The spatially anchored audio sources and the environment backgrounds are generated via the `AudioSourceView` and `SkyboxView` structures respectively.
  * `AudioSourceView.swift` defines the `AudioSourceView` structure,
    which contains a visual representation (this can be invisible, a static USDZ model, an animated USDZ model, or an MP4 video)
    and a spatial audio component using the `SpatialAudioComponent` resource natively available to the visionOS framework.
    It keeps track of changes in the parent `HearingTestScene` such that if it is the target audio of the current question,
    a yellow cone will appear on top of it to indicate it being the correct focus.
    It is kept up to date without forcing redeployment of the immersive space via the `update` closure attached to a `RealityView` instance
    contained within the `AudioSourceView` structure.
  * `SkyboxView.swift` defines the `SkyboxView` structure, which deploys the immersive environment as well as the surrounding background images.
  * `ClinicianScene.swift` provides the windows through which clinicians can add, modify, and save custom *spatial hearing experiences*.
  * `HistoryScene.swift` provides the windows through which clinicians can view the scores of previous attempts of *spatial hearing experiences*.
  * `InstructionScene.swift` implements the side panel that appears to provide instructions to the user before starting the *spatial hearing experience*.
  * `HeightAdjustmentScene.swift` implements the auxiliary panel that allows users to adjust the height of the environment relative to their viewpoint,
    in case the `RealityView` instances are spawned too high up or too low relative to the user's eye level.

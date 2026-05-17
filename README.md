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

## Credits

The visual and audio assets used in this project outside of the aforementioned files in the **Frameworks and Tools Used** section
were sourced from other sites including [Sketchfab](https://sketchfab.com/) and [Pixabay](https://pixabay.com/).
All assets downloaded from Sketchfab are covered by the Creative Commons (CC) License 4.0,
while the assets downloaded from Pixabay are covered by their [Content License](https://pixabay.com/service/license-summary/).
While not all of the following assets were directly used in the final iteration of our project,
the assets that have been accessed and downloaded at some point during the development of this project are listed in the following sub-sections.

### 3D Model Assets

* "ANIMATED OLDER MAN WITH BEARD WEARING SHORT" (https://skfb.ly/onqC6)
  by 360SMS is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Buisness man (With talking animation)" (https://skfb.ly/oAvKU)
  by art.piskov is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Dennis Posed 004 - Male Standing Business Model" (https://skfb.ly/6SArT)
  by Renderpeople is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Free 018 Kana Sitting" (https://skfb.ly/o6pXV)
  by ddd is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Govinda Walking 3d model fts" (https://skfb.ly/oSHPI)
  by Sunny khude 3d model is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Housewife Model" (https://skfb.ly/6oGVR)
  by hong227 is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Indian Office Woman" (https://skfb.ly/oLUUo)
  by Nodeaxis Interactive is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "JEONG SEUN_240316" (https://skfb.ly/oSpLo)
  by COTTA is licensed under Creative Commons Attribution-NonCommercial (http://creativecommons.org/licenses/by-nc/4.0/).
* "JEONG SEUN 34" (https://skfb.ly/oT9Ar)
  by COTTA is licensed under Creative Commons Attribution-NonCommercial (http://creativecommons.org/licenses/by-nc/4.0/).
* "Joe Having A Meeting" (https://skfb.ly/oPBDY)
  by myzatulsarah is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Jon Sitting (2)" (https://skfb.ly/oPAB9)
  by myzatulsarah is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Juhi chawala maushi walking 3d models fts" (https://skfb.ly/prAUu)
  by Sunny khude 3d model is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Kay" (https://skfb.ly/oSwxC)
  by Gen AI Guy is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Man Sitting" (https://skfb.ly/6zoQq)
  by apexpro is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* “Man Sitting Idle” (https://skfb.ly/oQqqJ)
  by DNAelite is licensed under Free Standard (https://sketchfab.com/licenses).
* "Mr Man Walking" (https://skfb.ly/6SsDF)
  by Instinto Ideal Studio is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Oiiaioooooiai Cat" (https://skfb.ly/prRXD)
  by Zhuier is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "OldMan Ernest" (https://skfb.ly/oHPpy)
  by grs is licensed under Creative Commons Attribution-ShareAlike (http://creativecommons.org/licenses/by-sa/4.0/).
* "Scanned animated walking man" (https://skfb.ly/osJUu)
  by 1-3D.com is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Sitting Talking (1)" (https://skfb.ly/oSCC9)
  by atierayunus is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Sophia Animated 003 - Animated 3D Woman" (https://skfb.ly/6SO7O)
  by Renderpeople is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Start Walking (1)" (https://skfb.ly/pECIA)
  by Leakkha11 is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* “Subway Station Modern 1” (https://www.turbosquid.com/3d-models/subway-station-modern-1-726486)
  by MS_RAY is licensed under Standard License (https://www.turbosquid.com/licensing)
* "Talking Lily" (https://skfb.ly/pC8Ky)
  by rexerincltd.scockburn is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Talking On A Cell Phone" (https://skfb.ly/oTSAX)
  by azreenphoebe99 is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Talking - Puan Mastura" (https://skfb.ly/oUSwT)
  by p143467 is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Talking (9)" (https://skfb.ly/pESRn)
  by Leakkha11 is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Woman" (https://skfb.ly/pB79N)
  by Grauwolf is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Walk-japanese-man" (https://skfb.ly/opsvu)
  by ddd is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).
* "Women Sitting Animated" (https://skfb.ly/oQqpR)
  by DNAelite is licensed under Creative Commons Attribution (http://creativecommons.org/licenses/by/4.0/).

### Audio Assets
* AllSounds24. (2018, April 19). Cup put down on table sound effect.
  [Video]. YouTube. https://www.youtube.com/watch?v=-m1jX83mMT8
* Bureau of Meteorology. (2026, January 6). National Weather Forecast 6 January 2026: Heatwaves spread across much of Australia.
  [Video].YouTube. https://www.youtube.com/watch?v=hFuxNx6GGS0
* "Car drive by" (https://pixabay.com/sound-effects/film-special-effects-car-drive-by-268509/)
  by FreeSoundsxx is under Pixabay Content License (https://pixabay.com/service/license-summary/)
* "Dog Barking in Distant" (https://pixabay.com/sound-effects/nature-dog-barking-in-distant-502561/)
  by dbsound is under Pixabay Content License (https://pixabay.com/service/license-summary/)
* "Footstep on wood foley" (https://pixabay.com/sound-effects/household-footstep-on-wood-foley-6398/)
  by martian (Freesound) is under Pixabay Content License (https://pixabay.com/service/license-summary/)
* "Jazzy Tender Loop" (https://pixabay.com/sound-effects/musical-jazzy-tender-loop-312714/)
  by SergeQuadrado is under Pixabay Content License (https://pixabay.com/service/license-summary/)
* Learn English with Bob the Canadian. (2024, September 24). Learn English Phone Phrases.
  [Video]. YouTube. https://www.youtube.com/watch?v=u40ZKHC98k0
* Nicks videos. (2016, July 25). Two People Talking.
  [Video]. YouTube. https://www.youtube.com/watch?v=6oYFKwCZpfk
* Pizza Hunter Sound. (2022, December 5). Eating Dinner Ambience Sound Effect.
  [Video]. YouTube. https://www.youtube.com/watch?v=aN3qlNl3G48
* "Plates Set Down" (https://pixabay.com/sound-effects/household-plates-set-down-69502/)
  by davjanus (Freesound) is under Pixabay Content License (https://pixabay.com/service/license-summary/)
* RazendeGijs. (2021, December 31). Cat meow sound effect.
  [Video]. YouTube. https://www.youtube.com/watch?v=IeUfgC-RHZ0
* "restaurant ambience" (https://pixabay.com/sound-effects/people-restaurant-ambience-24720/)
  by sarahmariealice (Freesound) is under Pixabay Content License (https://pixabay.com/service/license-summary/)
* Sound Effect Database. (2024, June 12). Drink Stir With Ice Sound Effect.
  [Video]. YouTube. https://www.youtube.com/watch?v=a1RBGnT1PbU
* Sydney_Trains1. (2023, April 9). T8 Central train board | Central to Macarthur | Macarthur via airport stations |.
  [Video] YouTube. https://www.youtube.com/watch?v=yphnUGTnIlo
* "Talking people" (https://pixabay.com/sound-effects/people-talking-people-6368/)
  by szalonegacie (Freesound) is under Pixabay Content License (https://pixabay.com/service/license-summary/)
* "Tea kettle whistling" (https://pixabay.com/sound-effects/household-tea-kettle-whistling-69415/)
  by reconsider59 (Freesound) is under Pixabay Content License (https://pixabay.com/service/license-summary/)
* The Social Skills Teacher. (2016, March 10). Joining Group Conversations - Unexpected.
  [Video]. YouTube. https://www.youtube.com/watch?v=UuY8L_NiNbY
* "Train Station 3" (https://pixabay.com/sound-effects/city-train-station-3-53789/)
  by Fission9 (Freesound) is under Pixabay Content License (https://pixabay.com/service/license-summary/)
* TSydneyRail Spotters. (2023, January 1). Sydney Trains DVA: "Please mind the gap".
  [Video]. YouTube. https://www.youtube.com/watch?v=jF4QIpX4_cc&list=PL23y0236wGOHm4jUB8neD2xe353bC-8xh&index=4

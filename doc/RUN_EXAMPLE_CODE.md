# Run the Navigation Flutter example code

* The example code is under the `example` folder of this repository
## NB Maps Access Key
A secret access key is required before running the example, otherwise you will see an error like this
```
!Using MapView requires calling Nextbillion.initNextbillion(String accessKey) before inflating or creating NBMap Widget.
```
## Android
* Clone this repo
* Open the project in Android Studio or Your Flutter Development Platforms
* `cd example` folder in the terminal
* Run the project with command `flutter run --dart-define ACCESS_KEY=YOUR_ACCESS_KEY`, replace the YOUR_ACCESS_KEY with your own
 ![image](https://github.com/nextbillion-ai/nb-navigation-flutter/assets/100656364/e433cc97-16cd-4097-aeb0-d9da0f82382e)
* The command output should be something like:
  ```
    Launching lib/main.dart on PEHM00 in debug mode...

    Upgrading build.gradle
    Running Gradle task 'assembleDebug'...                             16.8s
    ✓  Built build/app/outputs/flutter-apk/app-debug.apk.
  ```
## iOS
* Clone this repo
* Open `example/ios/Runner.xcworkspace` in XCode
* Select the Runner and changet the Bundle identifier to your own. On the `signing & capabilities` tab change the team to your own.
  ![image](https://github.com/nextbillion-ai/nb-navigation-flutter/assets/100656364/d02610bd-565d-48bd-86c7-520a5c92b644)
* Go back to your Flutter Development Platforms
* Running `cd example` folder in the terminal
* Run the project with command `flutter run --dart-define ACCESS_KEY=YOUR_ACCESS_KEY`, replace the YOUR_ACCESS_KEY with your own
 ![image](https://github.com/nextbillion-ai/nb-navigation-flutter/assets/100656364/e433cc97-16cd-4097-aeb0-d9da0f82382e)
* The command output should be something like:
  ```
    Automatically signing iOS for device deployment using specified development team in Xcode project: xxx
    Running Xcode build...                                                  
     └─Compiling, linking and signing...                         3.6s
    Xcode build done.                                           12.8s
    Installing and launching...                                        22.0s
    Syncing files to device iPhone...                             47ms

  ```

## Snap shot
![IMG_0297](https://github.com/nextbillion-ai/nb-navigation-flutter/assets/100656364/33c54eff-3ebe-4c17-ac0b-40d927aa5833)



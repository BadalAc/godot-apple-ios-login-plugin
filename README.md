# SwiftGodot Apple Sign-In Library ✨

<div align="center">
  
  ![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
  ![Godot](https://img.shields.io/badge/Godot-478CBF?style=for-the-badge&logo=GodotEngine&logoColor=white)
  ![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)
  
  **A lightweight, easy-to-integrate library for implementing Apple Sign-In with Godot 4.3+ on iOS**
</div>

<p align="center">
  <img src="https://raw.githubusercontent.com/godotengine/godot-website/master/assets/press/icon_curve.svg" width="100" alt="Godot Icon"/>
  <img src="https://developer.apple.com/assets/elements/icons/sign-in-with-apple/sign-in-with-apple-black-100x100.png" width="100" alt="Sign in with Apple"/>
</p>

## 📂 Project Structure

```
Bin/
  ios/
    MyLibrary.framework/
      Info.plist
      MyLibrary
    SwiftGodot.framework/
      Info.plist
      SwiftGodot
```

## 🛠️ Building the Framework

To build the framework, run the following commands:

```sh
chmod +x build.sh
./build.sh ios release
```

After running the script, you will find the built files inside the `Bin/` directory.

## 🔗 Setting Up in Godot

1. **Create a new file named `MyLibrary.gdextension` in the root directory (`res://`).**
2. Paste the following content into the file:

```ini
[configuration]
entry_symbol = "swift_entry_point"
compatibility_minimum = "4.3"

[libraries]
ios.release = "res://Bin/ios/MyLibrary.framework"

[dependencies]
ios.release = {"res://Bin/ios/SwiftGodot.framework" : ""}
```

### 📌 Important:
- **This file is required to link Godot to iOS.**
- Copy the framework files into `res://Bin/ios/` before running Godot.

## 🔥 Godot Script Example

Here's a sample **Godot script (`GDScript`)** demonstrating how to use Apple Sign-In:

```gdscript
extends Control

@onready var apple_button = $Panel/AppleLoginButton
@onready var error_label = $Panel/MarginContainer/ErrorLabel

# Variable for MyLibrary
var my_library = null

# Plugin configuration for Apple Sign-In
const APPLE_PLUGIN_NAME := "MyLibrary"  # Matches your Swift extension name

func _ready() -> void:
    initialize_plugins()
    apple_button.pressed.connect(_on_apple_button_pressed)

func initialize_plugins() -> void:
    if my_library == null && ClassDB.class_exists(APPLE_PLUGIN_NAME):
        my_library = ClassDB.instantiate(APPLE_PLUGIN_NAME)
        # Connect to signals defined in MyLibrary.swift
        my_library.connect("Output", _on_apple_output_signal)
        my_library.connect("Signout", _on_apple_signout_signal)
        print("MyLibrary initialized via ClassDB")
    else:
        push_error("Apple Sign-In extension not found: %s" % APPLE_PLUGIN_NAME)
        error_label.show()
        error_label.text = "Apple Sign-In unavailable"

func _on_apple_button_pressed() -> void:
    if my_library:
        if my_library.has_method("signIn"):
            my_library.signIn()
    else:
        error_label.show()
        push_error("Apple plugin not initialized")
        error_label.text = "Apple Sign-In error"

func _on_apple_output_signal(output: String) -> void:
    # Handle the Output signal from MyLibrary
    error_label.show()
    error_label.text = output

func _on_apple_signout_signal(signout: String) -> void:
    # Handle the Signout signal from MyLibrary
    error_label.show()
    error_label.text = signout
```

## 🔄 Rebuilding & Updating the Plugin

If you modify the Swift code, follow these steps to rebuild and update:

```sh
chmod +x build.sh
./build.sh ios release
```

Then, copy the updated files from `Bin/` to your Godot project and repeat the setup process.

## 🌟 Features

- Easy integration with Godot 4.3+
- Seamless Apple Sign-In implementation
- Simple signals for handling authentication results
- Lightweight and optimized for iOS

## 🙌 Acknowledgements

<div align="center">
  
  ### Special Thanks To
  
  [<img src="https://yt3.ggpht.com/ytc/placeholder" width="60" style="border-radius:50%">](https://www.youtube.com/@codingwithnobody)
  
  **[@codingwithnobody](https://www.youtube.com/@codingwithnobody)**
  
  *For inspiration and guidance*
</div>

## 🎮 Try My Games!

<div align="center">
  <h1>See this plugin in action and support my work!</h1>
  
  <table>
    <tr>
      <td align="center">
        <img src="https://play-lh.googleusercontent.com/l-usbpBq0OuurA1e9FJSlnnVVa1HQpcUCMv_RlM63zk7jGUvXRC10Z9hDuqA83DTU6A=w240-h480-rw)" width="120" height="120"><br>
        <b>Ludo App Gold</b><br>
        <a href="https://apps.apple.com/np/app/ludo-app-gold/id6504749605">
          <img src="https://developer.apple.com/app-store/marketing/guidelines/images/badge-download-on-the-app-store.svg" width="120">
        </a>
      </td>
      <td align="center">
        <img src="https://play-lh.googleusercontent.com/placeholder_android](https://play-lh.googleusercontent.com/l-usbpBq0OuurA1e9FJSlnnVVa1HQpcUCMv_RlM63zk7jGUvXRC10Z9hDuqA83DTU6A=w240-h480-rw" width="120" height="120)" width="120" height="120"><br>
        <b>Ludo World War</b><br>
        <a href="https://play.google.com/store/apps/details?id=com.ludosimplegame.ludo_simple">
          <img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" width="140">
        </a>
      </td>
    </tr>
  </table>
  
  ⭐ **Your ratings & reviews help tremendously!** ⭐
  
  Help us grow and bring you more amazing features!
</div>

---

<p align="center">
  Enjoy coding & gaming! 🎮🚀
</p>

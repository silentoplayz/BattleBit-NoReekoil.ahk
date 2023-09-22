# AutoHotkey Recoil Control Script

## Table of Contents
- [Introduction](#introduction)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
  - [Installation](#installation)
  - [Customization](#customization)
  - [Running the Script](#running-the-script)
- [Configuration](#configuration)
- [Hotkeys](#hotkeys)
- [INI File Usage](#ini-file-usage)
- [Important Notes](#important-notes)
- [Contributions and Support](#contributions-and-support)
- [Disclaimer](#disclaimer)

## Introduction

This AutoHotkey script is designed to assist with controlling recoil and various aspects of gameplay in a specific game. It offers features such as adjusting recoil, controlling fire rate, and modifying other settings to improve accuracy and performance. However, please exercise caution and ensure you're adhering to the terms of service of the game you're using this script with.

## Features

- **Recoil Control:** The script helps mitigate weapon recoil by adjusting mouse movements in real-time.
- **Fire Rate Control:** Modify the delay between shots to optimize firing rate and accuracy.
- **Configuration Settings:** Customize the script's behavior to suit your playstyle and preferences.
- **First Shot Compensation:** Apply special adjustments to the first shot to enhance accuracy.
- **Dynamic Script Naming:** The script generates unique names based on the game and settings for better organization.

## Prerequisites

Before using the script, make sure you have the following prerequisites:

- [AutoHotkey](https://www.autohotkey.com/): AutoHotkey must be installed on your system to run the script.

## Getting Started

1. **Installation**:
   - Ensure you have AutoHotkey installed on your system. You can download it from [AutoHotkey's official website](https://www.autohotkey.com/).
   - Copy the script contents provided above and paste them into a new text file using a text editor.

2. **Customization**:
   - Customize the script's configuration settings according to your gaming preferences. You can modify settings such as:
     - **Recoil Adjustments (pixelX and pixelY):** Modify these values to control horizontal and vertical recoil adjustments.
     - **Fire Rate (shotsPerMinute):** Adjust the number of shots fired per minute for optimal fire rate.
     - **Delay Increments (delayIncrement):** Fine-tune the delay between shots by changing this value.
     - **Period (period):** Change the time period for adjustments and actions.
     - **Pixel Increment (pixelIncrement):** Modify the amount by which pixel adjustments change.
     - **First Shot Compensation (firstShotEnabled, firstShotCompensationX, firstShotCompensationY):** Enable or disable adjustments specifically for the first shot fired.

3. **Running the Script**:
   - Save the text file with a `.ahk` extension. For example, you can name it `RecoilControl.ahk`.
   - Double-click the saved `.ahk` file to run the script.
   - The script will only become active when the specified game window process is running.

## Configuration

- The script's default configuration values can be found in the "Configuration" section of the script.
- You have the flexibility to adjust settings like recoil adjustments, fire rate, delay increments, and more to fine-tune your gameplay experience.
- Additionally, the script provides the option to load and save settings from/to an INI file, allowing you to customize settings for different weapons or scenarios.

## Hotkeys

- The script defines various hotkeys to trigger actions such as adjusting recoil, modifying settings, and more. These hotkeys are active only when the specified game window process is running. Below is a list of some predefined hotkeys and their actions:

  - **Hotkey:** Action
  - Numpad0: Load settings from an INI file.
  - Numpad1: Save settings to an INI file.
  - Numpad2: Toggle recoil control on/off.
  - Numpad3: Toggle first shot compensation on/off.
  - Numpad5: Cycle through different weapons and adjust settings.
  - Numpad6: Decrease pixel adjustments.
  - Numpad9: Increase pixel adjustments.
  - Numpad7: Decrease delay between shots.
  - Numpad8: Increase delay between shots.
  - NumpadSub: Decrease the time period for adjustments.
  - NumpadAdd: Increase the time period for adjustments.
  - PgUp: Increase vertical pixel adjustment.
  - PgDn: Decrease vertical pixel adjustment.
  - Del: Decrease horizontal pixel adjustment.
  - End: Increase horizontal pixel adjustment.
  - LButton: Handle recoil compensation while mouse buttons are held down.

## INI File Usage

- The script allows you to load and save settings to an INI file, making it easy to customize and switch between different configurations.
- To load settings from an INI file:
   1. Press the `Numpad0` hotkey.
   2. Enter the desired weapon or configuration name when prompted.
   3. The script will load settings from the specified INI section.
- To save settings to an INI file:
   1. Press the `Numpad1` hotkey.
   2. Enter the desired weapon or configuration name when prompted.
   3. The script will save the current settings to the specified INI section.

## Important Notes

- Use this script responsibly and ensure that its usage complies with the terms of service of the game you're playing.
- Always exercise caution when using scripts from external sources to avoid potential security risks or unintended consequences.
- Keep in mind that altering your gameplay experience might lead to ethical considerations, including potential violations of fair play and anti-cheat mechanisms.
- Be aware that AutoHotkey scripts might not work seamlessly with all games due to variations in game engines and anti-cheat implementations.

## Contributions and Support

- If you're interested in contributing to or seeking support for this script, please refer to the [repository](https://github.com/your-username/repo-name) for additional information.

## Disclaimer

This script is provided "as-is." The developers and contributors of this script take no responsibility for its usage or any consequences arising from its use. Please use this script at your own discretion and risk.

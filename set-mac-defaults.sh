#!/bin/env sh

# other mac settings
ln -s /Applications/Xcode.app/Contents/Applications/ /Applications/In\ Xcode
mkdir /Applications/CoreServices/
ln -s /System/Library/CoreServices/Applications/DVD\ Player.app/ /Applications/CoreServices/DVD\ Player.app
ln -s /System/Library/CoreServices/Applications/Feedback\ Assistant.app/ /Applications/CoreServices/Feedback\ Assistant.app
ln -s /System/Library/CoreServices/WidgetKit\ Simulator.app/ /Applications/CoreServices/WidgetKit\ Simulator.app

# global
defaults write -g NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false

# Trackpad
defaults write "com.apple.AppleMultitouchTrackpad" "ActuateDetents" -int 0
defaults write "com.apple.AppleMultitouchTrackpad" "Clicking" -bool True
defaults write "com.apple.AppleMultitouchTrackpad" "ForceSuppressed" -bool True
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadThreeFingerDrag" -bool True
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadThreeFingerHorizSwipeGesture" -int 0
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadThreeFingerTapGesture" -int 2
defaults write "com.apple.AppleMultitouchTrackpad" "TrackpadThreeFingerVertSwipeGesture" -int 0

defaults write "com.apple.FolderActionsDispatcher" "folderActionsEnabled" -bool True

# Dictionary
defaults write "com.apple.Dictionary" "text size multiplier" -float 1.44000005722
defaults write com.apple.DictionaryServices "DCSActiveDictionaries" -array "com.apple.dictionary.ja.Daijirin" "com.apple.dictionary.ja-en.WISDOM" "com.apple.dictionary.ODE" "com.apple.dictionary.AppleDictionary" "/System/Library/Frameworks/CoreServices.framework/Frameworks/DictionaryServices.framework/Resources/Wikipedia.wikipediadictionary"
defaults write com.apple.DictionaryServices "DCSDictionaryPrefs" -dict "com.apple.dictionary.ja.Daijirin" '{ "orientation-vertical" = 1; }'

# FontBook
defaults write "com.apple.FontBook" "FBCustomSampleString" -string 'Lorem ipsum dolor sit amet, consectetur adipisici elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

「ではみなさんは、そういうふうに川だと言いわれたり、乳の流れたあとだと言われたりしていた、このぼんやりと白いものがほんとうは何かご承知ですか」先生は、黒板につるした大きな黒い星座の図の、上から下へ白くけぶった銀河帯のようなところを指しながら、みんなに問いをかけました。

@main
struct EntryPoint {
  func main() async throws {
    print("swift code: \(123)")
  }
}'

# Music
defaults write "com.apple.Music" "userWantsPlaybackNotifications" -bool False
defaults write "com.apple.Music" "miniPlayerAlwaysOnTop" -bool False
defaults write "com.apple.Music" "dontWarnWhenEditingMultiple" -bool True
defaults write "com.apple.Music" "encoderName" -string "Lossless Encoder"
osascript -e '
tell application "Music"
	activate
	set newPreset to make new EQ preset
	set name of newPreset to "Eargasm Explosion"
	set band 1 of newPreset to 3
	set band 2 of newPreset to 6
	set band 3 of newPreset to 9
	set band 4 of newPreset to 7
	set band 5 of newPreset to 6
	set band 6 of newPreset to 5
	set band 7 of newPreset to 7
	set band 8 of newPreset to 4
	set band 9 of newPreset to 11
	set band 10 of newPreset to 8
	set preamp of newPreset to -6.6
	set current EQ preset to newPreset

	set secPreset to make new EQ preset
	set name of secPreset to "Perfect"
	set band 1 of secPreset to 3
	set band 2 of secPreset to 6
	set band 3 of secPreset to 9
	set band 4 of secPreset to 7
	set band 5 of secPreset to 6
	set band 6 of secPreset to 5
	set band 7 of secPreset to 7
	set band 8 of secPreset to 9
	set band 9 of secPreset to 11
	set band 10 of secPreset to 8
	set preamp of secPreset to -7.1
	set current EQ preset to secPreset
end tell'

# 共有フォルダ内で.DS_Storeを生成しない
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Dock
defaults write com.apple.dock show-recents -bool false
for _ in {1..3}; do
	# Dockに空白を追加する（3個）
	defaults write com.apple.dock persistent-apps -array-add '{ "tile-type" = "spacer-tile";}'
done
killall Dock

# Finder
defaults write com.apple.finder QLEnableTextSelection -bool true

# Screen Capture
defaults write "com.apple.screencapture" "type" -string "heic"
defaults write "com.apple.screencapture" "location" -string "~/Pictures/Screen Shots"

# Screen saver
defaults -currentHost write com.apple.screensaver idleTime -int 180

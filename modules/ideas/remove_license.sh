#!/run/current-system/sw/bin/bash
# https://gist.github.com/Hedgehogues/123eb27100608d248cf8370e666b29ce/

# declare array of tools
declare -a tools=(
    "DataGrip"
    "CLion"
    "Rider"
    "WebStorm"
    "GoLand"
    "PyCharm"
)

for tool in "${tools[@]}"
do
    /run/current-system/sw/bin/rm -rf ~/.config/JetBrains/$tool*/eval
    /run/current-system/sw/bin/rm -rf ~/.config/JetBrains/$tool*/options/usage.statistics.xml
    /run/current-system/sw/bin/rm -rf ~/.config/JetBrains/$tool*/options/other.xml
    /run/current-system/sw/bin/rm -rf ~/.config/JetBrains/$tool*/options/recentProjects.xml
    /run/current-system/sw/bin/rm -rf ~/.config/JetBrains/$tool*/options/updates.xml
    /run/current-system/sw/bin/rm -rf ~/.config/JetBrains/$tool*/options/usage.statistics.xml
    /run/current-system/sw/bin/rm -rf ~/.java/.userPrefs/jetbrains
    /run/current-system/sw/bin/rm -rf ~/.java/.userPrefs/prefs.xml        
    /run/current-system/sw/bin/rm -rf ~/.java/.userPrefs/.user.lock.user
    /run/current-system/sw/bin/rm -rf ~/.java/.userPrefs/.userRootModFile.user
done
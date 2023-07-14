#!/bin/sh

cd $1
echo "BearEmotes_defaultpack = {"
find . -type f -name "*.tga" -exec sh -c 'trim() { x="${1#"$2"}"; echo "${x%"$3"}"; }; trimmed=$(trim $1 "./" ".tga"); echo "    [\"${trimmed}\"] = \"Interface\\\\\\AddOns\\\\\\BearEmotes\\\\\\Emotes\\\\\\${trimmed}.tga:32:32\","' _ {} \;
echo "};\n"
echo "BearEmotes_emoticons = {"
find . -type f -name "*.tga" -exec sh -c 'trim() { x="${1#"$2"}"; echo "${x%"$3"}"; }; trimmed=$(trim $1 "./" ".tga"); echo "    [\"${trimmed}\"] = \"${trimmed}\","' _ {} \;
echo "};\n\nBearEmotes_animation_metadata = {};\nBearEmotes_ExcludedSuggestions = {};"
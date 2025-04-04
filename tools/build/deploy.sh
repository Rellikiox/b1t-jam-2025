BASE_DIR=$(realpath "$(dirname "$(dirname "$(dirname "$0")")")")

TEMP_DIR=$(mktemp -d)

unzip "$BASE_DIR/builds/lovejs/survive-the-beat-lovejs.zip" -d "$TEMP_DIR" > /dev/null

INDEX_HTML="$TEMP_DIR/survive-the-beat/index.html"

sed -i '/<h1>survive-the-beat<\/h1>/d' "$INDEX_HTML"
sed -i '/<footer>/,/<\/footer>/d' "$INDEX_HTML"

(cd $TEMP_DIR && zip -r "$BASE_DIR/builds/lovejs/survive-the-beat-lovejs.zip" "survive-the-beat" > /dev/null)

rm -rf "$TEMP_DIR"

butler push "$BASE_DIR/builds/win32/survive-the-beat-win32.zip" rellikiox/survive-the-beat:win32
butler push "$BASE_DIR/builds/macos/survive-the-beat-macos.zip" rellikiox/survive-the-beat:macos
butler push "$BASE_DIR/builds/lovejs/survive-the-beat-lovejs.zip" rellikiox/survive-the-beat:lovejs
butler push "$BASE_DIR/builds/love/survive-the-beat.love" rellikiox/survive-the-beat:love

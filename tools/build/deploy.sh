BASE_DIR=$(realpath "$(dirname "$(dirname "$(dirname "$0")")")")

TEMP_DIR=$(mktemp -d)

unzip "$BASE_DIR/builds/lovejs/realm-of-the-bat-lovejs.zip" -d "$TEMP_DIR" > /dev/null

INDEX_HTML="$TEMP_DIR/realm-of-the-bat/index.html"

sed -i '/<h1>realm-of-the-bat<\/h1>/d' "$INDEX_HTML"
sed -i '/<footer>/,/<\/footer>/d' "$INDEX_HTML"

(cd $TEMP_DIR && zip -r "$BASE_DIR/builds/lovejs/realm-of-the-bat-lovejs.zip" "realm-of-the-bat" > /dev/null)

rm -rf "$TEMP_DIR"

butler push "$BASE_DIR/builds/win32/realm-of-the-bat-win32.zip" rellikiox/realm-of-the-bat:win32
butler push "$BASE_DIR/builds/macos/realm-of-the-bat-macos.zip" rellikiox/realm-of-the-bat:macos
butler push "$BASE_DIR/builds/lovejs/realm-of-the-bat-lovejs.zip" rellikiox/realm-of-the-bat:lovejs
butler push "$BASE_DIR/builds/love/realm-of-the-bat.love" rellikiox/realm-of-the-bat:love

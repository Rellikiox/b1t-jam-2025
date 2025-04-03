BASE_DIR="$(dirname "$(dirname "$(dirname "$0")")")"

butler push "$BASE_DIR/builds/win32/survive-the-beat-win32.zip" rellikiox/survive-the-beat:win32
butler push "$BASE_DIR/builds/macos/survive-the-beat-macos.zip" rellikiox/survive-the-beat:macos
butler push "$BASE_DIR/builds/lovejs/survive-the-beat-lovejs.zip" rellikiox/survive-the-beat:lovejs
butler push "$BASE_DIR/builds/love/survive-the-beat.love" rellikiox/survive-the-beat:love

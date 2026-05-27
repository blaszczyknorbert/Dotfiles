export DOCKER_HOST="unix://${XDG_RUNTIME_DIR}/docker.sock"
export MOZ_ENABLE_WAYLAND=1
export MOZ_WEBRENDER=1
export _JAVA_AWT_WM_NONREPARENTING=1
export MINA_PATH="${HOME}/mina"
export PATH="${HOME}/.local/bin${PATH:+:${PATH}}"
export TERMINAL=foot
export EDITOR=nvim
export BROWSER=firefox
export FILE_MANAGER=nautilus

if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  while mina-river-launch; do sleep 1; done
fi

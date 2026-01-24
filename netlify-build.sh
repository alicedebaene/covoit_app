#!/usr/bin/env bash
set -euo pipefail

# Installer Flutter (stable) dans l’environnement Netlify
if [ ! -d "$HOME/flutter" ]; then
  git clone --depth 1 https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
fi

export PATH="$HOME/flutter/bin:$PATH"

flutter --version

# Activer le web + télécharger les artefacts web
flutter config --enable-web
flutter precache --web

# Dépendances + build
flutter pub get
flutter build web --release

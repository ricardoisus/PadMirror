# Convenções
Branches feat/* ou fix/*. Commits semânticos pequenos. PRs com problema, comportamento, validação e limitações. Não integrar milestones bloqueados por hardware.
Gate: scripts/build.sh, scripts/test.sh (XCTest com Xcode; mesmos casos comportamentais compilados diretamente com Command Line Tools), git diff --check e revisão dos hunks. macOS 14+; toolchain Xcode 16+ ou Command Line Tools compatíveis. Sem dependências externas na prova USB.
GPL-3.0-or-later em todo código original. Não copiar licença proprietária do template. Não commitar build, logs, identificadores pessoais de dispositivos ou secrets.

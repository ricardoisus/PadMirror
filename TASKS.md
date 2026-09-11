# TASKS
## Fase atual
Milestone 1 — aguardando validação física USB. Iniciado em 2026-09-10.
## Concluído nesta sessão
- [x] Templates adaptados; documentação canônica e GPL-3.0-or-later.
- [x] Repositório GitHub privado ricardoisus/PadMirror; main e branch feat/usb-preview-proof.
- [x] CoreMediaIO, discovery external/muxed com wireless desabilitado, PreviewLayer direto e NSWindow real.
- [x] Seleção, observação de hotplug, tentativa manual e sessão em fila serial.
- [x] Debug/Release compilados e bundle ad-hoc verificado localmente (Swift 6.3.3, SDK macOS 26).
- [x] Seis casos comportamentais passaram via runner CLT; XCTest depende de Xcode completo e será executado no CI.
- [x] Janela inicial inspecionada visualmente; não foi observada imagem de iPad.
## Próximos passos
- [ ] Usuário conectar iPad físico; seguir docs/MANUAL_TEST_PLAN.md.
- [ ] Confirmar imagem sem QuickTime, Freeform/Pencil, rotação, Meet e reconexão.
- [ ] Só após gate físico: concluir M1, endurecer USB no M2 e integrar AirPlay no M3.
## Bloqueios
Build is complete. Physical iPad validation required.
Não usar commit “working USB iOS screen mirroring” antes da prova real.
## Decisões e descobertas
PreviewLayer primeiro. isPreviewing e inputPriority indisponíveis no macOS; sessionRunning não prova frames. Inspeção local encontrou fonte external/muxed com transporte othr; removido filtro estrito USB que a descartava. Nenhuma engine AirPlay incluída. Áudio off. Métricas reais de latência/rotação ainda pendentes. Repositório privado durante desenvolvimento, conforme template; publicação open source ainda pendente.

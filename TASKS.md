# TASKS
## Fase atual
Milestone 3 — integração wireless autorizada pelo usuário após confirmação visual USB.
## Validação USB
- [x] Usuário relatou funcionamento; agente observou Freeform real na janela PadMirror.
- [x] Captura direta por AVCaptureSession/PreviewLayer; não usa captura de janela nem automação QuickTime.
- [x] CI USB e testes passaram.
- [ ] Comparação de latência, rotação, reconexão e Meet ainda exigem testes separados.
- Nota: havia um processo QuickTime aberto durante a inspeção visual; repetir com ele fechado para completar o cenário de independência física. O código não depende dele.
## Em andamento
→ Popyachsa pinado como submodule; C ABI in-process em NSView da mesma janela.
- [x] Build da engine, código por ativação e seleção explícita USB/AirPlay implementados.
- [x] CI USB e wireless passaram no PR #2 (run 34599799897).
- [x] Em 2026-09-12, anúncio Bonjour resolvido com senha obrigatória na versão atual; receptor pronto na UI.
- [x] 24 verificações comportamentais e verificação de 17 factories/8 símbolos/assinaturas passaram localmente.
- [x] Rebuild da cópia gerada testado após correção para não reter arquivos de versões anteriores.
- [ ] Imagem AirPlay real com cabo desconectado, código incorreto, rotação, áudio e Meet: aguardando iPad.
## Próxima ação física
PadMirror aberto em AirPlay. Selecionar o receptor no iPad e informar se Freeform aparece sem USB. Anúncio confirmado não prova transmissão de vídeo.
## Decisões
GPL-3.0-or-later. Sem Rust no host. Sem HLS, gravação, telemetria ou auto-update upstream. Áudio off por padrão. Código de acesso aleatório por ativação. Sem fallback que surpreenda o usuário.

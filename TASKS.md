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
→ Build da engine, pareamento por código e seleção explícita USB/AirPlay.
## Decisões
GPL-3.0-or-later. Sem Rust no host. Sem HLS, gravação, telemetria ou auto-update upstream. Áudio off por padrão. Código de acesso aleatório por ativação. Sem fallback que surpreenda o usuário.

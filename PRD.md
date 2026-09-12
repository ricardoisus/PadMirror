# PRD — PadMirror
## Problema e persona
Mostrar a tela real de um iPad Pro M2 no MacBook Air M4 para Freeform, Apple Pencil e compartilhamento de janela no Meet.
## Proposta de valor
Open. Plug. Mirror. Janela macOS normal, USB prioritário, AirPlay selecionado explicitamente pelo usuário, com funcionamento confirmado em 2026-09-12.
## Escopo
macOS 14+, Apple Silicon, Swift/AppKit, GPL-3.0-or-later, sem conta, telemetria, gravação ou servidores externos. Áudio desligado na primeira fase.
## Critérios de aceite
Captura direta sem QuickTime; proporção e rotação corretas; latência comparável ao QuickTime; Meet reconhece janela; reconexão. AirPlay só após prova física USB.
## Riscos
Exposição do dispositivo depende de confiança/desbloqueio e versão do macOS. PreviewLayer e compartilhamento precisam de prova física. Não prometer latência antes de medir.

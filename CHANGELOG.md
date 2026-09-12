# Changelog
## [Unreleased]
### Adicionado
- Janela limpa automaticamente durante captura USB ou streaming AirPlay, sem título ou botões de janela. Controles USB/AirPlay e desconexão aparecem ao passar o mouse; sair da janela os oculta.
- Desconexão USB explícita pausa a reconexão automática até clicar em USB. Estado de conexão restaura a interface sem recriar janela ou renderizadores.
- Fundação documental baseada nos templates fornecidos.
- Prova USB nativa com CoreMediaIO, AVFoundation e PreviewLayer, ainda não validada com hardware.

### Corrigido
- Descoberta aceita fonte screen-capture com transporte `other`, observado localmente, mantendo wireless desabilitado.

### Adicionado — wireless milestone
- Popyachsa/UxPlay nested submodule pins and explicit engine patch.
- Native C ABI AirPlay backend in the same window, access password per activation, optional audio, explicit USB switching.
- Bonjour readiness verification, bundled runtime/plugin checks and protocol-event tests.
- Basic USB Freeform image confirmed by user and visually inspected; extended physical test matrix remains open.

### Corrigido — build wireless
- Recria a cópia gerada do upstream antes de aplicar patches, evitando arquivos antigos em rebuilds/atualizações.

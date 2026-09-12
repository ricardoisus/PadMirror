# Changelog
## [Unreleased]
### Instalador completo
- DMG padrão inclui USB + AirPlay, com engine reconstruída, dependências e validação automática do bundle. USB-only passa a ser opção explícita.
- Nome do download e BUILD.txt identificam edição, arquitetura e versão mínima real do macOS.
- Inventário de fontes/licenças inclui dependências estáticas e receitas Homebrew, sem caminhos pessoais dos recibos.
### Validação e publicação
- Funcionamento AirPlay confirmado pelo usuário em 2026-09-12; testes específicos de áudio, rotação, reconexão e Meet continuam pendentes.
- Repositório público e pré-release USB v0.1.0-usb-preview.1 publicada para Apple Silicon.
- Documentado custo do Apple Developer Program e distinção entre conta gratuita e Developer ID/notarização.
### Distribuição
- Instalador DMG USB experimental com atalho para Aplicativos, licença, instruções e SHA-256; build Release e verificação de integridade automáticos.
- Documentadas instalação, limitações físicas e ausência de notarização Apple.
### Adicionado
- Janela limpa automaticamente durante captura USB ou streaming AirPlay, sem título ou botões de janela. Controles USB/AirPlay e desconexão aparecem ao passar o mouse; sair da janela os oculta.
- Desconexão USB explícita pausa a reconexão automática até clicar em USB. Estado de conexão restaura a interface sem recriar janela ou renderizadores.
- Fundação documental baseada nos templates fornecidos.
- Prova USB nativa com CoreMediaIO, AVFoundation e PreviewLayer, posteriormente validada com imagem Freeform em iPad físico.

### Corrigido
- Descoberta aceita fonte screen-capture com transporte `other`, observado localmente, mantendo wireless desabilitado.

### Adicionado — wireless milestone
- Popyachsa/UxPlay nested submodule pins and explicit engine patch.
- Native C ABI AirPlay backend in the same window, access password per activation, optional audio, explicit USB switching.
- Bonjour readiness verification, bundled runtime/plugin checks and protocol-event tests.
- Basic USB Freeform image confirmed by user and visually inspected; extended physical test matrix remains open.

### Corrigido — build wireless
- Recria a cópia gerada do upstream antes de aplicar patches, evitando arquivos antigos em rebuilds/atualizações.

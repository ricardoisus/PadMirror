# TASKS
## Fase atual
USB e AirPlay funcionando: confirmação do usuário para AirPlay em 2026-09-12. Distribuição pública USB disponível; testes físicos complementares e notarização pendentes.
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
- [x] Usuário confirmou AirPlay funcionando em 2026-09-12.
- [ ] Documentar cenários específicos: cabo desconectado, código incorreto, rotação, áudio e Meet; não detalhados nessa confirmação.
## Próxima ação física
Completar a matriz de cenários específicos de USB/AirPlay em docs/MANUAL_TEST_PLAN.md e docs/AIRPLAY.md. Funcionamento AirPlay confirmado pelo usuário; não é necessário repetir a confirmação básica.
## Decisões
GPL-3.0-or-later. Sem Rust no host. Sem HLS, gravação, telemetria ou auto-update upstream. Áudio off por padrão. Código de acesso aleatório por ativação. Sem fallback que surpreenda o usuário.

## Sessão — interface automática
- [x] Usuário confirmou visualmente o modo apresentação anterior; substituído conforme pedido por janela limpa durante conexão, sem toggle manual.
- [x] Controles USB/AirPlay e desconexão no hover; desconexão USB pausa reconexão automática até ação explícita.
- [x] Build local com AirPlay e assinatura, 24 casos comportamentais existentes aprovados. Teste de regressão da pausa USB aprovado no XCTest do CI (run 34681004113). Verificação local das 17 factories, 8 símbolos e assinaturas passou.
- [ ] Validação física do novo hover, reconexão, fullscreen e Meet; aprovação visual anterior não valida estes novos cenários.
- Implementação concluída no PR #3; integração autorizada pelo usuário, condicionada ao CI aprovado.

## Sessão — distribuição pública
- [x] DMG USB arm64 gerado; build Release, 24 casos comportamentais, integridade do DMG e assinatura do app montado aprovados. Instruções de instalação incluídas.
- [x] Repositório público; instalador publicado na pré-release v0.1.0-usb-preview.1.
- [ ] Developer ID/notarização e teste de instalação em outro Mac; validações físicas anteriores continuam pendentes.
- Histórico: 93 blobs revisados por padrões de credenciais; nenhuma ocorrência encontrada (não é garantia exaustiva).

## Sessão — confirmação AirPlay e integração
- [x] README, produto, instalação, créditos e planos atualizados com confirmação AirPlay e estado da publicação.
- [x] Build Release com AirPlay, 24 casos comportamentais, 17 factories, 8 símbolos ABI, assinaturas e revisão do diff aprovados.
- Integração da distribuição na main e remoção de feat/distribution autorizadas pelo usuário; executar após CI aprovado.

## Sessão — instalador completo
- [x] DMG USB + AirPlay gerado e verificado montado: 58 bibliotecas/plugins, 17 factories, 8 símbolos ABI, assinaturas válidas e 24 testes comportamentais aprovados.
- [ ] Publicar v0.1.0-airplay-preview.1 com fontes correspondentes; build local arm64 exige macOS 26.6.2+.

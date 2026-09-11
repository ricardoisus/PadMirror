# Arquitetura
## USB primeiro
AppKit cria NSWindow real. SwiftUI apresenta estado e seletor; NSView hospeda AVCaptureVideoPreviewLayer com resizeAspect. CoreMediaIO habilita screen capture e desabilita wireless capture explicitamente. DiscoverySession external/muxed procura fontes iOS; nenhuma heurística por nome iPhone. Não filtrar transportType == USB: a inspeção local encontrou external/muxed com transportType `othr`, conectado e sem mediaType video independente. Captura wireless é desabilitada via CoreMediaIO; external/muxed exclui webcams video-only. Essa seleção não é prova universal de identidade iOS: confirmar com o hardware alvo.
AVCaptureSession é configurada e iniciada/parada numa fila serial fora da main thread. PreviewLayer usa a sessão diretamente, sem callbacks de frame, cópias manuais, saída de áudio ou gravação. Main thread cuida da UI. O estado sessionRunning significa somente que startRunning retornou com sessão ativa; não confirma entrega de frames. isPreviewing e inputPriority são indisponíveis no macOS (confirmado pelo compilador e headers), portanto não são usados. A confirmação visual é obrigatória.
## Limitações da primeira prova
PreviewLayer preserva proporção; rotação depende dos metadados fornecidos pelo dispositivo e deve ser validada. Não forçamos rotação ou resolução arbitrária. Sem métricas falsas: PreviewLayer não expõe timestamps individuais de apresentação. Instrumentação de frames opt-in só será adicionada se necessária após a prova, pois VideoDataOutput altera o pipeline medido.
## AirPlay — C ABI nativa
Após confirmação visual do Freeform via USB e autorização do usuário, Popyachsa/UxPlay é integrado via dylib, renderizando em NSView da mesma janela. O core é serializado fora da main thread; senha aleatória por ativação, áudio off e troca de backend explícita. [Decisão, versões, privacidade e build](AIRPLAY.md).
## APIs e procedência
Implementação original baseada nos headers do SDK Apple e documentação pública. Apenas README/LICENSE de MirrorKit consultados; nenhuma implementação lida ou copiada.
- https://developer.apple.com/documentation/coremediaio/kcmiohardwarepropertyallowscreencapturedevices
- https://developer.apple.com/documentation/avfoundation/avcapturedevice/discoverysession
- https://developer.apple.com/documentation/avfoundation/avcapturevideopreviewlayer
- https://developer.apple.com/documentation/avfoundation/avcapturedevice/transporttype
Headers SDK local 26: CMIOHardwareSystem.h documenta UInt32 para opt-in (default descrito como 1); AVCaptureDevice.h define external desde macOS 14 e externalUnknown deprecated. Opt-in explícito evita depender do default. API pública não garante que cada iPad/OS entregue preview com comportamento igual ao QuickTime.

DiscoverySession.devices é observado via KVO, com polling de segurança para confiança/desbloqueio. Evita a diferença de nomes Swift das notificações de conexão entre SDK 15 e SDK 26, encontrada no CI macOS 14.
Notificações de erro/interrupção usam os valores públicos Objective-C estáveis (rawValue confirmado no SDK local), pois seus imports Swift também mudaram entre SDKs.

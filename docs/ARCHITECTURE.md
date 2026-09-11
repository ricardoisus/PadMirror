# Arquitetura
## USB primeiro
AppKit cria NSWindow real. SwiftUI apresenta estado e seletor; NSView hospeda AVCaptureVideoPreviewLayer com resizeAspect. CoreMediaIO habilita screen capture e desabilita wireless capture explicitamente. DiscoverySession external/muxed procura fontes iOS; nenhuma heurística por nome iPhone. A classificação como USB usa transportType USB para evitar selecionar webcams ou fontes wireless. Compatibilidade dessa classificação precisa de hardware.
AVCaptureSession é configurada e iniciada/parada numa fila serial fora da main thread. PreviewLayer usa a sessão diretamente, sem callbacks de frame, cópias manuais, saída de áudio ou gravação. Main thread cuida da UI. O estado sessionRunning significa somente que startRunning retornou com sessão ativa; não confirma entrega de frames. isPreviewing e inputPriority são indisponíveis no macOS (confirmado pelo compilador e headers), portanto não são usados. A confirmação visual é obrigatória.
## Limitações da primeira prova
PreviewLayer preserva proporção; rotação depende dos metadados fornecidos pelo dispositivo e deve ser validada. Não forçamos rotação ou resolução arbitrária. Sem métricas falsas: PreviewLayer não expõe timestamps individuais de apresentação. Instrumentação de frames opt-in só será adicionada se necessária após a prova, pois VideoDataOutput altera o pipeline medido.
## AirPlay — decisão adiada até gate USB
Avaliar Popyachsa uxplay-core/C ABI antes de escolher helper/IPC. Um NSView/NSWindow de outro processo não pode ser tratado como ponteiro local; helper exige transporte de superfície/frames ou integração documentada. Não lançar a GUI upstream como uma segunda interface. Preservar pairing/PIN e áudio opcional. Nenhuma engine incorporada nesta fase.
## APIs e procedência
Implementação original baseada nos headers do SDK Apple e documentação pública. Apenas README/LICENSE de MirrorKit consultados; nenhuma implementação lida ou copiada.
- https://developer.apple.com/documentation/coremediaio/kcmiohardwarepropertyallowscreencapturedevices
- https://developer.apple.com/documentation/avfoundation/avcapturedevice/discoverysession
- https://developer.apple.com/documentation/avfoundation/avcapturevideopreviewlayer
- https://developer.apple.com/documentation/avfoundation/avcapturedevice/transporttype
Headers SDK local 26: CMIOHardwareSystem.h documenta UInt32 para opt-in (default descrito como 1); AVCaptureDevice.h define external desde macOS 14 e externalUnknown deprecated. Opt-in explícito evita depender do default. API pública não garante que cada iPad/OS entregue preview com comportamento igual ao QuickTime.

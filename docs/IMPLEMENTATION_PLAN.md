# Milestones
1. USB vertical slice: build, CoreMediaIO, discovery, PreviewLayer, NSWindow. Gate: iPad físico, Freeform, rotação, Meet e comparação de latência. Somente após aprovação física usar commit `feat: working USB iOS screen mirroring`.
2. Reconexão robusta, seleção, presentation mode, controles, preferências e testes. Commit production-ready somente após testes adequados.
3. Pin de Popyachsa como submodule; spike separado de discovery/pairing/render/rotação/shutdown; decidir ABI versus IPC e integrar ao coordenador.
4. Fallback consentido, menu bar, settings, onboarding, packaging, Developer ID/notarização e release.

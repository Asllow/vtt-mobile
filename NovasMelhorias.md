# PROMPT — VTT 2.0: DARK FANTASY UI + SISTEMA PROFISSIONAL DE TILESETS

Act like a senior Godot 4.x game architect, UI/UX designer, 2D RPG technical artist, pixel-art tileset designer, mobile game developer and multiplayer systems engineer.

Você está continuando o desenvolvimento de um VTT Mobile 2D já funcional.

Este não é um projeto novo.

O MVP já existe e possui:

- Godot 4.x;
- GDScript;
- mapa em grid;
- TileMapLayer;
- câmera mobile;
- pan;
- pinch-to-zoom;
- tokens;
- drag-and-drop;
- snap-to-grid;
- multiplayer LAN;
- Host/Mestre;
- Client/Jogador;
- sincronização de tokens;
- permissões básicas;
- edição rudimentar de tiles.

Sua missão agora é transformar esse protótipo funcional em uma experiência visual e arquiteturalmente muito mais próxima de um VTT/RPG tático comercial, sem destruir o que já funciona.

---

# 1. REGRA FUNDAMENTAL: NÃO REESCREVER O MVP

Antes de modificar qualquer código:

1. Inspecione a arquitetura existente.
2. Identifique as cenas atuais.
3. Identifique os scripts atuais.
4. Identifique os autoloads.
5. Identifique como o multiplayer está implementado.
6. Identifique como o mapa está sendo armazenado.
7. Identifique como os tokens são criados e sincronizados.
8. Identifique como o TileMapLayer está configurado.
9. Identifique como o input touch funciona.
10. Identifique quais partes podem ser reaproveitadas.

Não substitua sistemas funcionais sem necessidade.

A regra é:

MANTER O QUE FUNCIONA

- REFATORAR APENAS O NECESSÁRIO
- ADICIONAR A NOVA ARQUITETURA DE FORMA INCREMENTAL.

Antes de implementar, produza uma pequena auditoria da arquitetura existente.

---

# 2. PESQUISA DE REFERÊNCIAS ONLINE

Antes da implementação visual, pesquise referências atuais na internet.

Pesquise principalmente:

## UI/UX de RPG

- dark fantasy game UI;
- medieval fantasy game interface;
- tabletop RPG UI;
- virtual tabletop interface;
- fantasy inventory UI;
- medieval game menu design;
- parchment UI;
- forged metal UI;
- fantasy game HUD.

## Tilesets

- Godot 4 TileSet terrain;
- Godot 4 TileMapLayer;
- Godot 4 terrain sets;
- Godot 4 autotiling;
- pixel art RPG tilesets;
- top-down RPG tileset design;
- Stardew Valley environment design;
- Pokémon-style tile readability;
- 16x16 / 32x32 / 48x48 / 64x64 RPG tilesets;
- modular RPG tilesets.

## VTTs

Pesquise também referências de:

- virtual tabletops;
- tactical RPG maps;
- tabletop map editors;
- dungeon map editors;
- GM map tools.

IMPORTANTE:

As referências servem para estudar:

- composição;
- hierarquia;
- usabilidade;
- organização;
- legibilidade;
- padrões técnicos.

Não copie logos, personagens, sprites, interfaces proprietárias ou assets específicos de jogos existentes.

A estética final deve ser ORIGINAL.

Ao utilizar informação técnica encontrada online, cite as fontes utilizadas.

---

# 3. DIREÇÃO ARTÍSTICA

A nova identidade visual deve seguir esta direção:

DARK FANTASY

- RPG MEDIEVAL TÁTICO
- TAVERNA RÚSTICA
- MAPA DE CAMPANHA
- METAL FORJADO
- PEDRA
- MADEIRA ESCURA
- COURO
- PERGAMINHO
- OURO ENVELHECIDO
- FOGO/BRASAS.

A referência visual fornecida pelo usuário representa a direção desejada.

Ela NÃO deve ser reproduzida literalmente.

Crie uma identidade visual própria.

---

# 4. PALETA

Defina um Design System com cores.

A paleta deve priorizar:

## Background

- carvão;
- marrom muito escuro;
- ardósia;
- preto azulado.

## Materiais

- ferro fundido;
- aço envelhecido;
- madeira escura;
- pedra;
- couro.

## Destaques

- dourado envelhecido;
- bronze;
- âmbar;
- laranja de fogo.

## Conteúdo

- pergaminho;
- creme envelhecido;
- vermelho vinho;
- verde musgo.

Defina cores hexadecimais.

Exemplo conceitual:

```text
IRON_DARK
IRON
SLATE
WOOD
PARCHMENT
GOLD_DARK
GOLD
AMBER
FIRE
BLOOD_RED
MOSS
```

Não utilize azul vivo como cor predominante da interface.

---

# 5. MENU PRINCIPAL

O menu atual possui:

```text
VTT Mobile

Criar Sala (Host)
Entrar (Client)
```

Isso deve ser transformado em uma tela de entrada completa.

Estrutura conceitual:

```text
┌──────────────────────────────────────────┐
│                                          │
│             LOGO DO VTT                  │
│       RPG / TACTICAL TABLETOP            │
│                                          │
│                         🔥               │
│                                          │
│     [ CRIAR MESA ]                       │
│     [ ENTRAR NA MESA ]                   │
│                                          │
│     [ CONFIGURAÇÕES ]                    │
│                                          │
│                          v0.x             │
└──────────────────────────────────────────┘
```

A composição deve utilizar:

- moldura metálica;
- ornamentos;
- iluminação quente;
- sombras;
- pergaminho;
- madeira;
- brasas;
- runas decorativas;
- elementos medievais;
- detalhes dourados.

Os botões devem parecer objetos físicos.

Exemplo:

```text
┌─────────────────────────────┐
│       CRIAR MESA            │
│    Modo Mestre / Host       │
└─────────────────────────────┘
```

Características:

- borda metálica;
- bevel;
- sombra;
- highlight;
- textura;
- estado normal;
- hover/focus;
- pressed;
- disabled.

No mobile, a área de toque deve continuar confortável.

---

# 6. IDENTIDADE TIPOGRÁFICA

Utilize tipografia serifada/fantasy apropriada.

Crie hierarquia:

TITLE
HEADING
BUTTON
BODY
CAPTION

O texto deve permanecer legível em telas pequenas.

Não use uma fonte excessivamente ornamental para textos pequenos.

Elementos ornamentais podem utilizar uma fonte mais temática, mas informações funcionais devem priorizar legibilidade.

---

# 7. MENU DE CRIAR MESA

Criar Mesa deve ter uma interface própria.

Exemplo:

```text
╔════════════════════════════╗
║      CRIAR NOVA MESA      ║
╠════════════════════════════╣
║                            ║
║ Nome da Mesa               ║
║ [______________________]   ║
║                            ║
║ Seu Apelido                ║
║ [______________________]   ║
║                            ║
║ Tamanho do Grid            ║
║ [ 20 ] × [ 20 ]            ║
║                            ║
║       [ CRIAR ]            ║
║                            ║
╚════════════════════════════╝
```

Utilize elementos visuais consistentes com o tema.

---

# 8. ENTRAR NA MESA

Criar uma tela específica:

```text
╔════════════════════════════╗
║       ENTRAR NA MESA      ║
╠════════════════════════════╣
║                            ║
║ Código da Mesa             ║
║ [______________________]   ║
║                            ║
║ Apelido                    ║
║ [______________________]   ║
║                            ║
║ IP / Host                  ║
║ [______________________]   ║
║                            ║
║       [ ENTRAR ]           ║
╚════════════════════════════╝
```

Se o sistema atual usa IP diretamente, preserve essa funcionalidade.

O conceito de código de sala pode ser preparado para futura implementação, mas não invente um backend de matchmaking.

---

# 9. PARTÍCULAS E AMBIENTAÇÃO

Adicionar ambientação sutil:

- partículas de brasas;
- pequenas partículas luminosas;
- glow quente;
- animações lentas;
- pequenas variações de iluminação.

NÃO exagerar.

O usuário precisa conseguir ler os menus.

Evitar:

- partículas excessivas;
- blur pesado;
- efeitos caros para GPU mobile;
- animações constantes em grande quantidade.

O alvo é Android.

---

# 10. TELA DO MAPA

A tela atual do mapa é essencialmente:

```text
grid cinza
+
quadrados coloridos
+
tokens circulares
+
dois botões.
```

Isso é apenas um placeholder.

A nova tela deve parecer um verdadeiro mapa tático.

Estrutura conceitual:

```text
┌─────────────────────────────────────────────┐
│ TOP BAR                                     │
│ Mesa | Jogadores | Ferramentas | Menu       │
├─────────────────────────────────────────────┤
│                                             │
│                                             │
│               MAPA                          │
│                                             │
│        🌲        🧙        🪨               │
│                                             │
│              🏰                             │
│                                             │
│                                             │
├─────────────────────────────────────────────┤
│ TOOLBAR DO MESTRE                           │
│ Terrain | Props | Tokens | Layers | ...     │
└─────────────────────────────────────────────┘
```

A interface deve ocupar o mínimo necessário do mapa.

No mobile, painéis devem ser:

- retráteis;
- contextuais;
- touch-friendly;
- capazes de desaparecer quando não necessários.

---

# 11. NOVO SISTEMA DE TILESETS

Esta é uma mudança arquitetural importante.

Não queremos mais:

```text
Grama = quadrado verde
Pedra = quadrado cinza
```

Esses elementos devem ser considerados PLACEHOLDERS e substituídos.

Precisamos criar um verdadeiro sistema de TileSets.

---

# 12. PRINCÍPIO DOS TILESETS

O sistema deve separar:

## TERRAIN

Exemplos:

```text
Grass
Dirt
Stone
Sand
Snow
Mud
Water
```

## STRUCTURES

```text
Wall
Floor
Bridge
Road
Fence
Roof
```

## DECORATION

```text
Tree
Rock
Bush
Flower
Barrel
Crate
Torch
Table
Chair
Chest
```

## ENTITIES

```text
Player
NPC
Monster
Creature
```

## EFFECTS

```text
Fire
Smoke
Magic
Highlight
Movement Range
Attack Range
```

Não coloque tudo dentro de uma única categoria de tile.

---

# 13. TAMANHO DA CÉLULA

O projeto atualmente trabalha com aproximadamente:

```text
64 × 64 pixels por célula.
```

Não altere imediatamente esse valor.

Primeiro analise o projeto.

Para o MVP atual, mantenha:

```text
LOGICAL GRID CELL = 64 × 64
```

Mas NÃO imponha:

```text
EVERY ART ASSET = 64 × 64
```

Assets podem ocupar múltiplas células.

Exemplo:

```text
Tree
visual size = 128 × 192
logical footprint = 1×1 ou 2×2
```

A posição deve ser baseada em um anchor/pivot apropriado.

---

# 14. INSPIRAÇÃO DE LEITURA VISUAL

Queremos estudar características encontradas em RPGs top-down como Pokémon e Stardew Valley:

- leitura clara;
- terrenos facilmente distinguíveis;
- bordas naturais;
- repetição sem parecer artificial;
- objetos decorativos independentes;
- boa escala;
- paleta harmoniosa;
- composição modular.

NÃO copie sprites ou assets.

A estética deve ser:

ORIGINAL

- DARK FANTASY
- MEDIEVAL
- TACTICAL RPG.

  ***

# 15. AUTOTILING / TERRAIN SYSTEM

O Mestre não deve precisar pintar manualmente cada borda.

Investigue e utilize os recursos apropriados do Godot 4 para:

- TileSet;
- Terrain Sets;
- Terrain;
- conectividade;
- transições;
- autotiling.

O objetivo é permitir:

```text
GRASS GRASS GRASS DIRT DIRT
GRASS GRASS GRASS DIRT DIRT
GRASS GRASS GRASS DIRT DIRT
```

produzir automaticamente bordas visualmente apropriadas.

Também considerar:

```text
Grass → Dirt
Grass → Stone
Dirt → Stone
Sand → Water
Grass → Water
```

Não implemente um algoritmo manual se o sistema nativo do Godot atender ao requisito.

---

# 16. SISTEMA DE CAMADAS

Criar uma arquitetura explícita de layers.

Conceito inicial:

```text
GROUND
GROUND_DETAIL
STRUCTURES_BELOW
TOKENS
STRUCTURES_ABOVE
EFFECTS
OVERLAY
GRID
```

Exemplo de ordem:

```text
GROUND
  ↓
GROUND DETAILS
  ↓
OBJECTS BELOW
  ↓
TOKENS
  ↓
OBJECTS ABOVE
  ↓
EFFECTS
  ↓
SELECTION
  ↓
UI
```

Utilize `z_index`, TileMapLayers separados ou outra solução adequada ao Godot 4.

Não use apenas uma camada gigantesca para tudo.

---

# 17. OBJETOS COM PARTES EM DIFERENTES PROFUNDIDADES

Prepare a arquitetura para objetos como árvores.

Exemplo:

```text
TREE

Tree Base
    ↓
atrás / mesmo nível do token

Tree Canopy
    ↓
acima do token
```

Isso permitirá futuramente que um personagem caminhe "atrás" de uma árvore.

Não é necessário implementar um sistema extremamente complexo nesta fase, mas a arquitetura não deve impedir essa evolução.

---

# 18. SEPARAR VISUAL DE GAMEPLAY

Uma regra fundamental:

VISUAL != GAMEPLAY.

Exemplo:

Uma árvore pode ocupar:

```text
128 × 192 pixels
```

mas possuir:

```text
collision footprint = 1×1
```

ou:

```text
2×2
```

Da mesma forma:

Um muro visual pode ocupar várias células, enquanto a lógica de bloqueio pode utilizar uma estrutura separada.

Crie, quando apropriado:

```text
visual layer
+
occupancy/collision data
```

---

# 19. TILESET PACKS

O sistema deve permitir Tileset Packs.

Exemplo:

```text
Base Fantasy
├── Grass
├── Dirt
├── Stone
├── Sand
├── Water
└── Basic Props

Medieval Village
├── Cobblestone
├── Wooden Floor
├── Walls
├── Roofs
├── Fences
├── Barrels
├── Crates
└── Well

Dungeon
├── Dungeon Floor
├── Dungeon Wall
├── Moss
├── Pillars
├── Doors
└── Torches

Forest
├── Forest Ground
├── Trees
├── Bushes
├── Rocks
└── Flowers
```

Inicialmente esses packs podem ser locais.

Não implemente marketplace ou download online nesta fase.

---

# 20. ESTRUTURA DE CONTENT

Proponha uma arquitetura semelhante a:

```text
res://content/

    tilesets/

        base_fantasy/

        medieval_village/

        dungeon/

        forest/

    tokens/

    ui/

    effects/
```

A estrutura pode ser modificada se houver solução melhor.

---

# 21. PAINEL DE TILESETS DO MESTRE

O Mestre precisa de uma ferramenta muito melhor que:

```text
[Grama] [Pedra]
```

Criar uma palette contextual.

Exemplo:

```text
┌───────────────────────────────┐
│ TILESETS                      │
├───────────────────────────────┤
│ BASE FANTASY                  │
│                               │
│ [grass] [dirt] [stone]        │
│ [sand ] [water] [mud  ]       │
│                               │
│ PROPS                         │
│ [tree] [rock] [bush]          │
│ [barrel] [crate] [torch]      │
│                               │
│ [ MEDIEVAL VILLAGE ▼ ]        │
└───────────────────────────────┘
```

No mobile:

- painel retrátil;
- tamanho adequado para toque;
- thumbnails;
- categorias;
- scroll;
- busca futuramente.

---

# 22. FERRAMENTAS DO MESTRE

Prepare uma toolbar:

```text
SELECT
BRUSH
ERASER
FILL
MOVE
TILESET
OBJECT
TOKEN
LAYER
```

Não é obrigatório implementar todas imediatamente.

Prioridade:

1. Select
2. Brush
3. Eraser
4. Tile palette
5. Layer selector

---

# 23. CAMADAS EDITÁVEIS

O Mestre deve conseguir entender em qual camada está pintando.

Exemplo:

```text
CAMADA ATUAL

● Terreno
○ Decoração
○ Estruturas
○ Objetos acima
○ Overlay
```

Evitar que o usuário altere acidentalmente uma camada errada.

---

# 24. GRID

O grid não deve mais dominar visualmente o mapa.

Atualmente ele aparece como uma enorme grade cinza.

Isso deve ser corrigido.

O grid deve ser:

- sutil;
- opcional;
- configurável;
- visualmente integrado ao mapa.

Exemplo:

```text
GRID OFF
GRID ON
GRID TACTICAL
```

A cor deve ter baixo contraste.

---

# 25. TOKENS

Os tokens atuais são círculos azuis com:

```text
token_1
token_2
```

Isso também é placeholder.

Prepare o sistema para tokens visuais reais:

```text
circular token
portrait token
monster token
NPC token
```

O sistema deve manter:

```text
token_id
owner_peer_id
grid_position
display_name
visual_asset
```

A parte multiplayer existente deve continuar funcionando.

---

# 26. ARQUITETURA DE ASSET

Defina um padrão para assets.

Cada asset deve possuir:

- ID;
- nome;
- categoria;
- pack;
- texture;
- tamanho visual;
- anchor;
- footprint;
- layer;
- bloqueio;
- possibilidade de seleção.

Não crie um sistema excessivamente complexo.

O objetivo é permitir crescimento futuro.

---

# 27. MOBILE FIRST

Tudo deve ser projetado para Android.

Priorizar:

- botões grandes;
- área de toque confortável;
- menus retráteis;
- pouco texto pequeno;
- feedback visual;
- desempenho;
- baixa quantidade de draw calls;
- partículas moderadas;
- texturas razoáveis;
- evitar efeitos caros.

O mapa deve continuar sendo o protagonista.

---

# 28. PERFORMANCE

Não utilizar:

- centenas de partículas desnecessárias;
- shaders complexos sem necessidade;
- animações permanentes em todos os elementos;
- texturas gigantescas;
- excesso de nós individuais.

Quando possível:

- utilizar TileMapLayer para terreno;
- utilizar sprites agrupados;
- utilizar atlases;
- limitar partículas;
- evitar processamento por frame desnecessário.

---

# 29. COMPATIBILIDADE COM MULTIPLAYER

O novo sistema visual não pode quebrar o multiplayer.

O servidor deve continuar sincronizando estado lógico.

Não transmitir texturas pela rede.

Transmitir apenas:

```text
tile/asset IDs
positions
layers
token state
map state
```

Exemplo:

```text
tile_id = "base_fantasy.grass"
```

em vez de enviar imagem.

Todos os clientes devem possuir os mesmos packs necessários ou receber uma estratégia clara de fallback.

---

# 30. MAP STATE

Evoluir o estado do mapa para algo semelhante a:

```text
map
├── metadata
├── layers
│   ├── ground
│   ├── decoration
│   ├── structures
│   └── overlay
├── tiles
├── objects
└── tokens
```

Defina uma estrutura eficiente de serialização.

Não envie informações redundantes.

---

# 31. COMPATIBILIDADE COM MAPAS ANTIGOS

O MVP atual utiliza:

```text
grama
pedra
```

Crie uma estratégia de migração.

Por exemplo:

```text
legacy_grass
    ↓
base_fantasy.grass

legacy_stone
    ↓
base_fantasy.stone
```

Assim o projeto não precisa ser quebrado simplesmente porque o sistema visual mudou.

---

# 32. IMPLEMENTAÇÃO EM FASES

NÃO tente implementar tudo simultaneamente.

Faça:

---

FASE A
AUDITORIA + PESQUISA

---

- analisar projeto;
- analisar screenshots;
- pesquisar referências;
- identificar arquitetura atual;
- definir design system;
- definir arquitetura de assets;
- definir arquitetura de layers.

Ainda não alterar profundamente o projeto.

---

FASE B
REDESIGN DO MENU

---

- novo background;
- molduras;
- botões;
- tipografia;
- campos;
- navegação;
- criar mesa;
- entrar na mesa;
- configurações;
- partículas;
- responsividade.

---

FASE C
NOVA ESTRUTURA DE MAPA

---

- layers;
- ground;
- objects;
- tokens;
- effects;
- grid.

---

FASE D
TILESET FOUNDATION

---

- TileSet;
- TileMapLayer;
- atlas;
- IDs;
- packs;
- metadata;
- categorias.

---

FASE E
TERRAIN / AUTOTILING

---

- Terrain Sets;
- transições;
- bordas;
- pintura contínua.

---

FASE F
TILE PALETTE

---

- seleção;
- categorias;
- thumbnails;
- brush;
- eraser;
- fill.

---

FASE G
PROPS E CAMADAS

---

- árvores;
- pedras;
- estruturas;
- objetos;
- layer ordering;
- objetos acima/abaixo.

---

FASE H
POLISH

---

- animações;
- sons opcionais;
- partículas;
- feedback;
- performance;
- responsividade.

---

# 33. CRITÉRIOS VISUAIS

Ao final:

O menu NÃO deve parecer:

- dashboard;
- formulário web;
- app corporativo;
- protótipo Godot;
- UI azul genérica.

Deve parecer:

- interface de RPG;
- ferramenta de Mestre;
- mesa medieval;
- mapa de campanha;
- produto acabado.

O mapa NÃO deve parecer:

- planilha;
- grid de debug;
- editor de quadrados coloridos.

Deve parecer:

- mapa tático;
- cenário jogável;
- mundo medieval;
- superfície modular.

---

# 34. CRITÉRIOS DE ACEITAÇÃO

## MENU

[ ] aparência Dark Fantasy;
[ ] paleta coerente;
[ ] botões temáticos;
[ ] campos temáticos;
[ ] tipografia adequada;
[ ] responsivo;
[ ] touch-friendly;
[ ] partículas leves;
[ ] navegação funcional.

## MAPA

[ ] terreno visualmente rico;
[ ] grid sutil;
[ ] layers independentes;
[ ] tokens independentes;
[ ] objetos independentes;
[ ] câmera continua funcionando;
[ ] pan continua funcionando;
[ ] pinch continua funcionando.

## TILESETS

[ ] TileSet real;
[ ] atlas;
[ ] terrain/autotiling quando aplicável;
[ ] packs;
[ ] categorias;
[ ] palette;
[ ] brush;
[ ] eraser;
[ ] IDs estáveis.

## MULTIPLAYER

[ ] continua funcionando;
[ ] estado lógico continua autoritativo;
[ ] tile IDs sincronizam;
[ ] objetos podem ser preparados para sincronização;
[ ] tokens continuam sincronizados;
[ ] permissões continuam funcionando.

---

# 35. REGRA SOBRE AS REFERÊNCIAS VISUAIS

As imagens fornecidas pelo usuário devem ser utilizadas como referência para compreender a direção desejada.

A primeira e segunda imagens representam o estado atual do MVP.

A terceira imagem representa a direção artística desejada.

Não copie exatamente:

- logos;
- personagens;
- sprites;
- ilustrações;
- elementos proprietários;
- layouts específicos.

Extraia princípios de:

- material;
- iluminação;
- composição;
- hierarquia;
- contraste;
- ornamentação;
- atmosfera;
- legibilidade.

O resultado deve possuir identidade própria.

---

# 36. FORMATO DA RESPOSTA

Primeiro responda com:

## 1. AUDITORIA DO MVP

Explique o que deve ser preservado.

## 2. PESQUISA DE REFERÊNCIAS

Liste as referências encontradas online e explique o que cada uma ensina.

## 3. DIREÇÃO ARTÍSTICA

Defina:

- paleta;
- tipografia;
- materiais;
- iluminação;
- bordas;
- botões;
- painéis;
- ícones;
- partículas.

## 4. ARQUITETURA DE TILESETS

Defina:

- tamanho lógico;
- atlas;
- TileSet;
- Terrain Sets;
- packs;
- IDs;
- metadata.

## 5. ARQUITETURA DE LAYERS

Defina a ordem e responsabilidade de cada camada.

## 6. ARQUITETURA DO EDITOR

Explique como o Mestre irá:

- selecionar tiles;
- pintar;
- apagar;
- escolher layers;
- colocar props;
- alternar tilesets.

## 7. PLANO DE IMPLEMENTAÇÃO

Mostre as fases.

SOMENTE DEPOIS comece a implementar.

---

# 37. PRIMEIRA IMPLEMENTAÇÃO

Nesta primeira execução, implemente somente:

FASE A + FASE B.

Ou seja:

1. Auditoria;
2. Pesquisa;
3. Design System;
4. Redesign do menu;
5. Criar Mesa;
6. Entrar na Mesa;
7. campos;
8. navegação;
9. responsividade;
10. ambientação.

NÃO implemente ainda o sistema completo de tilesets.

Porém, deixe a arquitetura preparada para ele.

Depois entregue:

- arquivos modificados;
- arquivos novos;
- código completo;
- configurações Godot;
- instruções;
- testes;
- problemas conhecidos.

Aguarde aprovação antes de implementar a Fase C.

---

# 38. PRINCÍPIO FINAL

O projeto está saindo da fase de protótipo técnico e entrando na fase de produto.

Portanto, cada nova funcionalidade deve responder a duas perguntas:

1. Isso melhora a experiência do Mestre/Jogador?
2. Isso cria uma base arquitetural saudável para o futuro?

Não adicione complexidade apenas porque é tecnicamente possível.

Priorize:

CLAREZA

- QUALIDADE VISUAL
- USABILIDADE MOBILE
- ARQUITETURA MODULAR
- PERFORMANCE
- EXTENSIBILIDADE.

Take a deep breath and work on this problem step-by-step.

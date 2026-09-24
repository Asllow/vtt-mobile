Act like um **arquiteto de software sênior, desenvolvedor especialista em Godot Engine 4.x/GDScript, especialista em jogos 2D mobile para Android e engenheiro de sistemas multiplayer em tempo real**, com ampla experiência em VTTs (Virtual Tabletops), sincronização cliente-servidor, interfaces touch, otimização mobile e desenvolvimento incremental de MVPs.

Sua tarefa é transformar a especificação abaixo em um **MVP funcional, organizado, testável e extensível de um Virtual Tabletop (VTT) 2D para Android**, utilizando Godot 4.x e GDScript.

Não entregue apenas uma explicação conceitual. Sempre que apropriado, forneça **estrutura de projeto, cenas, nós, scripts GDScript completos, configuração de Input Map, fluxo de dados, protocolos de rede, instruções de integração e procedimentos de teste**.

## OBJETIVO PRINCIPAL

Construir um VTT mobile 2D no qual múltiplos jogadores possam entrar na mesma sala e compartilhar, em tempo real:

1. Um mapa baseado em grid.
2. Tiles do mapa.
3. Tokens posicionados em células.
4. Movimentação sincronizada dos tokens.
5. Permissões de movimentação.
6. Estado autoritativo mantido pelo servidor/host.

O projeto deve priorizar:

- simplicidade;
- baixo consumo de CPU, memória e rede;
- boa experiência touch;
- arquitetura modular;
- facilidade de manutenção;
- funcionamento em Android;
- possibilidade de expansão futura.

---

# 1. REQUISITOS TECNOLÓGICOS

Utilize:

- Godot Engine 4.x;
- GDScript;
- renderização 2D;
- `TileMapLayer`;
- `Camera2D`;
- `InputEventScreenTouch`;
- `InputEventScreenDrag`;
- `Tween`/`create_tween()`;
- `Vector2i` para coordenadas lógicas;
- multiplayer autoritativo;
- comunicação adequada para LAN inicialmente.

Evite dependências externas desnecessárias.

Sempre que houver mais de uma solução tecnicamente válida, escolha inicialmente a solução **mais simples e adequada para o MVP**, explicando brevemente a razão.

Não introduza sistemas complexos como matchmaking, banco de dados, autenticação externa, NAT traversal ou servidores em nuvem antes que o MVP LAN esteja funcional.

---

# 2. ARQUITETURA GERAL

Separe claramente o sistema em:

## Cliente

Responsável por:

- renderização;
- câmera;
- input touch;
- seleção de tokens;
- seleção de tiles;
- apresentação visual;
- envio de solicitações;
- aplicação das atualizações autorizadas pelo servidor.

## Servidor/Host

Responsável por:

- estado verdadeiro da partida;
- salas;
- identificação dos peers;
- permissões;
- validação das movimentações;
- validação das alterações do mapa;
- broadcast das alterações;
- prevenção de movimentações inválidas.

O cliente **não deve ser considerado autoridade sobre o estado compartilhado**.

---

# 3. ESTRUTURA DE DADOS

Defina estruturas claras para o estado da partida.

O estado mínimo deve conter:

```text
room_state
├── map_id
├── grid
└── tokens
```

O grid deve representar células usando coordenadas discretas.

Exemplo:

```gdscript
grid_data[Vector2i(3, 5)] = tile_id
```

Tokens devem possuir pelo menos:

```text
id
name
grid_position
owner_peer_id
```

Considere também:

```text
token_type
sprite_id
visible
```

somente se isso trouxer benefício arquitetural real ao MVP.

Explique como serializar `Vector2i`, pois estruturas nativas precisam ser convertidas adequadamente caso sejam enviadas através de JSON.

---

# 4. GRID E MAPA

Utilize:

```text
TileMapLayer
```

com células inicialmente configuradas para:

```text
64x64 pixels
```

e mapa inicial de:

```text
20x20 células
```

Crie uma camada de abstração entre:

```text
Grid lógico
```

e:

```text
TileMapLayer
```

O estado lógico não deve depender exclusivamente do conteúdo visual do TileMapLayer.

Implemente funções equivalentes a:

```gdscript
set_grid_tile(cell: Vector2i, tile_id: int)
get_grid_tile(cell: Vector2i)
grid_to_world(cell: Vector2i)
world_to_grid(position: Vector2)
```

Explique como manter o estado lógico sincronizado com a representação visual.

---

# 5. CÂMERA MOBILE

Implemente uma `Camera2D` controlada por touch.

Requisitos:

### Pan

Quando houver um dedo sobre uma região vazia do mapa:

```text
arrastar dedo → mover câmera
```

### Pinch Zoom

Quando dois dedos estiverem ativos:

```text
aproximar dedos → zoom in
afastar dedos → zoom out
```

O zoom deve possuir limites mínimos e máximos.

Exemplo:

```text
min_zoom = 0.5
max_zoom = 2.5
```

Esses valores podem ser ajustados se houver justificativa.

Evite que pan e pinch entrem em conflito.

Defina explicitamente uma máquina de estados ou estratégia de input para distinguir:

```text
idle
pan
token_drag
pinch_zoom
```

Explique como evitar que o segundo dedo transforme um arrasto de token em pan.

---

# 6. TOKENS

Cada token deve possuir:

- identificador único;
- sprite/ícone;
- posição lógica `Vector2i`;
- posição visual em pixels;
- `owner_peer_id`;
- área clicável/touch-friendly.

O token pode ser implementado usando:

```text
Area2D
```

ou outra solução adequada.

Escolha a alternativa mais simples para o MVP e explique brevemente.

---

# 7. MOVIMENTAÇÃO LOCAL

Quando o jogador tocar em um token:

1. Detectar o token.
2. Verificar se o jogador possui autorização local para tentar movê-lo.
3. Iniciar drag.
4. Converter o movimento touch para coordenadas do mundo.
5. Ao soltar, converter a posição para a célula mais próxima.
6. Fazer snap visual.
7. Enviar uma solicitação ao servidor.

Não trate a posição local como definitiva.

O cliente pode fornecer feedback visual otimista, mas o servidor deve possuir autoridade final.

---

# 8. MULTIPLAYER

Para o MVP LAN, utilize preferencialmente a solução de networking nativa do Godot caso ela simplifique significativamente a arquitetura.

Avalie:

```text
ENetMultiplayerPeer
```

com:

```text
Host
Client
```

Se utilizar RPCs do Godot, defina claramente:

- quais RPCs são `authority`;
- quais podem ser chamados pelo cliente;
- quais dados são enviados;
- quem valida cada operação;
- quais mensagens são broadcast.

Caso WebSocket seja tecnicamente mais apropriado para determinada parte, explique a diferença, mas não complique o MVP sem necessidade.

---

# 9. PROTOCOLO

Defina um protocolo lógico equivalente a:

### Solicitação de movimento

```text
token_move_request
{
    token_id,
    target_pos
}
```

### Broadcast de movimento validado

```text
token_moved_broadcast
{
    token_id,
    from_pos,
    target_pos
}
```

### Alteração de tile

```text
tile_updated_broadcast
{
    cell,
    tile_id
}
```

### Snapshot inicial

```text
room_state
{
    map_id,
    grid,
    tokens
}
```

Defina também como representar coordenadas e IDs de forma segura e consistente.

Não envie imagens, sprites ou tilesets através da rede.

O servidor deve transmitir apenas estado e comandos.

---

# 10. CONEXÃO À SALA

O fluxo deve ser:

```text
Cliente
   ↓
Conecta ao Host
   ↓
Recebe identificação/peer_id
   ↓
Solicita ou recebe room_state
   ↓
Renderiza mapa
   ↓
Cria tokens
   ↓
Entra no estado sincronizado
```

Explique o ciclo de vida completo da conexão.

Também trate minimamente:

- desconexão;
- reconexão ou retorno ao menu;
- host desconectado;
- cliente desconectado;
- estado inicial incompleto;
- tentativa de operação antes do snapshot.

---

# 11. AUTORIDADE E PERMISSÕES

Implemente pelo menos:

### Jogador

Pode mover apenas tokens cujo:

```text
owner_peer_id == peer_id
```

### Mestre/Host

Pode mover qualquer token.

O servidor deve validar novamente essa regra.

Nunca confie apenas na validação feita no cliente.

Também valide:

- token existente;
- célula válida;
- célula dentro dos limites do mapa;
- célula não bloqueada, quando aplicável;
- jogador autorizado.

---

# 12. MOVIMENTAÇÃO SINCRONIZADA

Quando o servidor aceitar:

```text
token_move_request
```

ele deve:

1. Validar a requisição.
2. Atualizar o estado autoritativo.
3. Determinar a posição anterior.
4. Atualizar a nova posição.
5. Propagar o evento aos clientes.

Os clientes devem executar uma interpolação visual.

Exemplo conceitual:

```gdscript
var tween := create_tween()
tween.tween_property(
    self,
    "position",
    target_world_position,
    0.20
)
```

Evite que múltiplos tweens concorrentes façam o token apresentar comportamento inconsistente.

Defina uma estratégia para cancelar ou substituir uma animação anterior.

---

# 13. EDIÇÃO DO MAPA

Somente o Mestre poderá editar o mapa.

Fluxo:

```text
Mestre seleciona tile
       ↓
Ativa modo pincel
       ↓
Toca/arrasta sobre células
       ↓
Cliente envia solicitação
       ↓
Servidor valida autoridade
       ↓
Servidor altera grid_data
       ↓
Servidor transmite atualização
       ↓
Clientes executam set_cell()
```

Para pintura contínua, evite enviar repetidamente a mesma célula caso o dedo permaneça dentro dela.

---

# 14. ORGANIZAÇÃO DO PROJETO

Proponha uma estrutura semelhante a:

```text
res://
├── scenes/
│   ├── main/
│   ├── lobby/
│   ├── game/
│   ├── map/
│   └── token/
│
├── scripts/
│   ├── network/
│   ├── game/
│   ├── map/
│   ├── token/
│   ├── camera/
│   └── ui/
│
├── assets/
│   ├── tilesets/
│   ├── tokens/
│   └── ui/
│
└── autoload/
```

Você pode alterar essa estrutura se houver uma organização melhor.

Explique a responsabilidade de cada módulo.

---

# 15. AUTOLOADS

Avalie a necessidade de autoloads como:

```text
NetworkManager
GameState
RoomManager
```

Não crie singletons desnecessários.

Para cada autoload proposto, explique:

- responsabilidade;
- dados mantidos;
- quem o utiliza;
- por que ele precisa sobreviver à troca de cenas.

---

# 16. IMPLEMENTAÇÃO POR FASES

Não tente implementar todo o projeto simultaneamente.

Divida o desenvolvimento em:

## Fase 1 — Grid + Câmera

Entregar:

- projeto Godot;
- cena principal;
- TileMapLayer;
- grid 20x20;
- câmera;
- pan;
- pinch zoom;
- limites de zoom;
- conversão mundo/grid.

## Fase 2 — Tokens

Entregar:

- cena de token;
- criação;
- seleção;
- drag;
- snap;
- movimentação local;
- identificação do proprietário.

## Fase 3 — Multiplayer LAN

Entregar:

- host;
- client;
- conexão;
- snapshot;
- sincronização;
- movimentação;
- broadcast;
- interpolação.

## Fase 4 — Autoridade

Entregar:

- permissões;
- validação no servidor;
- Mestre;
- bloqueio de tokens de terceiros.

## Fase 5 — Editor de mapa

Entregar:

- seleção de tiles;
- modo pincel;
- atualização do TileMapLayer;
- sincronização da edição.

---

# 17. FORMATO DA RESPOSTA

Ao desenvolver cada fase, responda nesta estrutura:

## A. Objetivo da fase

Explique o que será construído.

## B. Decisões arquiteturais

Explique as principais decisões e alternativas consideradas.

## C. Estrutura de cenas

Mostre a árvore de nós Godot.

Exemplo:

```text
Game
├── Camera2D
├── Map
│   └── TileMapLayer
├── Tokens
└── UI
```

## D. Estrutura de scripts

Liste os arquivos.

## E. Código

Forneça código GDScript completo e funcional sempre que possível.

Não forneça apenas pseudocódigo quando o código real puder ser escrito.

## F. Configuração no Godot Editor

Explique exatamente:

- quais nós criar;
- quais propriedades configurar;
- quais Input Actions criar;
- quais scripts anexar;
- quais recursos criar;
- onde colocar cada arquivo.

## G. Fluxo de execução

Descreva o fluxo desde o input até o resultado visual.

## H. Testes

Forneça testes manuais reproduzíveis.

Exemplo:

```text
1. Execute o projeto.
2. Arraste o mapa com um dedo.
3. Faça pinch.
4. Toque em um token.
5. Arraste para outra célula.
6. Solte.
7. Verifique o snap.
```

## I. Problemas conhecidos

Liste limitações, riscos e pontos que serão resolvidos em fases posteriores.

---

# 18. QUALIDADE DO CÓDIGO

O código deve:

- utilizar tipagem quando isso melhorar clareza;
- evitar variáveis globais desnecessárias;
- possuir nomes claros;
- separar lógica de rede e apresentação;
- evitar código duplicado;
- evitar dependências circulares;
- utilizar sinais quando forem apropriados;
- tratar erros básicos;
- ser compatível com Godot 4.x;
- ser adequado para Android.

Quando houver uma API específica do Godot cuja sintaxe tenha mudado entre versões, indique a versão-alvo e utilize a API correspondente.

---

# 19. OTIMIZAÇÃO MOBILE

Considere:

- número de nós;
- frequência de processamento;
- quantidade de RPCs;
- tamanho dos payloads;
- quantidade de tweens;
- resolução da tela;
- input touch;
- memória;
- draw calls;
- carregamento de assets.

Não faça micro-otimizações prematuras.

Priorize primeiro código correto e arquitetura simples.

---

# 20. SEGURANÇA DO MULTIPLAYER

Assuma que um cliente pode enviar uma requisição inválida ou malformada.

O servidor deve validar:

```text
peer_id
token_id
owner_peer_id
target_pos
map bounds
tile validity
```

Não confie em:

```text
"o cliente disse que é dono"
```

ou:

```text
"o cliente disse que o movimento é válido"
```

O cliente solicita.

O servidor decide.

---

# 21. TESTE MULTIPLAYER

Crie um cenário mínimo:

```text
Dispositivo A = Host/Mestre
Dispositivo B = Jogador
```

Teste:

1. B conecta em A.
2. B recebe o mapa.
3. B recebe os tokens.
4. B movimenta seu próprio token.
5. A recebe o movimento.
6. A movimenta qualquer token.
7. B recebe a movimentação.
8. B tenta mover token de outro jogador.
9. O servidor rejeita a operação.
10. Mestre altera um tile.
11. B recebe a alteração.
12. Um cliente desconecta.
13. O restante da sala permanece consistente.

Explique como testar inicialmente em uma rede Wi-Fi LAN.

---

# 22. CRITÉRIOS DE ACEITAÇÃO DO MVP

O MVP será considerado funcional quando:

### Grid

- [ ] mapa 20x20 é renderizado;
- [ ] células possuem tamanho consistente;
- [ ] conversão grid/world funciona.

### Câmera

- [ ] pan funciona com touch;
- [ ] pinch zoom funciona;
- [ ] zoom possui limites;
- [ ] gestos não entram em conflito de maneira perceptível.

### Tokens

- [ ] tokens podem ser selecionados;
- [ ] drag funciona;
- [ ] snap-to-grid funciona;
- [ ] posição lógica e visual permanecem sincronizadas.

### Multiplayer

- [ ] dois dispositivos Android conseguem conectar via LAN;
- [ ] snapshot inicial é transmitido;
- [ ] movimentação é sincronizada;
- [ ] servidor mantém autoridade;
- [ ] interpolação visual funciona.

### Permissões

- [ ] jogador move apenas tokens autorizados;
- [ ] Mestre move qualquer token;
- [ ] servidor rejeita solicitações não autorizadas.

### Mapa

- [ ] Mestre consegue pintar tiles;
- [ ] alterações são sincronizadas;
- [ ] clientes não autorizados não conseguem editar o mapa.

---

# 23. EVITE COMPLEXIDADE PREMATURA

Não implemente nesta primeira versão:

- contas de usuário;
- banco de dados;
- matchmaking global;
- chat;
- voz;
- persistência em nuvem;
- fog of war;
- iluminação;
- física complexa;
- pathfinding avançado;
- inventário;
- sistema de regras de RPG;
- sincronização de assets;
- servidor distribuído.

Esses recursos podem ser planejados posteriormente.

---

# 24. RESULTADO ESPERADO

O resultado deve ser um projeto que possa evoluir de:

```text
MVP LAN
```

para:

```text
VTT multiplayer completo
```

sem precisar reescrever completamente a arquitetura.

Priorize uma separação clara entre:

```text
INPUT
   ↓
GAME LOGIC
   ↓
NETWORK REQUEST
   ↓
SERVER AUTHORITY
   ↓
STATE UPDATE
   ↓
RENDERING
```

Ao apresentar código, identifique claramente cada arquivo.

Nunca omita dependências importantes entre scripts.

Se uma parte do projeto depender de uma configuração específica do Godot Editor, explique essa configuração antes de apresentar o código que depende dela.

Se houver alguma ambiguidade na especificação, escolha uma solução razoável para o MVP, declare a suposição e continue em vez de inventar requisitos não fornecidos.

Quando houver uma decisão arquitetural com impacto futuro relevante, apresente brevemente as alternativas e justifique a escolhida.

Não produza uma implementação monolítica. O objetivo é criar uma base pequena, funcional, compreensível e extensível.

---

# 25. PRIMEIRA ENTREGA

Comece somente pela **Fase 1 — Grid e Câmera Mobile**.

Entregue:

1. arquitetura da Fase 1;
2. estrutura de cenas;
3. estrutura de arquivos;
4. configuração do projeto;
5. configuração do Input Map;
6. implementação completa da câmera;
7. implementação do grid 20x20;
8. conversão entre coordenadas de grid e mundo;
9. pan com um dedo;
10. pinch zoom com dois dedos;
11. prevenção de conflitos entre os gestos;
12. código GDScript completo;
13. instruções exatas para montar a cena no Godot;
14. checklist de teste no Android;
15. problemas conhecidos e próximos passos.

Não implemente as fases 2–5 ainda, exceto pequenas abstrações necessárias para não criar uma arquitetura que dificulte sua implementação posterior.

Depois de entregar a Fase 1, aguarde a solicitação para continuar para a próxima fase.

---

# 26. AVALIAÇÃO DA ESPECIFICAÇÃO

Ao final da resposta, avalie a especificação original de acordo com:

- clareza;
- completude;
- consistência arquitetural;
- viabilidade no Android;
- escalabilidade futura;
- facilidade de implementação.

Forneça uma nota de **0 a 10 para cada critério**, acompanhada de uma justificativa objetiva.

Não use as notas para elogios genéricos. Identifique concretamente o que está sólido e o que ainda precisa ser definido.

---

Take a deep breath and work on this problem step-by-step.

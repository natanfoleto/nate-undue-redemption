# Técnico

Motor, arquitetura, estrutura de pastas e convenções de código.

## Fundamentos
| Item | Decisão |
|------|---------|
| Motor | Godot 4.7.2, a versão estável no começo da produção (2026-10-12), fixada até o fim (sem atualizar no meio) |
| Linguagem | GDScript, sempre com tipos declarados (ex.: `var health: int = 5`) |
| Plataformas | Windows e macOS; o desenvolvimento acontece no Mac |
| Idioma do código | nomes de variáveis, funções e arquivos em inglês, como a API do Godot; comentários e textos do jogo em português |
| Textos do jogo | numa tabela de tradução do Godot desde o início, só com português do Brasil (`09-interface.md`) |

- Antes de publicar, o jogo precisa ser testado num Windows de verdade.
- No Mac, um jogo sem assinatura mostra um aviso de segurança, e assinar exige a conta paga de desenvolvedor da Apple. Assinar ou não: `[A DEFINIR na publicação]`.

## Arquitetura

### Mapa
- Uma cena por área: Prólogo e Mina, Bosque de Fungos, Ruínas e Grande Prisão (`08-mapa.md`).
- A troca de cena acontece nas passagens que já existem: o elevador (Mina → Bosque), a passagem escura (Bosque → Ruínas) e a porta da Grande Prisão. Na viagem rápida, a área de destino carrega durante um escurecimento da tela.
- O cenário é pintado bloco a bloco com o GridMap do Godot, usando uma biblioteca de blocos texturizados de 16×16 pixels (`10-arte-audio.md`). Detalhes menores que um bloco viram objetos à parte.

### Modelos e animações
- Cada modelo é um arquivo de dados com a lista de caixas: tamanho, posição, ponto de giro e região da textura. Um script único, o montador, monta o modelo no jogo.
- As animações também são dados: poses-chave por tempo, com a rotação e a posição de cada parte, tocadas pelo mesmo sistema.
- Uma cena de prévia no editor mostra o modelo e a animação enquanto os dados são editados.
- Uma variante usa o mesmo modelo e só troca a textura (`06-mobs/README.md`).
- O montador e a prévia são feitos antes dos primeiros modelos.
- Medidas em pixels (16 px = 1 bloco), com o chão em y = 0 e a frente do modelo virada para −z.
- Cada caixa tem um nome e pode se prender a outra, girando junto com ela. Uma caixa de tamanho zero só agrupa partes.
- A textura segue o molde de caixa do Minecraft: cada caixa ocupa uma região que começa num canto dado. Sem textura, cada caixa usa a própria cor (caixa lisa).
- Uma pose cita só as partes que saem do repouso. Entre duas poses, o movimento é suave ou constante, e a troca de animação mistura as duas no tempo de mistura da nova.
- Os scripts ficam em `game/tools/models/` (o montador `BlockModel`, o tocador `ModelAnimator` e a prévia `model_preview.tscn`); os dados, em `game/data/models/` e `game/data/animations/`.

### Salvamento
- Um arquivo JSON na pasta do usuário, regravado a cada conquista (item, atalho, mural, inimigo morto) e a cada descanso (`02-core-loop.md`).
- Gravação segura: o jogo escreve num arquivo temporário e só no fim o troca pelo antigo, para não corromper o jogo salvo se o computador desligar no meio.
- Tudo o que é salvo (mob, baú, atalho, mural, pergaminho, melhoria) tem um identificador único no mapa.
- O arquivo guarda: último santuário, itens, elementos aprendidos, melhorias, o que está equipado, objetos abertos, inimigos mortos, murais vistos, tempo de jogo e mortes (para o resumo do fim).
- As opções do menu ficam num arquivo à parte, que não é apagado por "Novo jogo".

### Sistemas globais
Autoloads do Godot:

| Sistema | Função |
|---------|--------|
| `GameState` | progresso, último santuário e troca de área |
| `SaveSystem` | grava e lê o JSON, com gravação segura |
| `Events` | canal de sinais (ex.: inimigo morreu, item achado, atalho aberto); o salvamento ouve esses sinais |
| `Balance` | carrega os arquivos de dados com os números do `11-balanceamento.md` |
| `InputManager` | último dispositivo usado (para os ícones de botão) e botões trocados |
| `AudioManager` | música por área, sons de ambiente e mixagem com os avisos acima da música |

### Combate
- Toda colisão de combate é calculada por código no plano do chão (`03-regras.md`). Cada entidade recebe golpes num círculo, e as áreas de golpe são círculo, setor, retângulo ou projétil.
- A marca de aviso é desenhada a partir da mesma forma do golpe: o que se vê é o que acerta.
- Componentes reutilizáveis, como nós filhos: vida, efeitos de status, recuo e área de golpe.
- A fórmula de dano fica numa função só, coberta por teste automático.

### Inteligência dos mobs
- Máquina de estados simples: parado, perseguir, atacar e voltar.
- Uma fila global garante que no máximo 5 mobs preparem ataque ao mesmo tempo (`06-mobs/README.md`).

### Dados
- Os dados do jogo (números, modelos, animações e ondas das arenas) são recursos do Godot: tipados e editáveis no inspetor.
- Só o jogo salvo usa JSON, por segurança.
- Os números do `11-balanceamento.md` ficam nesses arquivos de dados, um por categoria (armas, magias, mobs, Boiúna etc.). Mudar um número não exige mexer no código.

### Câmera e luz
- Câmera ortográfica, com ângulo isométrico. Tamanho do enquadramento: `[A DEFINIR no rascunho do mapa]`.
- Fungos e padrões marajoara brilham pelo próprio material, com poucas luzes reais. A Luz Ancestral é uma luz presa em Nate.

### Interface
- Todo texto que aparece na tela passa pela tabela de tradução, só com português do Brasil por enquanto (`09-interface.md`).
- As imagens do mapa são geradas do próprio mapa: uma câmera de cima fotografa cada área, e o jogo desenha os ícones por cima. Toda mudança no mapa atualiza a imagem.

## Estrutura de pastas
O projeto do Godot fica em `game/`, ao lado de `docs/`, no mesmo repositório:

```
nate-undue-redemption/
├── CLAUDE.md
├── docs/
└── game/
```

Dentro de `game/`, as pastas são organizadas por assunto: cada parte do jogo junta as próprias cenas e scripts.

```
game/
├── project.godot
├── addons/        gdUnit4, a ferramenta de testes
├── assets/        texturas, sons, música e fontes
├── data/          números, modelos, animações e ondas
├── autoload/      sistemas globais
├── combat/        golpes, vida, efeitos e recuo
├── player/        Nate
├── mobs/          lobo, esqueleto, necromante e golem
├── boss/          Boiúna
├── world/         áreas, armadilhas e objetos
├── ui/            HUD, inventário, menus e mapa
├── tools/         montador, prévia e gerador das imagens do mapa
├── localization/  tabela de textos
└── tests/         testes de regras e de salvamento
```

## Convenções de código
- Estilo oficial do GDScript: `snake_case` para arquivos, funções e variáveis; `PascalCase` para classes; `CONSTANT_CASE` para constantes.
- Tipos sempre declarados (ex.: `func take_damage(amount: int) -> void`).
- Nomes em inglês; comentários em português, curtos, explicando o porquê.
- Uma cena por entidade, com o comportamento comum em componentes (nós filhos). Herança de no máximo um nível, como a classe base `Mob`.
- Os sistemas conversam por sinais, nunca por caminhos longos de nós.
- Nenhum número fixo no código: os números vêm dos arquivos de dados.
- Todo texto que aparece na tela passa pela tabela de tradução.
- Tudo o que é salvo tem um identificador único no mapa.
- Commits em português, no formato `tipo: descrição`, como no histórico do repositório.

## Processo
- **Versão do Godot:** a estável mais recente no começo da produção, fixada até o fim.
- **Testes automáticos:** para as regras de combate (fórmula de dano, efeitos de status, recuo) e para o salvamento, com o gdUnit4 6.2.2, fixado junto com o Godot. O resto é testado jogando.
  - Os testes ficam em `game/tests/`. No editor, rodam pelo painel GdUnit; no terminal, a partir da raiz do repositório:
    `godot --headless --path game -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode`
  - O gdUnit4 e os testes ficam fora das exportações do jogo.
- **Git:** os arquivos gerados pelo Godot (`.godot/`), os relatórios dos testes (`reports/`) e as exportações ficam fora do git. Sem Git LFS no começo: texturas de 16 px e sons pequenos cabem no git normal.
- **Assets prontos:** entram como provisórios no começo da produção e são registrados com origem e licença no `10-arte-audio.md`. Os créditos do jogo listam os que pedem crédito.
- **Ordem:** o montador de modelos e a prévia vêm antes dos primeiros modelos.

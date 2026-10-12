# Plano de produção

Como construir o jogo a partir da documentação. São etapas curtas, e cada uma termina com algo jogável. As etapas 0 a 4 estão detalhadas; as seguintes estão em linhas gerais e ganham detalhe quando chegar a vez delas.

## Princípios
- **Jogável cedo:** toda etapa termina com algo que dá para jogar e testar.
- **Risco primeiro:** o montador de modelos e o combate vêm antes de tudo, porque o resto depende deles.
- **Provisórios:** caixas lisas e texturas prontas (CC0) até a área ficar boa de jogar. A arte e o som definitivos entram no fim de cada área (`10-arte-audio.md`).
- **Uma área completa antes da próxima:** o prólogo e a Mina formam a primeira fatia jogável.
- **Documentos em dia:** se o design mudar durante a produção, o documento muda junto.

## Visão geral
| Etapa | Entrega | Pronto quando |
|-------|---------|---------------|
| 0. Projeto | projeto do Godot montado em `game/` | o projeto abre, roda uma cena vazia e o teste de exemplo passa |
| 1. Montador de modelos | modelos e animações a partir de dados, com prévia no editor | Nate aparece na prévia e anda, tudo vindo dos dados |
| 2. Nate se movendo | câmera, movimento, mira e rolamento numa sala de teste | andar, mirar e rolar respondem bem no teclado e mouse e no controle |
| 3. Combate contra o lobo | golpes, avisos, vida, dano, recuo e o primeiro mob | lutar contra 3 lobos é claro e tem peso (pilares 1 e 2) |
| 4. Prólogo e Mina | a primeira fatia jogável, com arte e som definitivos | dá para jogar do prólogo ao elevador, fechar o jogo e continuar de onde parou |
| 5. Bosque de Fungos | santuários, frasco, magias e o Necromante | o Bosque inteiro jogável, do elevador à passagem escura |
| 6. Ruínas | Golem, variantes, Terra, combinações e o Selo | as Ruínas inteiras jogáveis, até a sala do Selo |
| 7. Grande Prisão | a Boiúna e o fim do jogo | dá para jogar do começo ao fim |
| 8. Acabamento | cenas, menus, música e testes com jogadores | os 30 min de jogo conferidos com quem nunca jogou; versões para Windows e macOS |

## Etapa 0: projeto
- Instalar o Godot 4.7.2, a versão estável atual, e registrá-la no `12-tecnico.md`.
- Criar `game/` com `project.godot`, o `.gitignore` (`.godot/` e exportações) e as pastas do `12-tecnico.md`.
- Criar os sistemas globais vazios: `GameState`, `SaveSystem`, `Events`, `Balance`, `InputManager` e `AudioManager`.
- Cadastrar os botões do `04-player.md` no mapa de entrada do Godot, para teclado e mouse e para controle.
- Criar a tabela de tradução (pt_BR) com a primeira chave.
- Instalar a ferramenta de testes (ex.: gdUnit4) e escrever um teste de exemplo.

Concluída em 2026-10-12.

## Etapa 1: montador de modelos
- Recurso `ModelData`: a lista de caixas, com tamanho, posição, ponto de giro e região da textura, em 16 px por bloco.
- Montador: um script que cria as caixas como nós e aplica a textura.
- Recurso `AnimationData`: poses-chave por tempo, e um tocador que passa de uma pose para a outra.
- Cena de prévia no editor, que mostra o modelo e a animação enquanto os dados são editados.
- Nate em caixas lisas, com as animações parado e andar.

Concluída em 2026-10-12.

## Etapa 2: Nate se movendo
- Câmera ortográfica isométrica seguindo Nate.
- Sala de teste pintada com GridMap, usando uma textura pronta de pedra (CC0).
- Movimento de 5 blocos/s, com aceleração e frenagem de 0,1 s.
- Mira pelo mouse e pelo analógico direito, com a ajuda de mira.
- Rolamento de 3 blocos em 0,4 s, invencível, com recarga de 1 s.
- Ícones de botão trocando conforme o dispositivo.
- Todos os números lidos de `game/data/`, pelo `Balance`.

## Etapa 3: combate contra o lobo
- Área de golpe no plano do chão: as quatro formas, os três tempos e a marca de aviso desenhada pela mesma forma.
- Vida em corações para Nate e em pontos para os mobs; fórmula de dano com variação e crítico, coberta por teste.
- Recuo e peso, interrupção e 1 s de invencibilidade depois de levar golpe.
- Combo de 3 golpes do facão e tiro da baladeira.
- Lobo com modelo provisório: persegue, salta com mordida depois do aviso e desiste quando perde Nate de vista.
- Fila de ataque, com no máximo 5 mobs atacando.
- Morte de Nate e volta ao começo da sala.
- Teste com alguém que nunca jogou: entende por que levou cada golpe?

## Etapa 4: prólogo e Mina
- Rascunho do mapa do prólogo e da Mina, definindo o tamanho do enquadramento da câmera (pendência do `12-tecnico.md`).
- Esqueleto Guerreiro e a armadilha das pedras que caem.
- Baú, alavanca (de perto e de longe), portão e o elevador que quebra na descida.
- Arena da Mina, com as ondas do `11-balanceamento.md`.
- Prólogo com o lobo que foge pela fenda, e dicas de botão na tela.
- Salvamento em JSON a cada conquista, coberto por teste; HUD com corações; morte rápida.
- Arte e som definitivos do prólogo e da Mina; registro das licenças no `10-arte-audio.md`.

## Etapas 5 a 8, em linhas gerais
- **5. Bosque de Fungos:** santuários, frasco, memórias 1 e 2, viagem rápida, pergaminhos de Fogo e Água, Luz Ancestral e áreas escuras, magias e combinações, Necromante, cogumelos de esporos, inventário, arenas, atalhos e os segredos do Bosque.
- **6. Ruínas:** Golem e as variantes, pergaminhos de Terra e Ar, paredes rachadas (também as das áreas anteriores), lanças do chão, ponte de alavanca, murais e galeria, memória 3 e a sala do Selo.
- **7. Grande Prisão:** antessala com a memória 4, a Boiúna com as duas fases e os pilares, a cena da troca de fase, o final, os créditos, o resumo e o pós-jogo.
- **8. Acabamento:** abertura, menus e opções (trocar botões e acessibilidade), mapa por área e tela de progresso, música, testes com jogadores de fora para conferir os 30 min, ajustes no `11-balanceamento.md` e exportação para Windows e macOS.

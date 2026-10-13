# Plano de produção

Como construir o jogo a partir da documentação. São etapas curtas, e cada uma termina com algo jogável. As etapas 0 a 6 estão detalhadas; as seguintes estão em linhas gerais e ganham detalhe quando chegar a vez delas.

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

Concluída em 2026-10-12 no teclado e mouse; falta o teste com controle, que fica para quando houver um.

## Etapa 3: combate contra o lobo
- Área de golpe no plano do chão: as quatro formas, os três tempos e a marca de aviso desenhada pela mesma forma.
- Vida em corações para Nate e em pontos para os mobs; fórmula de dano com variação e crítico, coberta por teste.
- Recuo e peso, interrupção e 1 s de invencibilidade depois de levar golpe.
- Combo de 3 golpes do facão e tiro do estilingue.
- Lobo com modelo provisório: persegue, salta com mordida depois do aviso e desiste quando perde Nate de vista.
- Fila de ataque, com no máximo 5 mobs atacando.
- Morte de Nate e volta ao começo da sala.
- Teste com alguém que nunca jogou: entende por que levou cada golpe?

Concluída em 2026-10-12, menos o teste com alguém que nunca jogou, que fica com o responsável. A sala de teste tem três lobos e, depois deles, um Lobo Alfa, para ver a marca de aviso do golpe forte.

## Etapa 4: prólogo e Mina
- Rascunho do mapa do prólogo e da Mina, definindo o tamanho do enquadramento da câmera (pendência do `12-tecnico.md`).
- Esqueleto Guerreiro e a armadilha das pedras que caem.
- Baú, alavanca (de perto e de longe), portão e o elevador que quebra na descida.
- Arena da Mina, com as ondas do `11-balanceamento.md`.
- Prólogo com o lobo que foge pela fenda, e dicas de botão na tela.
- Salvamento em JSON a cada conquista, coberto por teste; HUD com corações; morte rápida.
- Arte e som definitivos do prólogo e da Mina; registro das licenças no `10-arte-audio.md`.

Feita em 2026-10-12, menos a arte e o som definitivos, que esperam decisões do responsável. O rascunho do mapa está no `08-mapa.md`, e o enquadramento de 14 blocos continua até ser conferido jogando. Junto vieram o menu principal (Continuar, Novo jogo e Sair) e a pausa (Continuar e Voltar ao menu principal); as outras opções dos menus ficam para o acabamento.

## Etapa 5: Bosque de Fungos
- Efeitos de status (atordoado, lento, veneno e queimadura), com partículas, ícones sobre os mobs e ao lado dos corações, cobertos por teste.
- Frasco: 3 cargas, 2 corações por carga, 0,6 s para beber; ganho no S1; recarrega no descanso e na volta depois de morrer.
- Santuários S1 e S2: acendem na primeira visita, mostram a memória (1 e 2) e abrem o menu com Descansar e Viajar.
- Troca de área com a tela escurecendo: o elevador da Mina desce até o Bosque e quebra na chegada; consertado, vira atalho. A morte com o último santuário em outra área leva até ele.
- Pergaminhos de Fogo e Água: o rolo abre na tela; o primeiro acorda o muiraquitã, que dá a Luz Ancestral nas áreas escuras.
- Magias: Bola de Fogo, Onda Cortante e a combinação Vapor, com as recargas no HUD.
- Necromante e Necromante Ancião (praga com veneno, invocação de esqueletos, recuo); Esqueleto Veterano (2 golpes seguidos).
- Cogumelos de esporos e cogumelos gigantes que brilham (os dinossauros do Bosque saíram depois do segundo teste de jogo).
- Inventário (Tab): os 5 espaços, os itens de cada categoria e a comparação com o equipado.
- Itens do Bosque: Lança, Zarabatana e Azagaia marajoara, Manto de fibras e o +1 coração; na Mina, o +1 coração do canto escuro.
- Rascunho do mapa do Bosque, com as 2 arenas, a arena opcional, a porta que só abre por um lado e a passagem escura.

Feita em 2026-10-12, menos a arte e o som definitivos e o teste com controle, como na etapa 4. As memórias são cenas curtas provisórias, feitas no motor; os murais 2 e 3 têm o lugar no mapa e ganham a tela e a galeria na etapa 6. A passagem escura termina a parte jogável até as Ruínas existirem. Junto vieram as correções da revisão da etapa 4: a arena vencida reabre os portões ao carregar o jogo, as barreiras (camada 4) seguram Nate e os mobs, os corações da armadura chegam vazios, a dica de um item já pego volta se ainda não foi usada, o título da confirmação de "Novo jogo" passa pela tabela de textos e o tempo de jogo passa a contar.

## Etapa 6: Ruínas
- Golem de Pedra e Golem Ancião: socão e abalo alternados, peso pesado, o abalo deixa lento.
- Pergaminhos de Terra e Ar e as magias Colapso Terrestre e Rajada Veloz; as 6 combinações (Vapor, Magma, Tempestade de Fogo, Gelo, Lamaçal e Escudo de Areia).
- Paredes rachadas que quebram com qualquer golpe ou tiro depois da Terra, também na Mina (Armadura de minerador e arena opcional) e no Bosque (+1 coração).
- Lanças do chão, ponte de alavanca (atalho até o S3) e o portão das 3 alavancas do Arco marajoara.
- Murais: os 7 desenhos, o mural grande na tela e a galeria no menu de pausa, com a contagem.
- S3 com a memória 3; a sala do Selo, com os murais 4 e 5, e o Selo, que completa o muiraquitã.
- Tacape, Lâmina de pedra verde, Arco, Couraça de cerâmica, Armadura de minerador, +1 coração e +1 carga.
- Rascunho do mapa das Ruínas, com as 2 arenas e a arena opcional; a passagem escura do Bosque leva até elas.

Feita em 2026-10-12, menos a arte e o som definitivos e o teste com controle. Os murais e a memória 3 são provisórios, feitos no motor. A saída depois da sala do Selo termina a parte jogável até a Grande Prisão existir, e só vale com o Selo pego. A revisão de código veio junto com os ajustes do primeiro teste de jogo.

## Ajustes do primeiro teste de jogo
Depois da etapa 6, o responsável jogou e pediu (2026-10-12):
- **Cenário:** bordas naturais no lugar das paredes retas de limite (morros, mata e barrancos, como no Minecraft Dungeons); texturas pintadas à mão, menos parecidas com as do Minecraft; relevo, com platôs e escadas; personagens com as quinas arredondadas.
- **Jogabilidade:** o golpe não leva Nate para a frente, e dá para golpear andando, à metade da velocidade; a Baladeira vira Estilingue; o HUD mostra o equipamento e avisa cada item achado; o rolamento recarrega em 0,5 s, numa cambalhota com os joelhos dobrados; a vida volta sozinha fora de luta, e o frasco fica para o meio da luta.

Feitos em 2026-10-13, com os documentos atualizados, junto com a revisão de código das etapas 6 e dos ajustes. Ela corrigiu: a ponte de alavanca, que com a gravidade nova não segurava Nate; os murais de uma área, que mostravam todos o mesmo desenho na parede; o mob atingido de longe, que corria para um canto do mapa; a ajuda de mira, que não puxa mais para inimigos em outra altura; e as magias que só empurram, que não dão mais crítico de 0. Fica para depois, como o responsável preferiu: mais plantas e mato na floresta.

## Cenário cheio, abismos e som
Depois de jogar os ajustes, o responsável pediu (2026-10-13): nada do vazio preto em volta do mapa; florestas, montanhas e vilarejos do lado de fora; paredes extensas de pedra dentro das cavernas; e profundidade no cenário, com pontes e descidas. Também aprovou baixar os pacotes de som e trazer os geradores das áreas para o repositório. As escolhas dele:
- No fundo dos abismos, um para cada área: água escura na Mina, água brilhante e fungos no Bosque, lava nas Ruínas.
- Lá fora, a vila abandonada dos mineiros, a mata e, mais embaixo, o rio Nhamundá com a cidade do outro lado.
- Um trecho novo por área no caminho, sem mudar salas, lutas e itens: a ponte de tábuas sobre a galeria inundada da Mina, o pé de cogumelo caído sobre a fenda do Bosque e a ponte de pedra sobre a fenda de lava das Ruínas; a vala da Mina e os vãos das Ruínas ficaram fundos.

Feito em 2026-10-13: o terreno preenche tudo o que a câmera alcança (`08-mapa.md`), com água, rio e lava animados, plantas, cercas na beira dos abismos e o mapa de navegação passando pelas pontes; o som provisório toca em todo o jogo, com música por área, a das arenas e a das memórias, som de fundo na Mina e nas Ruínas, avisos de golpe acima da música e passos conforme o chão (`10-arte-audio.md`). Os geradores e os rascunhos dos mapas ficam em `game/tools/areas/` (`12-tecnico.md`).

## Ajustes do segundo teste de jogo
Depois de jogar o cenário cheio, o responsável pediu (2026-10-13), em 18 pontos: um som de vento só para todos os golpes de lâmina; o rastro do golpe com as pontas arredondadas, nascendo pequeno; a barra fixa de 5 espaços embaixo, no centro, visível com o inventário aberto, com os números de 1 a 5; o inventário numa caixa no centro; o elevador do Bosque sem o chão de grama pela metade; a água mais lenta; as configurações de volume na pausa; a esquiva melhor; a poção de vida nova, como item da barra; a barra de vida no lugar dos corações, com a vida voltando mais devagar e só fora de combate; salas menos quadradas e chão misturado na troca de material; relevo sem escada obrigatória; a sombra dos corredores escuros menos quadrada; sem os dinossauros; e "Voltar" no lugar de "Sair" no santuário. As escolhas dele:
- **Barra fixa:** uma arma na mão, como no Minecraft: o número escolhe o item da mão, e o botão esquerdo usa (golpeia, atira ou bebe).
- **Vida:** 100 de vida, que volta 2 por segundo fora de combate; cada coração vira 20 (golpe comum 20, forte 40, chefe até 60; armadura e melhorias +20 por coração); a poção cura 40.
- **Esquiva:** dash com rastro, com a mesma distância, tempo, recarga e invencibilidade do rolamento.
- **Relevo:** rampas do próprio chão na natureza; escadas só nas construções.

Feitos em 2026-10-13, com os documentos atualizados. Em avaliação com o responsável: o visual novo de Nate (3 opções com textura pintada, para ele escolher).

## Etapas 7 e 8, em linhas gerais
- **7. Grande Prisão:** antessala com a memória 4, a Boiúna com as duas fases e os pilares, a cena da troca de fase, o final, os créditos, o resumo e o pós-jogo.
- **8. Acabamento:** abertura, menus e opções (trocar botões e acessibilidade), mapa por área e tela de progresso, música, testes com jogadores de fora para conferir os 30 min, ajustes no `11-balanceamento.md` e exportação para Windows e macOS.

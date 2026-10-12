# Nate: Undue Redemption

Projeto piloto para ganhar experiência em desenvolvimento de jogos antes dos próximos (entre eles, um jogo educacional sobre reciclagem ligado ao projeto Ecokids).

## Fase atual: documentação
- Nenhum código, cena ou asset é criado até a documentação estar concluída e aprovada.
- Documentar um tema por vez, na ordem do roteiro em `docs/00-visao-geral.md`.
- Em cada tema: propor opções com prós e contras, o usuário decide, a decisão é registrada no documento.
- Ao concluir um tema, marcar no roteiro e atualizar a seção "Decisões" da visão geral se algo mudar.

## Regra de produção
- **Pequeno e completo:** começo, meio e fim. Poucos sistemas bem feitos em vez de muitos pela metade. Na dúvida, cortar escopo.

## Como trabalhar
- Sempre em português.
- Explicar pouco as alterações feitas nos arquivos; focar no conteúdo.

## Convenções dos documentos
- Markdown, um arquivo por tema, em `docs/`.
- Mobs em `docs/06-mobs/` e chefes em `docs/07-chefes/`, um arquivo por criatura.
- Pendências marcadas com `[A DEFINIR]`. Nunca inventar um valor sem discutir antes.
- Números (atributos, dano, tempos, distâncias) sempre explícitos e com unidade.
- Toda entidade (player, mob, chefe, item, armadilha) usa a ficha abaixo, para que a lista de assets, animações e sons saia direto dos documentos.

### Ficha de entidade

```markdown
# Nome

**Papel no jogo:** o que ela faz e por que existe
**Descrição visual:** forma, cores, tamanho em blocos

## Atributos
| Atributo | Valor |
|----------|-------|

## Comportamento e habilidades

## Interações
Com o player, outros mobs, itens e o cenário.

## Animações necessárias

## Sons necessários

## Assets necessários
```

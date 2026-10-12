# Nate: Undue Redemption

Projeto piloto para ganhar experiência em desenvolvimento de jogos antes dos próximos (entre eles, um jogo educacional sobre reciclagem ligado ao projeto Ecokids).

## Fase atual: produção
- A documentação em `docs/` foi aprovada em 2026-10-12 e é a referência do que se constrói.
- Seguir o plano em `docs/13-plano-de-producao.md`, uma etapa por vez; cada etapa termina com algo jogável.
- Mudança de design: propor opções com prós e contras, o usuário decide, e o documento é atualizado junto com o código.
- Números ficam em `docs/11-balanceamento.md` e nos arquivos de dados de `game/data/`; os dois mudam juntos.
- Código e projeto seguem `docs/12-tecnico.md`.
- Antes de cada commit com código, rodar os testes automáticos (comando em `docs/12-tecnico.md`).

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
- Itens com o mesmo comportamento (armas e armaduras) dividem uma ficha por categoria, com uma tabela das peças.

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

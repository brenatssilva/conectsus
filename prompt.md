Atue como um **desenvolvedor sênior de R Shiny, arquiteto de software e UI/UX designer especializado em dashboards analíticos para saúde pública**.

Quero que você desenvolva o **esqueleto funcional e visual de um painel de Business Intelligence em R Shiny para avaliação da Qualidade dos Dados da RNDS**, utilizando como referência todos os arquivos disponíveis neste projeto.

O objetivo desta primeira etapa NÃO é finalizar todos os indicadores. Quero construir uma arquitetura sólida, modular, bonita e escalável, utilizando a dimensão **Consistência** como demonstração funcional, pois ela já possui indicadores disponíveis nos dados. Para as demais dimensões, crie o esqueleto visual preparado para receber os indicadores posteriormente.

# 1. Antes de programar

Primeiro, analise os arquivos existentes no projeto, especialmente:

* `Modelo_Dashboard_hoje.pptx`
* `readme_uso_base_intermediario.md`
* `dicionario_dados_bases_intermediarias.xlsx`
* bases/dicionários referentes aos modelos informacionais
* demais arquivos auxiliares disponíveis

Use o PowerPoint como referência para a **arquitetura da informação e organização do dashboard**, mas NÃO replique literalmente sua estética.

Quero transformar essa proposta em uma interface muito mais moderna, limpa, elegante e profissional.

NÃO invente nomes, fórmulas, indicadores ou significados que não estejam presentes nos dados ou nos materiais disponíveis.

Quando alguma informação ainda não existir, use componentes de placeholder claramente identificados como:

**"Indicador em definição"**

e deixe a estrutura pronta para sua implementação posterior.

---

# 2. Objetivo técnico desta entrega

A entrega deve contemplar:

1. Fazer um plano de desenvolvimento do painel;
2. Criar a arquitetura do projeto R Shiny;
3. Criar o esqueleto funcional do painel;
4. Implementar a dimensão **Consistência** utilizando os indicadores realmente disponíveis;
5. Criar apenas o esqueleto para as demais dimensões;
6. Definir como os dados serão lidos pelo R;
7. Definir como serão feitas as consultas;
8. Criar funções reutilizáveis para indicadores, filtros e visualizações;
9. Deixar o projeto preparado para crescimento futuro;
10. Documentar as principais decisões técnicas.

---

# 3. Tecnologias preferenciais

Utilize preferencialmente:

* `shiny`
* `bslib`
* `bsicons`
* `dplyr`
* `tidyr`
* `arrow`
* `purrr`
* `stringr`
* `lubridate`
* `scales`

Para visualizações, escolha bibliotecas adequadas entre:

* `plotly`
* `echarts4r`
* `leaflet`
* `reactable`

Evite utilizar `shinydashboard` como estrutura principal.

Quero uma interface moderna construída preferencialmente com **Bootstrap 5 via bslib**, complementada com CSS personalizado apenas quando necessário.

Evite adicionar dependências sem necessidade.

---

# 4. Arquitetura do projeto

Não concentre todo o código em um único `app.R`.

Estruture o projeto de forma modular e profissional, aproximadamente assim:

```text
projeto/
│
├── app.R
│
├── R/
│   ├── data_access.R
│   ├── data_processing.R
│   ├── indicators.R
│   ├── utils.R
│   ├── mod_home.R
│   ├── mod_dimensao.R
│   ├── mod_consistencia.R
│   ├── mod_filters.R
│   ├── mod_kpis.R
│   ├── mod_series_temporais.R
│   ├── mod_mapa.R
│   └── mod_tabela_investigacao.R
│
├── config/
│   └── config.yml
│
├── www/
│   ├── custom.css
│   ├── logo/
│   └── imagens/
│
└── README.md
```

Você pode adaptar essa estrutura caso identifique uma organização tecnicamente superior, mas preserve:

* separação entre interface, servidor e dados;
* módulos reutilizáveis;
* funções de cálculo centralizadas;
* facilidade para adicionar novas dimensões e indicadores.

---

# 5. Conceito visual

Quero uma estética de **dashboard institucional contemporâneo de saúde pública**.

A interface deve transmitir:

* credibilidade;
* clareza;
* precisão;
* modernidade;
* leveza;
* organização;
* caráter institucional.

Quero algo visualmente sofisticado, mas NÃO extravagante.

## Evitar

Não utilizar:

* excesso de gradientes;
* excesso de sombras;
* cores muito saturadas;
* dezenas de cores diferentes;
* cards com bordas pesadas;
* aparência de dashboard antigo;
* elementos apertados;
* fontes excessivamente grandes;
* excesso de informação na mesma tela;
* efeitos apenas decorativos;
* fundo escuro.

## Direção estética

Utilize:

* fundo geral muito claro, próximo de branco/cinza;
* cards brancos;
* muito espaço em branco;
* cantos arredondados discretos;
* sombras extremamente suaves;
* bordas claras;
* excelente alinhamento;
* hierarquia tipográfica;
* ícones simples;
* animações/transições apenas discretas;
* design responsivo.

A cor principal pode seguir uma identidade institucional baseada em **verde**, inspirada também nas fichas metodológicas fornecidas, utilizando tons complementares neutros e, quando necessário, azul/verde-azulado para elementos analíticos.

Defina no CSS variáveis globais, por exemplo:

```css
--primary
--primary-dark
--primary-light
--background
--surface
--text-primary
--text-secondary
--border
--success
--warning
--danger
```

Não espalhe códigos hexadecimais aleatoriamente pelo projeto.

Garanta contraste adequado e acessibilidade.

---

# 6. Cabeçalho

Crie um cabeçalho limpo contendo:

* identidade institucional à esquerda;
* nome do painel;
* subtítulo curto, se necessário;
* à direita, elementos discretos como:

  * última atualização;
  * botão de informações/metodologia;
  * eventualmente botão de ajuda.

Evite um cabeçalho excessivamente alto.

---

# 7. Navegação principal

Utilize uma navegação lateral elegante e recolhível.

Sugestão:

* Visão Geral
* Completude
* Oportunidade
* Consistência
* Cobertura
* Confiabilidade
* Não-duplicidade
* Acessibilidade
* Clareza metodológica
* Validade

Cada item deve possuir um ícone discreto.

Destaque visualmente a página selecionada.

A navegação deve funcionar corretamente em telas menores.

---

# 8. HOME — Visão Geral do IQD

A Home é uma das páginas visualmente mais importantes.

Quero preservar o conceito do modelo proposto:

**todas as dimensões + IQD geral no centro.**

Entretanto, quero uma versão muito mais sofisticada.

## Elemento central

Crie um componente central para:

### IQD

**Índice de Qualidade de Dados**

Exibir:

* valor geral;
* classificação qualitativa;
* indicação visual discreta do desempenho.

Exemplo conceitual:

```text
          93,4%
            IQD
Índice de Qualidade de Dados
          Excelente
```

NÃO use velocímetro/gauge semicircular tradicional.

Prefira um elemento circular/minimalista ou outro recurso visual moderno.

## Dimensões

Ao redor ou em composição visual harmoniosa com o IQD central, exiba as nove dimensões:

* Completude
* Oportunidade
* Consistência
* Cobertura
* Confiabilidade
* Não-duplicidade
* Acessibilidade
* Clareza metodológica
* Validade

Cada dimensão deve funcionar como um card/interação contendo:

* nome;
* resultado, quando disponível;
* classificação;
* pequeno indicador visual;
* possibilidade de clicar e navegar para a página correspondente.

Quando uma dimensão ainda não estiver implementada, apresentar de maneira elegante:

**Indicadores em definição**

e não inventar valores.

A composição precisa remeter a um **mapa geral da qualidade dos dados**, e não simplesmente a uma fileira comum de cartões.

O IQD deve ser claramente o elemento de maior importância hierárquica.

---

# 9. Página padrão de cada dimensão

Cada dimensão terá sua própria página.

Crie um componente/template reutilizável para que novas dimensões possam ser adicionadas sem duplicar toda a programação.

A página deve seguir aproximadamente esta estrutura:

```text
Breadcrumb / nome da dimensão

Título da dimensão
Breve descrição

[Filtros]

[KPI] [KPI] [KPI] [KPI] [...]

[Série temporal                      ]

[Comparação regional] [Distribuição]

[Mapa                               ]

[Tabela para investigação           ]
```

Não é obrigatório que todos os gráficos apareçam imediatamente.

A prioridade é criar uma arquitetura visual coerente e preparada para expansão.

---

# 10. KPIs de cada dimensão

No topo de cada página, incluir uma fileira de KPIs.

A lógica proposta é:

### KPI 1

**Nº Absoluto**

Representa o número absoluto relacionado ao universo/evento analisado.

### KPI 2

**Dimensão de Qualidade**

Exibir o resultado agregado da dimensão.

### KPI 3

**Indicador Primário**

### KPI 4

**Indicador Primário**

### ...

Criar automaticamente a quantidade necessária de cards de indicadores primários com base nos indicadores existentes na dimensão.

Portanto:

**NÃO hardcode a quantidade de indicadores.**

O componente deve funcionar dinamicamente.

Cada KPI deve apresentar:

* nome;
* valor;
* unidade;
* classificação, quando aplicável;
* tooltip ou acesso à metodologia;
* ícone discreto, quando fizer sentido.

Não transformar os KPIs em cards excessivamente grandes.

---

# 11. Página Consistência

A página **Consistência** será a demonstração funcional desta primeira versão.

Analise os dados disponíveis e identifique:

* quais `indicador_id` pertencem à dimensão Consistência;
* respectivos numeradores;
* denominadores;
* períodos disponíveis;
* modelos informacionais disponíveis;
* granularidade geográfica disponível.

Não invente mapeamentos.

Se os arquivos atuais não permitirem associar determinado `indicador_id` à Consistência de maneira segura, informe isso no README e não crie uma associação arbitrária.

Depois, implemente essa dimensão com dados reais.

---

# 12. Regra dos indicadores

A base intermediária possui numerador e denominador agregáveis.

O percentual deve ser sempre calculado como:

```r
SUM(numerador) / SUM(denominador) * 100
```

ou equivalente em `dplyr`.

É PROIBIDO calcular:

```r
mean(percentual)
```

sobre percentuais previamente calculados por grupos.

Sempre agregue numerador e denominador primeiro e calcule o resultado depois.

Crie uma função central reutilizável, por exemplo:

```r
calcular_indicador <- function(data) {
  ...
}
```

Trate explicitamente:

* denominador igual a zero;
* NA;
* registros sem identificação geográfica;
* filtros sem observações;
* valores fora do esperado.

---

# 13. Leitura dos dados

Os dados intermediários são armazenados como datasets Parquet particionados.

No R, priorize leitura lazy com:

```r
library(arrow)

ds <- open_dataset(caminho)
```

Não faça `collect()` da base inteira por padrão.

Como existem bases com milhões de registros, quero uma abordagem eficiente.

A filtragem deve ocorrer, sempre que tecnicamente possível, antes do `collect()`.

Exemplo conceitual:

```r
dados_filtrados <- ds |>
  filter(
    indicador_id %in% indicadores,
    ano %in% input$ano
  ) |>
  group_by(...) |>
  summarise(...) |>
  collect()
```

Analise quais operações podem ser executadas pelo Arrow antes do `collect()`.

---

# 14. Camada de acesso aos dados

Implemente uma camada separada de acesso aos dados.

Não quero chamadas de `open_dataset()` espalhadas dentro dos módulos gráficos.

Crie funções como, por exemplo:

```r
get_dataset()
get_indicadores()
get_serie_temporal()
get_resultado_geografico()
get_registros_investigacao()
```

A UI não deve conhecer detalhes físicos do armazenamento.

Utilize `config.yml` ou estratégia equivalente para os caminhos das bases.

Não coloque caminhos absolutos específicos de uma máquina diretamente no código.

---

# 15. Filtros

Com base na estrutura disponível, prepare filtros para:

### Tempo

* Ano
* Mês
* Semestre

### Geografia

* Brasil
* Região
* UF
* Município

### Estabelecimento

* CNES

### Modelo Informacional

Quando aplicável.

Os filtros devem ser hierárquicos quando fizer sentido.

Exemplo:

```text
Região
   ↓
UF
   ↓
Município
```

Ao selecionar uma Região, as opções de UF devem ser atualizadas.

Ao selecionar UF, atualizar Municípios.

Evite recarregamentos desnecessários.

---

# 16. Organização visual dos filtros

Não quero uma grande coluna de filtros ocupando metade da tela.

Crie uma solução elegante, como:

* sidebar recolhível;
* painel compacto de filtros;
* botão "Filtros" que abre área lateral;
* chips/badges mostrando filtros ativos.

Inclua:

**Limpar filtros**

e, quando fizer sentido:

**Aplicar filtros**

O usuário deve sempre conseguir entender quais filtros estão ativos.

---

# 17. Visualizações previstas

Prepare a arquitetura para as seguintes análises.

## A. Série histórica

Linha temporal do resultado da dimensão/indicador.

Permitir alternar, quando pertinente:

* ano;
* semestre;
* mês.

Visual limpo e com tooltip.

Não colocar marcadores em todos os pontos quando houver muitos períodos.

---

## B. Comparação regional

Gráfico de barras horizontais com o resultado por:

* Região;
* UF;
* Município;

conforme o nível selecionado.

Ordenar de forma coerente.

Linha de referência pode ser usada para o resultado Brasil quando pertinente.

---

## C. Análise por CNES

O modelo original propõe Treemap por CNES.

Você pode manter treemap caso ele seja a melhor opção para os dados, mas avalie criticamente a legibilidade.

Caso uma barra ordenada, tabela ou outra solução seja superior, documente a decisão.

Não altere a finalidade da análise.

---

## D. Mapa

Preparar um mapa do Brasil para análise por:

* UF;
* Município.

Utilizar `leaflet` ou solução compatível.

Criar legenda clara.

Tooltips devem mostrar:

* local;
* indicador;
* valor;
* numerador;
* denominador, quando pertinente.

Caso os arquivos geográficos ainda não estejam disponíveis, crie apenas o componente/esqueleto e documente o que será necessário para ativá-lo.

---

## E. Tabela de investigação

Criar uma área destinada aos registros/agrupamentos que demandem investigação da qualidade.

Preferencialmente utilizar `reactable`.

Preparar:

* pesquisa;
* ordenação;
* filtros;
* paginação;
* exportação, se tecnicamente apropriado.

Não exponha dados pessoais ou identificadores sensíveis sem necessidade.

---

# 18. Ficha metodológica dos indicadores

Quero aproveitar também o conceito das fichas metodológicas disponibilizadas no projeto.

Para cada indicador, crie um botão ou ícone:

**“Sobre o indicador”**

Ao clicar, abrir uma modal ou painel lateral contendo, quando essas informações existirem:

1. Conceituação
2. Interpretação
3. Usos
4. Limitações
5. Fonte
6. Método de cálculo
7. Categorias sugeridas para análise

A aparência da ficha deve ser moderna e integrada ao painel.

Não inventar conteúdo metodológico que ainda não esteja documentado.

---

# 19. Estados da interface

Crie estados adequados para:

### Carregando

Skeleton/loading discreto.

### Sem dados

Mensagem clara:

**“Não há dados disponíveis para os filtros selecionados.”**

### Não implementado

Mensagem:

**“Indicador em definição.”**

### Erro

Mensagem amigável para o usuário e detalhe técnico apenas no console/log.

Nunca mostrar erros brutos do R diretamente na interface.

---

# 20. Classificação qualitativa

Se houver faixas oficiais/documentadas para classificar resultados como, por exemplo:

* Excelente
* Bom
* Regular
* etc.

utilize apenas as faixas presentes nos documentos/dados.

Caso ainda não existam regras formais, não invente thresholds.

Nesse caso, apresente somente o resultado numérico e sinalize no código/README que a regra de classificação está pendente.

---

# 21. Responsividade

O dashboard deve ser desenvolvido primeiro pensando em desktop, mas deve adaptar-se adequadamente para:

* notebook;
* tablet;
* telas menores.

Cards devem quebrar de linha naturalmente.

Gráficos devem adaptar largura.

Sidebar deve ser recolhível.

Não permitir overflow horizontal desnecessário.

---

# 22. Acessibilidade

Adote boas práticas:

* contraste adequado;
* tamanho de fonte legível;
* não depender apenas de cores;
* tooltips;
* textos alternativos quando aplicável;
* foco de teclado;
* estados hover/focus;
* paleta compatível com diferentes tipos de visão de cores.

---

# 23. Performance

Como algumas bases possuem milhões de registros:

* evitar carregar toda a base na memória;
* filtrar antes de `collect()`;
* evitar cálculos repetitivos;
* utilizar `reactive()` de maneira organizada;
* utilizar cache quando houver benefício real;
* não executar a mesma consulta para cada gráfico se um único dataset agregado puder alimentá-los;
* evitar observers desnecessários.

Se considerar apropriado, utilize:

```r
bindCache()
```

ou estratégia equivalente.

Documente decisões de performance relevantes.

---

# 24. Reatividade

Centralize os filtros em um objeto reativo.

Conceitualmente:

```r
filtros <- reactive({
  list(
    ano = ...,
    mes = ...,
    regiao = ...,
    uf = ...,
    municipio = ...,
    cnes = ...
  )
})
```

Depois crie datasets reativos derivados.

Evite colocar longas sequências de filtros diretamente dentro de cada `renderPlot`.

---

# 25. Design dos gráficos

Todos os gráficos devem compartilhar uma identidade visual única.

Padronize:

* tipografia;
* tamanhos;
* tooltips;
* margens;
* títulos;
* legendas;
* gridlines;
* formatos percentuais;
* formatos numéricos.

Não colocar títulos redundantes dentro do gráfico quando o card já possui título.

Evite molduras pesadas.

Utilize grades extremamente discretas.

Formatação brasileira:

```text
1.234.567
93,4%
```

quando pertinente.

---

# 26. Interatividade

A interatividade deve servir à análise, não apenas à estética.

Utilize:

* tooltips;
* drill/down quando realmente necessário;
* seleção de dimensão;
* filtros;
* navegação clicável a partir da Home.

Evite animações excessivas.

---

# 27. Home navegável

Os cards/elementos das dimensões na Home devem ser clicáveis.

Exemplo:

```text
Usuário clica em "Consistência"
            ↓
Navega para página Consistência
            ↓
Visualiza KPIs e análises
```

Isso deve funcionar sem recarregar a aplicação inteira.

---

# 28. Não utilizar dados fictícios silenciosamente

Para as dimensões ainda não implementadas:

NÃO gerar valores aleatórios apenas para preencher o dashboard.

Se for absolutamente necessário utilizar mock data para demonstrar algum componente técnico, identifique visualmente e no código:

```text
DADO SIMULADO — APENAS DEMONSTRAÇÃO
```

Minha preferência é não utilizar números fictícios.

---

# 29. README

Crie um `README.md` explicando:

## Objetivo

Finalidade do painel.

## Arquitetura

Estrutura de arquivos.

## Fonte de dados

Como as bases são acessadas.

## Como executar

Pacotes necessários e comando para iniciar.

## Indicadores implementados

Informar que Consistência é a dimensão inicialmente demonstrada.

## Indicadores pendentes

Listar componentes ainda em definição.

## Regras de cálculo

Documentar a regra numerador/denominador.

## Performance

Explicar leitura lazy e consultas.

## Próximas etapas

Exemplo:

1. validar indicadores;
2. completar metadados;
3. implementar demais dimensões;
4. validar classificações;
5. adicionar geometrias;
6. testes;
7. homologação;
8. publicação.

---

# 30. Primeiro resultado que espero

Implemente uma primeira versão executável contendo:

### Home

* cabeçalho;
* navegação;
* IQD central;
* nove dimensões;
* navegação clicável;
* placeholders corretos.

### Consistência

* filtros;
* Nº absoluto;
* resultado agregado da dimensão, se tecnicamente calculável com os dados atuais;
* cards dinâmicos dos indicadores disponíveis;
* série temporal;
* comparação geográfica;
* área para análise por CNES;
* área de mapa;
* tabela de investigação;
* ficha metodológica.

### Demais dimensões

Criar a página estrutural, mas sem inventar indicadores.

---

# 31. Qualidade do código

O código final deve:

* executar;
* estar organizado;
* possuir comentários somente onde agregarem valor;
* evitar duplicação;
* usar nomes claros;
* utilizar funções;
* utilizar módulos Shiny;
* possuir tratamento de erros;
* ser preparado para manutenção por mais de um desenvolvedor.

Não quero um protótipo descartável.

Quero um **esqueleto que possa evoluir para a aplicação de produção**.

---

# 32. Antes de finalizar

Revise o projeto verificando:

1. A aplicação abre sem erro?
2. A Home está visualmente equilibrada?
3. O IQD possui clara prioridade visual?
4. As nove dimensões aparecem?
5. Consistência funciona com dados reais disponíveis?
6. Os demais indicadores não foram inventados?
7. Os filtros funcionam?
8. Os percentuais foram calculados corretamente?
9. A interface permanece organizada após filtros?
10. Existe tratamento para ausência de dados?
11. O código está modular?
12. A leitura dos parquets é eficiente?
13. A estética é consistente?
14. O painel é responsivo?
15. A estrutura permite adicionar novos indicadores sem redesenhar tudo?

Corrija os problemas encontrados antes de considerar a versão concluída.

---

# 33. Forma de trabalhar

Não comece criando dezenas de gráficos isolados.

Siga esta ordem:

### Fase 1

Analise dados e arquivos disponíveis.

### Fase 2

Apresente/defina a árvore do projeto e arquitetura.

### Fase 3

Crie o design system.

### Fase 4

Crie layout global e navegação.

### Fase 5

Crie a Home.

### Fase 6

Crie o template das páginas de dimensão.

### Fase 7

Implemente Consistência.

### Fase 8

Implemente filtros e consultas.

### Fase 9

Adicione visualizações.

### Fase 10

Revise responsividade, performance e experiência do usuário.

### Fase 11

Documente.

Ao tomar decisões não especificadas, priorize:

**clareza > estética decorativa**
**correção dos indicadores > aparência**
**reutilização > duplicação**
**performance > conveniência de implementação**
**interface limpa > excesso de informação**

O resultado deve parecer um **produto institucional de BI em saúde pública moderno e profissional**, e não simplesmente uma aplicação Shiny com gráficos colocados em caixas.

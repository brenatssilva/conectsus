# Painel IQD — Qualidade dos dados da RNDS

Esqueleto funcional de um painel de Business Intelligence em R Shiny para avaliação da qualidade dos dados da RNDS. Nesta versão, a dimensão **Consistência** é demonstrada com dados reais da base intermediária; as demais dimensões aparecem como estrutura visual, sem valores inventados.

## Objetivo

Apoiar a leitura analítica dos indicadores de qualidade de dados da RNDS a partir da base intermediária (`tb_<modelo>_intermediario`), com cálculo correto de percentuais, filtros hierárquicos e páginas reutilizáveis por dimensão.

## Arquitetura

```text
painel_iqd/
├── app.R
├── config/config.yml          # caminhos das bases
├── config/catalogo.yml        # dimensões, indicadores e fichas
├── R/                         # acesso a dados, indicadores e módulos Shiny
└── www/custom.css             # design system (variáveis CSS)
```

A interface (módulos), o servidor e a leitura dos Parquet são separados. Novas dimensões entram no catálogo e reutilizam `mod_dimensao.R` sem duplicar o layout.

## Fonte de dados

Parquets particionados em `dados_intermediarios_iqd_07082026/dados_intermediarios/`:

| Modelo | Pasta | Indicadores |
|---|---|---|
| RIA-R | `ria_r/tb_ria_r_intermediario` | i001, i002, i018 |
| RA | `ra/tb_ra_intermediario` | i001, i002 |
| REL | `rel/tb_rel_intermediario` | i001, i002 |

Caminhos relativos estão em `config/config.yml`. Não há caminhos absolutos de máquina no código.

A coluna `dimensao_qualidade` da base vale **Consistência** para todos os indicadores atualmente implementados no pipeline. Esse mapeamento não foi inferido de forma arbitrária.

## Como executar

Requer R 4.x e os pacotes:

`shiny`, `bslib`, `bsicons`, `dplyr`, `tidyr`, `arrow`, `purrr`, `stringr`, `lubridate`, `scales`, `plotly`, `leaflet`, `reactable`, `htmltools`, `config`, `yaml`, `rlang`

Na raiz deste repositório:

```r
shiny::runApp("painel_iqd")
```

Ou, dentro de `painel_iqd/`:

```r
shiny::runApp()
```

## Indicadores implementados

Dimensão **Consistência**:

- **i001** — proporção de registros com CNES estruturalmente válido (RIA-R, RA, REL)
- **i002** — proporção de registros com `dt_entrada_rnds >= dt_evento` (RIA-R, RA, REL)
- **i018** — idade calculada igual a `nu_idade_paciente` (**somente RIA-R**)

O nº absoluto usa o denominador do **i001** (total de registros finais com `dt_entrada_rnds` válida).

## Indicadores pendentes

- **IQD** (índice composto) e o resultado agregado da dimensão: não há fórmula oficial nos materiais; a interface exibe “Indicador em definição.”
- **Classificação qualitativa** (Excelente, Bom, Regular etc.): não há faixas documentadas; não é exibida.
- Demais dimensões (completude, oportunidade, cobertura, confiabilidade, não-duplicidade, acessibilidade, clareza metodológica, validade): esqueleto visual apenas.
- Fichas i003–i014, i016–i017, i019–i024 existem como requisitos, mas **não estão na base intermediária**. i015 consta como excluído na ficha.
- **Mapa**: sem malhas IBGE no repositório. O componente está pronto para receber geometrias ligadas a `co_municipio_ocorrencia` (IBGE 6 dígitos).

## Regras de cálculo

Numerador e denominador são aditivos. O percentual é:

```text
SUM(numerador) / SUM(denominador) * 100
```

É incorreto calcular a média de percentuais já agregados. Denominador zero ou ausência de linhas resulta em valor ausente e estado de interface “sem dados”. Registros sem geografia identificada entram no total Brasil e aparecem como “Não identificado” nas quebras.

## Performance

A leitura usa `arrow::open_dataset()` (lazy). Filtros, `group_by` e `summarise` ocorrem antes de `collect()`. Consultas de KPI, série e geografia compartilham a mesma lógica de agregação; CNES e tabela são consultas à parte (Top N). Lookups de geografia/tempo são coletados uma vez na inicialização.

## Decisões de produto

- **Treemap por CNES** não foi usado: há dezenas de milhares de estabelecimentos. A análise por CNES usa barras dos menores percentuais (i001) e tabela pesquisável.
- Gráficos: `plotly` (série e barras) e `reactable` (investigação). Identidade visual via CSS, fundo claro, verde institucional.
- Fichas metodológicas de i001, i002 e i018 vêm dos documentos do projeto, com o método de cálculo alinhado ao **dicionário da base intermediária** quando ele diverge da ficha de requisitos (caso do i018).

## Próximas etapas

1. Validar indicadores com a equipe responsável.
2. Completar metadados e demais indicadores na base.
3. Implementar as outras dimensões quando houver `indicador_id` associado.
4. Definir e validar faixas de classificação e a fórmula do IQD.
5. Incluir geometrias IBGE e ativar o mapa.
6. Testes automatizados das agregações.
7. Homologação institucional.
8. Publicação.

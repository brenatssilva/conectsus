# Como usar a base intermediária (RIA-R, RA, REL)

Guia de uso dos parquets `tb_<modelo>_intermediario` para quem vai consumir os dados.

## Visão geral

A **base intermediária** é o parquet consolidado `tb_<modelo>_intermediario`, um por modelo
informacional ativo (RIA-R, RA, REL). Cada linha representa um grupo com um
`numerador`/`denominador` **aditivos** — nunca um percentual pré-calculado. Os dados de
origem são uma amostra de 10% da RNDS.

| Modelo | Nome do parquet consolidado | Linhas | Colunas | `indicador_id` presentes |
|---|---|---:|---:|---|
| RIA-R | `tb_ria_r_intermediario` | 5.781.564 | 13 | i001, i002, i018 |
| RA | `tb_ra_intermediario` | 712.890 | 13 | i001, i002 |
| REL | `tb_rel_intermediario` | 377.214 | 13 | i001, i002 |

### Colunas (13, idênticas nos três modelos)

```text
modelo_informacional, dimensao_qualidade, indicador_id,
ano, mes, co_cnes, co_municipio_ocorrencia,
no_municipio_ocorrencia, sg_uf, regiao_brasil,
numerador, denominador, dt_processamento
```

### Grão da tabela

Uma linha por combinação de `indicador_id, ano, mes, co_cnes, co_municipio_ocorrencia,
no_municipio_ocorrencia, sg_uf, regiao_brasil` — ou seja, o agrupamento é por indicador,
período (ano/mês), estabelecimento (`co_cnes`), município de ocorrência e região.

### Numerador, denominador e percentual

`numerador`/`denominador` são **polimórficos**: o significado muda conforme `indicador_id`
(ex.: para i001, numerador = registros com CNES estruturalmente válido; para i002, numerador
= registros elegíveis com `dt_entrada_rnds >= dt_evento`). Sempre são soma/contagem bruta por
grupo, nunca um percentual pronto. O percentual só é calculado na consulta:

```text
percentual = SUM(numerador) / SUM(denominador) * 100
```

Não fazer média simples de percentuais por grupo/unidade — isso distorce o resultado quando
os grupos têm tamanhos diferentes.

### Dicionário de dados completo

Para detalhe coluna a coluna (tipo, nulos, valores distintos, categorias, min/max, se compõe
o grão, linhagem/origem raw) das 13 colunas de cada modelo, ver
`dicionario_dados_bases_intermediarias.xlsx` (uma aba por modelo).

## Como ler os dados

### Pandas

```python
import pandas as pd

# troque pelo nome do parquet consolidado do modelo desejado:
#   RIA-R -> tb_ria_r_intermediario | RA -> tb_ra_intermediario | REL -> tb_rel_intermediario
path = "tb_ria_r_intermediario"  # aponte para a pasta onde este parquet esta disponivel
df = pd.read_parquet(path, engine="pyarrow")
```

### Spark

```python
df = spark.read.parquet(path)  # mesma pasta do parquet consolidado
```

### R

```r
library(arrow)

path <- "tb_ria_r_intermediario"  # mesma pasta do parquet consolidado
ds <- open_dataset(path)
```

`tb_<modelo>_intermediario` é uma **pasta** com o parquet particionado em múltiplos
arquivos, não um arquivo único — nos três exemplos acima, `path` aponta para o caminho da
pasta, não para um arquivo dentro dela.

### Padrão genérico: total BRASIL e quebra por região (R + dplyr)

```r
library(arrow)
library(dplyr)

path <- "tb_ria_r_intermediario"  # troque pelo parquet consolidado do modelo desejado
ds <- open_dataset(path)

sub <- ds %>% filter(indicador_id == "i001") %>% collect()

# total BRASIL
sub %>%
  summarise(numerador = sum(numerador), denominador = sum(denominador)) %>%
  mutate(percentual = round(numerador / denominador * 100, 2))

# quebra por região
sub %>%
  mutate(regiao_brasil = coalesce(regiao_brasil, "(nulo/não identificado)")) %>%
  group_by(regiao_brasil) %>%
  summarise(numerador = sum(numerador), denominador = sum(denominador)) %>%
  mutate(percentual = round(numerador / denominador * 100, 2))
```

`regiao_brasil` é nulo quando `co_municipio_ocorrencia` não foi encontrado em
`dim_geografia_chave6.parquet` — esses registros continuam no total BRASIL, só não entram em
nenhuma das 5 regiões nomeadas (ver linha "(nulo/não identificado)" nas tabelas da próxima
seção).

## Exemplo prático — indicadores i001 e i002 (BRASIL e por região)

Os valores abaixo foram calculados em 2026-08-07 com o código da seção "Como ler os dados"
acima, direto dos parquets consolidados. Em cada tabela, a soma das 5 regiões nomeadas mais a
linha "(nulo/não identificado)" reconcilia exatamente com a linha **BRASIL (total)**.
Rodando o mesmo código sobre os mesmos parquets, os valores devem bater; se os parquets forem
reprocessados depois desta data, os valores podem mudar e este documento fica desatualizado
até ser reexecutado e atualizado manualmente (não há checagem automática de staleness).

### RIA-R

**i001**

| Região | Numerador | Denominador | Percentual |
|---|---:|---:|---:|
| **BRASIL (total)** | **97.873.347** | **105.279.126** | **92,97%** |
| Centro-Oeste | 7.427.661 | 8.673.713 | 85,63% |
| Nordeste | 25.176.842 | 26.773.514 | 94,04% |
| Norte | 9.755.533 | 10.136.499 | 96,24% |
| Sudeste | 39.575.353 | 42.074.952 | 94,06% |
| Sul | 15.935.501 | 17.617.987 | 90,45% |
| (nulo/não identificado) | 2.457 | 2.461 | 99,84% |

**i002**

| Região | Numerador | Denominador | Percentual |
|---|---:|---:|---:|
| **BRASIL (total)** | **105.279.001** | **105.279.126** | **100,00%** |
| Centro-Oeste | 8.673.713 | 8.673.713 | 100,00% |
| Nordeste | 26.773.513 | 26.773.514 | 100,00% |
| Norte | 10.136.499 | 10.136.499 | 100,00% |
| Sudeste | 42.074.946 | 42.074.952 | 100,00% |
| Sul | 17.617.869 | 17.617.987 | 100,00% |
| (nulo/não identificado) | 2.461 | 2.461 | 100,00% |

### RA

**i001**

| Região | Numerador | Denominador | Percentual |
|---|---:|---:|---:|
| **BRASIL (total)** | **92.082.378** | **98.664.817** | **93,33%** |
| Centro-Oeste | 15.559.054 | 17.187.860 | 90,52% |
| Nordeste | 27.455.784 | 29.834.529 | 92,03% |
| Norte | 12.931.475 | 13.192.278 | 98,02% |
| Sudeste | 20.677.141 | 21.282.658 | 97,15% |
| Sul | 15.367.422 | 16.471.658 | 93,30% |
| (nulo/não identificado) | 91.502 | 695.834 | 13,15% |

**i002**

| Região | Numerador | Denominador | Percentual |
|---|---:|---:|---:|
| **BRASIL (total)** | **98.663.571** | **98.664.817** | **100,00%** |
| Centro-Oeste | 17.187.797 | 17.187.860 | 100,00% |
| Nordeste | 29.834.099 | 29.834.529 | 100,00% |
| Norte | 13.192.233 | 13.192.278 | 100,00% |
| Sudeste | 21.281.959 | 21.282.658 | 100,00% |
| Sul | 16.471.649 | 16.471.658 | 100,00% |
| (nulo/não identificado) | 695.834 | 695.834 | 100,00% |

### REL

**i001**

| Região | Numerador | Denominador | Percentual |
|---|---:|---:|---:|
| **BRASIL (total)** | **4.500.874** | **4.880.330** | **92,22%** |
| Centro-Oeste | 463.093 | 504.189 | 91,85% |
| Nordeste | 518.458 | 577.570 | 89,77% |
| Norte | 180.741 | 187.785 | 96,25% |
| Sudeste | 2.753.954 | 2.955.372 | 93,18% |
| Sul | 584.361 | 654.528 | 89,28% |
| (nulo/não identificado) | 267 | 886 | 30,14% |

**i002**

| Região | Numerador | Denominador | Percentual |
|---|---:|---:|---:|
| **BRASIL (total)** | **4.835.509** | **4.874.954** | **99,19%** |
| Centro-Oeste | 504.072 | 504.189 | 99,98% |
| Nordeste | 540.588 | 577.570 | 93,60% |
| Norte | 187.784 | 187.785 | 100,00% |
| Sudeste | 2.948.426 | 2.949.996 | 99,95% |
| Sul | 653.753 | 654.528 | 99,88% |
| (nulo/não identificado) | 886 | 886 | 100,00% |

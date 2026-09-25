# Quem morre no trânsito de SP, onde e quando?

Análise dos sinistros de trânsito do estado de São Paulo (2022–2025) com os
dados abertos do Infosiga-SP (Detran-SP), para identificar onde e quando uma
ação de segurança viária teria mais efeito.

## Principais achados
<!-- Preencher após as 5 consultas, com números das queries -->
1. 
2. 
3. 

## Perguntas
1. Como evoluem sinistros e mortes por mês? Existe sazonalidade?
2. Quais municípios concentram mais mortes?
3. Que dia da semana e turno são mais letais, e não só mais frequentes?
4. Qual o perfil das vítimas fatais?
5. Que combinação de fatores está associada à maior gravidade?

## Dados
- **Fonte:** [Infosiga-SP](https://infosiga.detran.sp.gov.br/), Detran-SP
  (dados abertos): tabelas de sinistros, pessoas e veículos.
- **Período:** 2022–2025. Os dados de 2015–2018 cobrem só acidentes fatais e
  2026 é ano incompleto, por isso ficaram de fora.
- **Volume após a limpeza:** 789.122 sinistros, 23.211 vítimas fatais e
  1.015.991 veículos.

## Como foi feito
1. **Leitura (`01_exploracao`):** 6 CSVs em Latin-1, separador `;`,
   empilhados por período com checagem de colunas.
2. **Limpeza (`02_limpeza`):** datas convertidas para `datetime`, 8 colunas
   redundantes de data reduzidas a 2, colunas 100% vazias removidas.
   Resultado salvo em Parquet.
3. **Banco (`03_analise_sql`):** as 3 tabelas carregadas num SQLite
   (`infosiga.db`), com contagens validadas.
4. **Análise (SQL):** consultas em `sql/consulta.sql`.

## Decisões e limitações
- 76% das vítimas morreram no mesmo dia do sinistro e o restante em até 30
  dias. Por isso as mortes são agrupadas pela data do **sinistro**, e não do
  óbito, para comparar com o número de acidentes no mesmo mês.
- Nulos (ex.: marca/modelo e cor do veículo) foram mantidos como `NULL`, sem
  preenchimento artificial.

## Como reproduzir
```bash
git clone <URL-do-repo>
cd project_sinistros_sp
python -m venv .venv
source .venv/Scripts/activate   # Linux/Mac: source .venv/bin/activate
pip install -r requirements.txt
```
Baixe os dados em infosiga.detran.sp.gov.br, coloque os CSVs em `data/raw/`
e rode os notebooks em ordem (`01`, `02`, `03`).

## Tecnologias
Python (pandas, matplotlib), SQLite, SQL, Parquet.
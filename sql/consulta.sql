-- #Como evoluem sinistros e mortes por mes? existe sazonalidade?
--pct mensal
SELECT s.mes_sinistros AS mes_ano, s.total_sinistros, p.total_obitos,
	ROUND(100.0  * p.total_obitos / s.total_sinistros, 1) AS pct
FROM
    (
    SELECT strftime('%Y-%m', data_sinistro) AS mes_sinistros, COUNT(*) AS total_sinistros
    FROM sinistros
    GROUP BY strftime('%Y-%m', data_sinistro)
    ) s
LEFT JOIN
    (
     SELECT strftime('%Y-%m', data_sinistro) AS mes_obitos, COUNT(*) AS total_obitos
     FROM pessoas
     WHERE gravidade_lesao = 'FATAL'
     GROUP BY strftime('%Y-%m', data_sinistro)
    ) p
ON s.mes_sinistros = p.mes_obitos
ORDER BY mes_ano;

--pct anual
SELECT mes_ano, SUM(total_sinistros), SUM(total_obitos), ROUND(100 * SUM(total_obitos) / SUM(total_sinistros), 2) AS pct
FROM (SELECT s.mes_sinistros AS mes_ano, s.total_sinistros, p.total_obitos,
	ROUND(100.0  * p.total_obitos / s.total_sinistros, 1) AS pct
FROM
    (
    SELECT strftime('%Y-%m', data_sinistro) AS mes_sinistros, COUNT(*) AS total_sinistros
    FROM sinistros
    GROUP BY strftime('%Y-%m', data_sinistro)
    ) s
LEFT JOIN
    (
     SELECT strftime('%Y-%m', data_sinistro) AS mes_obitos, COUNT(*) AS total_obitos
     FROM pessoas
     WHERE gravidade_lesao = 'FATAL'
     GROUP BY strftime('%Y-%m', data_sinistro)
    ) p
ON s.mes_sinistros = p.mes_obitos
ORDER BY mes_ano)
GROUP BY SUBSTR(mes_ano, 1, 4)
-- ## resultado de crescimento em README


-- # quais municipios concentram mais mortes?
SELECT s.municipio, s.total_sinistros , p.total_mortes, ROUND(100.0 * p.total_mortes / s.total_sinistros, 1) AS pct
FROM 
	(
	SELECT municipio, COUNT(*) as total_sinistros 
	FROM sinistros
	GROUP BY municipio
	) s
INNER JOIN
	(
	SELECT municipio, COUNT(*) as total_mortes
	FROM pessoas
	WHERE gravidade_lesao = 'FATAL'
	GROUP BY municipio
	) p
ON p.municipio = s.municipio
WHERE s.total_sinistros  >= 1000
ORDER BY pct DESC
LIMIT 10;
-- ## resultados baseados em municipios mais fatais
-- IBIUNA | %7,8
-- PIEDADE | %7,0
-- ITANHAEM | %6,7

SELECT s.municipio, s.total_sinistros , p.total_mortes, ROUND(100.0 * p.total_mortes / s.total_sinistros, 1) AS pct
FROM 
	(
	SELECT municipio, COUNT(*) as total_sinistros 
	FROM sinistros
	GROUP BY municipio
	) s
INNER JOIN
	(
	SELECT municipio, COUNT(*) as total_mortes
	FROM pessoas
	WHERE gravidade_lesao = 'FATAL'
	GROUP BY municipio
	) p
ON p.municipio = s.municipio
ORDER BY p.total_mortes DESC
LIMIT 10;
-- ## resultados baseados em municipios com mais obitos
-- SAO PAULO | 4.556 | %2,5
-- GUARULHOS | 730 | %3,4
-- CAMPINAS | 666 | %3,4


-- # que dia da semana e turno são mais letais, e não só mais frequentes?
SELECT s.dia_da_semana, s.turno, s.sinistros, 
	COALESCE(p.mortes, 0) AS mortes,
	ROUND(100.0 * COALESCE(p.mortes, 0) / s.sinistros, 1) AS mortes_por_cem
FROM 
    (SELECT dia_da_semana, turno, COUNT(*) AS sinistros
    FROM sinistros
    GROUP BY dia_da_semana, turno
	) s
LEFT JOIN
	(
	SELECT si.dia_da_semana, si.turno, COUNT(*) AS mortes
	FROM pessoas p
	JOIN sinistros si
	ON p.id_sinistro = si.id_sinistro 
	WHERE p.gravidade_lesao = 'FATAL'
	GROUP BY si.dia_da_semana, si.turno
	) p
ON s.dia_da_semana  = p.dia_da_semana  
AND s.turno = p.turno 
WHERE s.turno <> 'NAO DISPONIVEL'
  AND s.sinistros >= 1000
ORDER BY mortes_por_cem DESC
LIMIT 10;
-- ## resultados
-- SEXTA-FEIRA | MADRUGADA | SINISTROS 8.580 | MORTES 593 | 6,9 a cada 100 
-- SEGUNDA-FEIRA | MADRUGADA | SINISTROS 9.949 | MORTES 657 | 6,6 a cada 100
-- QUARTA-FEIRA | MADRUGADA | SINISTROS 6.202 | MORTES 408 | 6,6 a cada 100 


-- # qual o perfil das vitimas fatais?
-- porcentagem de faixa etaria
SELECT faixa_etaria_demografica, 
	COUNT(*) AS mortes,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM pessoas
WHERE gravidade_lesao = 'FATAL' AND 
faixa_etaria_demografica IS NOT NULL
GROUP BY faixa_etaria_demografica
ORDER BY mortes DESC;
-- ## resultados com vitima sobre base informada
-- 20 a 24 com %12,2
-- 25 a 29 com %10,5
-- 40 a 44 com %9.1

-- porcentagem de sexo
SELECT sexo, 
	COUNT(*) AS total, 
	ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM pessoas
WHERE gravidade_lesao = 'FATAL'
GROUP BY sexo
ORDER BY pct DESC;
-- ## resultados
-- MASCULINO %82,0
-- FEMININO %17,7
-- NÃO DISPONIVEL %0,3

-- porcentagem de profissao
SELECT profissao, 
	COUNT(*) AS total, 
	ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM pessoas
WHERE gravidade_lesao = 'FATAL'
GROUP BY profissao
ORDER BY pct DESC;
-- ## resultado limitado para analise
-- NULLO %63,6 

-- porcentagem tipo de vitima
SELECT tipo_de_vitima, 
	COUNT(*) AS total, 
	ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM pessoas
WHERE gravidade_lesao = 'FATAL'
GROUP BY tipo_de_vitima 
ORDER BY pct DESC;
-- ## resultados
-- CONDUTOR %62
-- PEDESTRE %22
-- PASSAGEIRO %11

-- porcentagem veiculo
SELECT tipo_veiculo_vitima, 
	COUNT(*) AS total, 
	ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM pessoas
WHERE gravidade_lesao = 'FATAL'
GROUP BY tipo_veiculo_vitima 
ORDER BY pct DESC;
-- ## resultados
-- MOTOCICLETA %41 
-- SEM VEICULO %22
-- AUTOMOVEL %22

-- proporcao tipo de vitima e tipo veiculo
SELECT tipo_de_vitima, tipo_veiculo_vitima, 
	COUNT(*) AS total, 
	ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM pessoas
WHERE gravidade_lesao = 'FATAL'
GROUP BY tipo_de_vitima, tipo_veiculo_vitima
ORDER BY total DESC;
-- ## resultados
-- CONDUTOR MOTOCICLISTA 37,0 a cada 100 
-- PEDESTRE 22,9 a cada 100
-- CONDUTOR AUTOMOVEL 14,9 a cada 100


-- # qual combinação de fatores está associada a maior gravidade
SELECT si.tipo_via, si.tp_sinistro_primario, 
	si.dia_da_semana, si.turno, si.total_sinistros, so.total_obitos,
	ROUND(100.0 * so.total_obitos / si.total_sinistros, 2) AS pct
FROM (
	SELECT si.tipo_via, si.tp_sinistro_primario, si.dia_da_semana, si.turno, COUNT(*) AS total_obitos
	FROM sinistros si
	LEFT JOIN pessoas p
	ON si.id_sinistro = p.id_sinistro  
	WHERE p.gravidade_lesao = 'FATAL'
	GROUP BY si.tipo_via, si.tp_sinistro_primario, si.dia_da_semana, si.turno
	) so
RIGHT JOIN 
	(
	SELECT si.tipo_via, si.tp_sinistro_primario, si.dia_da_semana, si.turno, COUNT(*) AS total_sinistros
	FROM sinistros si
	GROUP BY si.tipo_via, si.tp_sinistro_primario, si.dia_da_semana, si.turno
	) si
ON so.tipo_via = si.tipo_via
AND so.tp_sinistro_primario = si.tp_sinistro_primario
AND so.dia_da_semana = si.dia_da_semana 
AND so.turno = si.turno 
WHERE si.tp_sinistro_primario <> 'NAO INFORMADO'
AND si.turno <> 'NAO DISPONIVEL'
AND si.total_sinistros >= 500
ORDER BY pct DESC
LIMIT 10;
-- ## resultados
-- ESTRADAS E RODOVIAS | ATROPELAMENTO | Domingo | NOITE | sinistros(505) | obitos(194) | 38,42 a cada 100
-- ESTRADAS E RODOVIAS | ATROPELAMENTO | Sexta-feira | NOITE | sinistros(556) | obitos(191) | 34,35 a cada 100
-- ESTRADAS E RODOVIAS | ATROPELAMENTO | Sábado | NOITE | sinistros(613) | obitos(208) | 33,93 a cada 100
-- -- Como evoluem sinistros e mortes por mes? existe sazonalidade?

SELECT pa.mes_sinistros, pa.total_sinistros, pb.mes_obitos, pb.total_mortes
FROM (SELECT strftime("%Y-%m", data_sinistro) AS mes_sinistros, 
        COUNT(*) AS total_sinistros
    FROM pessoas
    WHERE gravidade_lesao = 'FATAL'
    GROUP BY strftime("%Y-%m", data_sinistro)
    ) pa
LEFT JOIN (
    SELECT strftime("%Y-%m", data_obito) AS mes_obitos, COUNT(*) AS total_mortes
    FROM pessoas
    WHERE gravidade_lesao = 'FATAL'
    GROUP BY strftime("%Y-%m", data_obito)
) pb ON pa.mes_sinistros = pb.mes_obitos
ORDER BY pa.mes_sinistros

-- pergunta 2

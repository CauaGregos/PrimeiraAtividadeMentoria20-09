
-- EXEMPLO USANDO SUBQUERY PARA INSERIR DADOS EM OUTRA TABELA

INSERT INTO resumo_bancario (user_id,total_depositos,total_transferencias,mes)

	SELECT 
	    user_id,
	    SUM(CASE 
	            WHEN tipo_transacao = 'deposito' THEN total
	            ELSE 0 
	        END) AS total_depositos,
	    SUM(CASE 
	            WHEN tipo_transacao = 'transferencia' THEN total
	            ELSE 0 
	        END) AS total_transferencias,
	        mes
	      
	FROM ( 
	    -- Depósitos
	    SELECT 
	        payee_id AS user_id, 
	        VALUE AS total, 
	        'deposito' AS tipo_transacao,
	        MONTH(FROM_UNIXTIME(created_at)) AS mes
	    FROM smartphone_bank_invoices
	    WHERE VALUE > 0
	    AND YEAR(FROM_UNIXTIME(created_at)) = 2024
	    AND MONTH(FROM_UNIXTIME(created_at)) = 8
	
	    UNION ALL
	    
	    -- Transferências
	    SELECT 
	        payer_id AS user_id, 
	        VALUE AS total, 
	        'transferencia' AS tipo_transacao,
	        MONTH(FROM_UNIXTIME(created_at)) AS mes
	    FROM smartphone_bank_invoices
	    WHERE payer_id != payee_id
	    AND YEAR(FROM_UNIXTIME(created_at)) = 2024
	    AND MONTH(FROM_UNIXTIME(created_at)) = 8
	    
	) AS transacoes
	GROUP BY user_id;
	

-- CRIANDO INDEX 	
CREATE INDEX payee_id_payer_id ON smartphone_bank_invoices (payee_id,payer_id)





-- EXEMPLO DE CRIAÇÃO DE INDEX DIRETO NA TABELA
CREATE TABLE `resumo_bancario` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`user_id` INT(11) NOT NULL DEFAULT '0',
	`total_depositos` INT(11) NULL DEFAULT '0',
	`total_transferencias` INT(11) NULL DEFAULT '0',
	`mes` INT(11) NULL DEFAULT '0',
	PRIMARY KEY (`user_id`) USING BTREE,
	INDEX `index_id` (`id`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=8
;




-- EXEMPLO DE CRIÇÃO DE TRIGGER
DELIMITER $$

CREATE TRIGGER Atualizar_Resumo
AFTER INSERT ON smartphone_bank_invoices
-- para cada linha inserida na smartphone_bank_invoices
FOR EACH ROW
BEGIN

	DELETE FROM resumo_bancario;
	call atualizando_resumos();
	
END $$

DELIMITER ;




-- EXEMPLO DE PROCEDURE SEM PARAMETROS
DELIMITER $$

CREATE PROCEDURE atualizando_resumos ()
BEGIN
    
    
   INSERT INTO resumo_bancario (user_id,total_depositos,total_transferencias,mes)

	SELECT 
	    user_id,
	    SUM(CASE 
	            WHEN tipo_transacao = 'deposito' THEN total
	            ELSE 0 
	        END) AS total_depositos,
	    SUM(CASE 
	            WHEN tipo_transacao = 'transferencia' THEN total
	            ELSE 0 
	        END) AS total_transferencias,
	        mes
	      
	FROM ( 
	    -- Depósitos
	    SELECT 
	        payee_id AS user_id, 
	        VALUE AS total, 
	        'deposito' AS tipo_transacao,
	        MONTH(FROM_UNIXTIME(created_at)) AS mes
	    FROM smartphone_bank_invoices
	    WHERE VALUE > 0
	
	    UNION ALL
	    
	    -- Transferências
	    SELECT 
	        payer_id AS user_id, 
	        VALUE AS total, 
	        'transferencia' AS tipo_transacao,
	        MONTH(FROM_UNIXTIME(created_at)) AS mes
	    FROM smartphone_bank_invoices
	    WHERE payer_id != payee_id
	    
	) AS transacoes
	GROUP BY user_id;
    
    
END $$

DELIMITER ;






	
	
	
	

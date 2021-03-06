DROP DATABASE IF EXISTS DBCOMPRAPARCELADA;
CREATE DATABASE DBCOMPRAPARCELADA;
USE DBCOMPRAPARCELADA;

CREATE TABLE COMPRA (
	IDCOMPRA INT NOT NULL AUTO_INCREMENT
    , DTCOMPRA DATE
	, VALOR_TOTAL NUMERIC(8,2)
	, QTDE_PARCELA INT
	, DT_COMPRA DATE
    , PRIMARY KEY (IDCOMPRA)
);

CREATE TABLE PARCELA(
	IDPARCELA INT NOT NULL AUTO_INCREMENT
	, IDCOMPRA INT NOT NULL
	, NUMERO INT
	, DT_VENCIMENTO DATE
	, VALOR NUMERIC(8,2)
	, PRIMARY KEY (IDPARCELA)
	, FOREIGN KEY (IDCOMPRA) REFERENCES COMPRA (IDCOMPRA)
);

DELIMITER $$

CREATE PROCEDURE SP_REGISTRAR_COMPRA(pVALOR NUMERIC(8,2), pQTDE_PARCELA INT)
BEGIN

	DECLARE vIDCOMPRA INT;
    DECLARE vCONTADOR INT;
    DECLARE vDTVENCIMENTO DATE;
    DECLARE vVALORPARCELA NUMERIC(8,2);
    DECLARE vVALORDIFERENCA NUMERIC(8,2);
    DECLARE vIDPARCELA INT;

	INSERT INTO COMPRA(VALOR_TOTAL, QTDE_PARCELA, DT_COMPRA)
    VALUES(pVALOR, pQTDE_PARCELA, NOW());
    
    SET vIDCOMPRA = LAST_INSERT_ID();
    SET vVALORPARCELA = pVALOR/pQTDE_PARCELA;
    SET vDTVENCIMENTO = NOW();
	SET vCONTADOR = 1;
    
    WHILE(vCONTADOR <= pQTDE_PARCELA)DO
    
		SET vDTVENCIMENTO = DATE_ADD(vDTVENCIMENTO, INTERVAL 1 MONTH);
		
		INSERT INTO PARCELA(IDCOMPRA, NUMERO, DT_VENCIMENTO, VALOR)
        VALUES(vIDCOMPRA, vCONTADOR, vDTVENCIMENTO, vVALORPARCELA);
        
        SET vCONTADOR = vCONTADOR + 1;
	END WHILE;
    
    SELECT 
		COMPRA.VALOR_TOTAL - SUM(PARCELA.VALOR) 
		, MAX(PARCELA.IDPARCELA)
	INTO 
		vVALORDIFERENCA
        , vIDPARCELA
	FROM
		PARCELA
		INNER JOIN COMPRA ON
		COMPRA.IDCOMPRA = PARCELA.IDCOMPRA
	WHERE
		PARCELA.IDCOMPRA = 1
	GROUP BY COMPRA.VALOR_TOTAL;
    
    UPDATE PARCELA 
	SET VALOR = VALOR + vVALORDIFERENCA
    WHERE IDPARCELA = vIDPARCELA;
    
END $$

DELIMITER ;

SELECT * FROM COMPRA;
SELECT * FROM PARCELA WHERE IDCOMPRA = 2;
SELECT SUM(VALOR) FROM PARCELA WHERE IDCOMPRA = 2;

CALL SP_REGISTRAR_COMPRA(1200, 24);
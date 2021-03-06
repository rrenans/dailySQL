SET SQL_SAFE_UPDATES = 0;

DROP DATABASE IF EXISTS DBESTATISTICA;

CREATE DATABASE DBESTATISTICA;

USE DBESTATISTICA;

CREATE TABLE PESSOA (
	IDPESSOA INT NOT NULL PRIMARY KEY AUTO_INCREMENT
	, NOME VARCHAR(45)
	, SEXO CHAR(1)
);

CREATE TABLE ESTATISTICA (	
	HOMEM INT
	, MULHER INT
);


DELIMITER $$

-- 01, TRIGGER PARA O INSERT

CREATE TRIGGER TRIG_PESSOA_AI AFTER INSERT ON PESSOA FOR EACH ROW
BEGIN

	IF NEW.SEXO = 'M' THEN
		UPDATE ESTATISTICA SET HOMEM = HOMEM + 1;
	ELSEIF NEW.SEXO = 'F' THEN
		UPDATE ESTATISTICA SET MULHER = MULHER + 1;
	END IF;
    
END $$



-- 02, TRIGGER PARA O DELETE

CREATE TRIGGER TRI_PESSOA_AD AFTER DELETE ON PESSOA FOR EACH ROW
BEGIN

	IF OLD.SEXO = 'M' THEN
		UPDATE ESTATISTICA SET HOMEM = HOMEM - 1;
	ELSEIF OLD.SEXO = 'F' THEN
		UPDATE ESTATISTICA SET MULHER = MULHER - 1;
	END IF;
		
END $$



-- 03, TRIGGER PARA UPDATE

CREATE TRIGGER TRI_PESSOA_AU AFTER UPDATE ON PESSOA FOR EACH ROW
BEGIN
	
    -- INFORMAÇÃO ANTIGA
	IF OLD.SEXO = 'M' THEN
		UPDATE ESTATISTICA SET HOMEM = HOMEM - 1;
	ELSEIF OLD.SEXO = 'F' THEN
		UPDATE ESTATISTICA SET MULHER = MULHER -1;
	END IF;
    
    -- INFORMAÇÃO NOVA
	IF NEW.SEXO = 'M' THEN
		UPDATE ESTATISTICA SET HOMEM = HOMEM + 1;
    ELSEIF NEW.SEXO = 'F' THEN
		UPDATE ESTATISTICA SET MULHER = MULHER + 1;
	END IF;
    
END $$



-- 04, TRIGGER PARA VALIDAÇÃO

CREATE TRIGGER TRI_PESSOA_BI BEFORE INSERT ON PESSOA FOR EACH ROW
BEGIN

	IF NEW.SEXO <> 'M' AND NEW.SEXO <> 'F' AND NEW.SEXO IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR: SEXO INDEFINIDO';
    END IF;

END $$


CREATE TRIGGER TRI_PESSOA_BU BEFORE UPDATE ON PESSOA FOR EACH ROW
BEGIN

	IF (NEW.SEXO <> 'M' AND NEW.SEXO <> 'F') OR (NEW.SEXO IS NULL) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O valor para o campo sexo é inválido';
    END IF;

END $$

DELIMITER ; 

INSERT INTO ESTATISTICA (HOMEM, MULHER)VALUES(0,0);

SELECT * FROM PESSOA;
SELECT * FROM ESTATISTICA;

INSERT INTO PESSOA(NOME, SEXO)VALUES('JOAO', 'M');
INSERT INTO PESSOA(NOME, SEXO)VALUES('JERONIMO', 'F');
INSERT INTO PESSOA(NOME, SEXO)VALUES('FERNANDA', 'F');

UPDATE PESSOA SET SEXO = 'M' WHERE NOME = 'JERONIMO';


SHOW TRIGGERS;
SHOW ERRORS;




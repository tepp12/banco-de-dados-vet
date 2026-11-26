SET NAMES utf8mb4;
SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
SET SESSION cte_max_recursion_depth = 200000;

DROP DATABASE IF EXISTS clinica_legado;
DROP DATABASE IF EXISTS clinica_protegida;

CREATE DATABASE clinica_legado CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE clinica_legado;

CREATE TABLE responsavel (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  nome      VARCHAR(100),
  cpf       VARCHAR(20),
  telefone  VARCHAR(20),
  email     VARCHAR(120),
  endereco  VARCHAR(200)
) ENGINE=InnoDB;

CREATE TABLE animal (
  id               INT AUTO_INCREMENT PRIMARY KEY,
  nome             VARCHAR(60),
  especie          VARCHAR(30),
  raca             VARCHAR(40),
  sexo             VARCHAR(5),
  data_nascimento  DATE,
  peso             DECIMAL(7,2),
  responsavel_id   INT
) ENGINE=InnoDB;

CREATE TABLE atendimento (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  animal_id         INT,
  veterinario       VARCHAR(100),
  data_atendimento  DATETIME,
  queixa            TEXT,
  diagnostico       TEXT,
  conduta           TEXT
) ENGINE=InnoDB;

INSERT INTO responsavel (id, nome, cpf, telefone, email, endereco)
WITH RECURSIVE n (i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 80)
SELECT i,
  CASE i WHEN 77 THEN '   ' WHEN 78 THEN NULL
    ELSE CONCAT(ELT(1 + i % 8, 'Maria','João','Ana','Pedro','Luciana','Carlos','Fernanda','Rafael'),
                ' ', ELT(1 + i % 7, 'Silva','Santos','Oliveira','Souza','Lima','Costa','Pereira'),
                ' ', i) END,
  CASE WHEN i IN (43, 63) THEN LPAD(10000000000 + (i - 1) * 123457, 11, '0')
       WHEN i = 55 THEN '123'
       ELSE LPAD(10000000000 + i * 123457, 11, '0') END,
  CASE WHEN i % 10 = 0 THEN NULL
       ELSE CONCAT('799', LPAD((i * 13579) % 100000000, 8, '0')) END,
  CASE WHEN i % 6 = 0 THEN NULL
       WHEN i = 33 THEN 'email-invalido'
       ELSE CONCAT('resp', i, '@exemplo.com') END,
  CONCAT('Rua ', i, ', Aracaju-SE')
FROM n;
   Defeitos injetados:
     sem responsável (NULL) ... ids 13,47,88
     responsável inexistente .. id 95 (responsavel_id = 999)
     nome NULL / em branco .... ids 30 / 64
     nascimento NULL / futuro . ids 9,58,83 / 22,71
     peso NULL / <=0 / absurdo  ids 5,44 / 15,66 / 90
     sexo NULL ................ id 70                                    */
INSERT INTO animal (id, nome, especie, raca, sexo, data_nascimento, peso, responsavel_id)
WITH RECURSIVE n (i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 100)
SELECT i,
  CASE i WHEN 30 THEN NULL WHEN 64 THEN '  '
    ELSE ELT(1 + i % 10, 'Rex','Mel','Thor','Luna','Bolt','Nina','Simba','Mimi','Fred','Pandora') END,
  ELT(1 + i % 4, 'Cão','Gato','Ave','Coelho'),
  CASE i % 4
    WHEN 0 THEN ELT(1 + (i DIV 4) % 3, 'Labrador','Poodle','SRD')
    WHEN 1 THEN ELT(1 + (i DIV 4) % 3, 'Siamês','Persa','SRD')
    WHEN 2 THEN ELT(1 + (i DIV 4) % 2, 'Calopsita','Periquito')
    ELSE        ELT(1 + (i DIV 4) % 2, 'Mini Lop','SRD') END,
  CASE WHEN i = 70 THEN NULL ELSE ELT(1 + i % 2, 'M','F') END,
  CASE WHEN i IN (9, 58, 83) THEN NULL
       WHEN i IN (22, 71) THEN DATE_ADD(CURDATE(), INTERVAL 30 DAY)
       ELSE DATE_SUB(CURDATE(), INTERVAL (70 + (i * 37) % 3500) DAY) END,
  CASE WHEN i IN (5, 44) THEN NULL
       WHEN i = 15 THEN -3.5
       WHEN i = 66 THEN 0
       WHEN i = 90 THEN 850
       ELSE ROUND(1 + ((i * 37) % 400) / 10, 2) END,
  CASE WHEN i IN (13, 47, 88) THEN NULL
       WHEN i = 95 THEN 999
       ELSE 1 + (i - 1) % 80 END
FROM n;

INSERT INTO atendimento (id, animal_id, veterinario, data_atendimento, queixa, diagnostico, conduta)
WITH RECURSIVE n (i) AS (SELECT 1 UNION ALL SELECT i + 1 FROM n WHERE i < 120)
SELECT i,
  CASE WHEN i = 7 THEN NULL WHEN i = 110 THEN 500 ELSE 1 + (i - 1) % 100 END,
  CASE WHEN i IN (33, 66, 99) THEN NULL
       WHEN i = 45 THEN 'Dr. Inexistente'
       ELSE ELT(1 + i % 4, 'Dra. Ana Souza','Dr. Carlos Lima','Dra. Beatriz Rocha','Dr. Paulo Mendes') END,
  CASE WHEN i = 88 THEN NULL
       WHEN i = 19 THEN DATE_ADD(NOW(), INTERVAL 5 DAY)
       WHEN i = 101 THEN '2000-01-01 09:00:00'
       ELSE DATE_SUB(NOW(), INTERVAL (i % 60 + 1) DAY) END,
  CASE WHEN i = 12 THEN NULL WHEN i = 60 THEN ''
       ELSE ELT(1 + i % 5, 'Vômito','Apatia','Febre','Claudicação','Coceira') END,
  CASE WHEN i % 7 = 0 THEN NULL WHEN i % 13 = 0 THEN ''
       ELSE ELT(1 + i % 5, 'Gastrite','Infecção viral','Otite','Dermatite','Fratura') END,
  CASE WHEN i % 9 = 0 THEN NULL
       ELSE ELT(1 + i % 4, 'Repouso e hidratação','Medicação oral','Retorno em 7 dias','Curativo e observação') END
FROM n;

SELECT 'responsavel' AS tabela, COUNT(*) AS linhas FROM responsavel
UNION ALL SELECT 'animal', COUNT(*) FROM animal
UNION ALL SELECT 'atendimento', COUNT(*) FROM atendimento;

CREATE VIEW vw_atendimentos_incompletos AS
SELECT * FROM (
  SELECT id, animal_id,
    CONCAT_WS(', ',
      IF(animal_id IS NULL, 'animal_id', NULL),
      IF(veterinario IS NULL OR TRIM(veterinario) = '', 'veterinario', NULL),
      IF(data_atendimento IS NULL, 'data_atendimento', NULL),
      IF(queixa IS NULL OR TRIM(queixa) = '', 'queixa', NULL),
      IF(diagnostico IS NULL OR TRIM(diagnostico) = '', 'diagnostico', NULL),
      IF(conduta IS NULL OR TRIM(conduta) = '', 'conduta', NULL)
    ) AS campos_faltando
  FROM atendimento
) t
WHERE campos_faltando <> '';

CREATE VIEW vw_completude AS
SELECT 'responsavel.nome' AS coluna, COUNT(*) AS total,
       SUM(nome IS NOT NULL AND TRIM(nome) <> '') AS preenchidos,
       ROUND(100 * SUM(nome IS NOT NULL AND TRIM(nome) <> '') / COUNT(*), 1) AS pct_completo
FROM responsavel
UNION ALL SELECT 'responsavel.cpf', COUNT(*), SUM(cpf IS NOT NULL AND TRIM(cpf) <> ''),
       ROUND(100 * SUM(cpf IS NOT NULL AND TRIM(cpf) <> '') / COUNT(*), 1) FROM responsavel
UNION ALL SELECT 'responsavel.telefone', COUNT(*), SUM(telefone IS NOT NULL AND TRIM(telefone) <> ''),
       ROUND(100 * SUM(telefone IS NOT NULL AND TRIM(telefone) <> '') / COUNT(*), 1) FROM responsavel
UNION ALL SELECT 'animal.nome', COUNT(*), SUM(nome IS NOT NULL AND TRIM(nome) <> ''),
       ROUND(100 * SUM(nome IS NOT NULL AND TRIM(nome) <> '') / COUNT(*), 1) FROM animal
UNION ALL SELECT 'animal.data_nascimento', COUNT(*), COUNT(data_nascimento),
       ROUND(100 * COUNT(data_nascimento) / COUNT(*), 1) FROM animal
UNION ALL SELECT 'animal.peso', COUNT(*), COUNT(peso),
       ROUND(100 * COUNT(peso) / COUNT(*), 1) FROM animal
UNION ALL SELECT 'animal.responsavel_id', COUNT(*), COUNT(responsavel_id),
       ROUND(100 * COUNT(responsavel_id) / COUNT(*), 1) FROM animal
UNION ALL SELECT 'atendimento.animal_id', COUNT(*), COUNT(animal_id),
       ROUND(100 * COUNT(animal_id) / COUNT(*), 1) FROM atendimento
UNION ALL SELECT 'atendimento.veterinario', COUNT(*), SUM(veterinario IS NOT NULL AND TRIM(veterinario) <> ''),
       ROUND(100 * SUM(veterinario IS NOT NULL AND TRIM(veterinario) <> '') / COUNT(*), 1) FROM atendimento
UNION ALL SELECT 'atendimento.queixa', COUNT(*), SUM(queixa IS NOT NULL AND TRIM(queixa) <> ''),
       ROUND(100 * SUM(queixa IS NOT NULL AND TRIM(queixa) <> '') / COUNT(*), 1) FROM atendimento
UNION ALL SELECT 'atendimento.diagnostico', COUNT(*), SUM(diagnostico IS NOT NULL AND TRIM(diagnostico) <> ''),
       ROUND(100 * SUM(diagnostico IS NOT NULL AND TRIM(diagnostico) <> '') / COUNT(*), 1) FROM atendimento
UNION ALL SELECT 'atendimento.conduta', COUNT(*), SUM(conduta IS NOT NULL AND TRIM(conduta) <> ''),
       ROUND(100 * SUM(conduta IS NOT NULL AND TRIM(conduta) <> '') / COUNT(*), 1) FROM atendimento;

SELECT * FROM vw_completude;
SELECT COUNT(*) AS atendimentos_incompletos FROM vw_atendimentos_incompletos;
SELECT * FROM vw_atendimentos_incompletos ORDER BY id LIMIT 15;

SELECT 'CPF duplicado' AS problema, COUNT(*) AS responsaveis_afetados
FROM responsavel WHERE cpf IN (SELECT cpf FROM responsavel GROUP BY cpf HAVING COUNT(*) > 1)
UNION ALL
SELECT 'Animal sem responsável', COUNT(*) FROM animal WHERE responsavel_id IS NULL
UNION ALL
SELECT 'Animal com responsável inexistente', COUNT(*) FROM animal a
  LEFT JOIN responsavel r ON r.id = a.responsavel_id
  WHERE a.responsavel_id IS NOT NULL AND r.id IS NULL
UNION ALL
SELECT 'Atendimento com animal inexistente', COUNT(*) FROM atendimento t
  LEFT JOIN animal a ON a.id = t.animal_id
  WHERE t.animal_id IS NOT NULL AND a.id IS NULL
UNION ALL
SELECT 'Peso inválido (<=0 ou >200)', COUNT(*) FROM animal WHERE peso <= 0 OR peso > 200
UNION ALL
SELECT 'Nascimento no futuro', COUNT(*) FROM animal WHERE data_nascimento > CURDATE()
UNION ALL
SELECT 'Atendimento no futuro', COUNT(*) FROM atendimento WHERE data_atendimento > NOW();

CREATE DATABASE clinica_protegida CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE clinica_protegida;

CREATE TABLE especie (
  id    TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome  VARCHAR(30) NOT NULL,
  CONSTRAINT uq_especie_nome  UNIQUE (nome),
  CONSTRAINT chk_especie_nome CHECK (TRIM(nome) <> '')
) ENGINE=InnoDB;

CREATE TABLE raca (
  id          SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome        VARCHAR(40) NOT NULL,
  especie_id  TINYINT UNSIGNED NOT NULL,
  CONSTRAINT uq_raca_nome_especie UNIQUE (especie_id, nome),
  CONSTRAINT uq_raca_id_especie   UNIQUE (id, especie_id),   
  CONSTRAINT chk_raca_nome        CHECK (TRIM(nome) <> ''),
  CONSTRAINT fk_raca_especie      FOREIGN KEY (especie_id) REFERENCES especie (id)
) ENGINE=InnoDB;

CREATE TABLE responsavel (
  id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome       VARCHAR(100) NOT NULL,
  cpf        CHAR(11) NOT NULL,
  telefone   VARCHAR(11) NOT NULL,
  email      VARCHAR(120) NULL,
  endereco   VARCHAR(200) NULL,
  ativo      BOOLEAN NOT NULL DEFAULT TRUE,                  
  criado_em  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_resp_cpf    UNIQUE (cpf),
  CONSTRAINT chk_resp_nome  CHECK (CHAR_LENGTH(TRIM(nome)) >= 3),
  CONSTRAINT chk_resp_cpf   CHECK (cpf REGEXP '^[0-9]{11}$'),
  CONSTRAINT chk_resp_tel   CHECK (telefone REGEXP '^[0-9]{10,11}$'),
  CONSTRAINT chk_resp_email CHECK (email IS NULL OR email REGEXP '^[^@ ]+@[^@ ]+[.][^@ ]+$')
) ENGINE=InnoDB;

CREATE TABLE veterinario (
  id    TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome  VARCHAR(100) NOT NULL,
  crmv  VARCHAR(10) NOT NULL,
  ativo BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT uq_vet_crmv  UNIQUE (crmv),
  CONSTRAINT chk_vet_nome CHECK (CHAR_LENGTH(TRIM(nome)) >= 3),
  CONSTRAINT chk_vet_crmv CHECK (crmv REGEXP '^[A-Z]{2}-[0-9]{3,6}$')
) ENGINE=InnoDB;

CREATE TABLE animal (
  id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome             VARCHAR(60) NOT NULL,
  especie_id       TINYINT UNSIGNED NOT NULL,
  raca_id          SMALLINT UNSIGNED NULL,
  sexo             CHAR(1) NOT NULL,
  data_nascimento  DATE NOT NULL,
  peso_kg          DECIMAL(5,2) NOT NULL,
  responsavel_id   INT UNSIGNED NOT NULL,
  ativo            BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT chk_animal_nome  CHECK (TRIM(nome) <> ''),
  CONSTRAINT chk_animal_sexo  CHECK (sexo IN ('M','F')),
  CONSTRAINT chk_animal_peso  CHECK (peso_kg > 0 AND peso_kg <= 200),
  CONSTRAINT fk_animal_resp    FOREIGN KEY (responsavel_id) REFERENCES responsavel (id),
  CONSTRAINT fk_animal_especie FOREIGN KEY (especie_id)     REFERENCES especie (id),
  CONSTRAINT fk_animal_raca    FOREIGN KEY (raca_id, especie_id) REFERENCES raca (id, especie_id)
) ENGINE=InnoDB;

CREATE TABLE atendimento (
  id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  animal_id         INT UNSIGNED NOT NULL,
  veterinario_id    TINYINT UNSIGNED NOT NULL,
  data_atendimento  DATETIME NOT NULL,
  queixa            TEXT NOT NULL,
  diagnostico       TEXT NULL,
  conduta           TEXT NULL,
  status            ENUM('rascunho','finalizado') NOT NULL DEFAULT 'rascunho',
  INDEX idx_atend_animal_data (animal_id, data_atendimento),
  CONSTRAINT chk_atend_queixa CHECK (TRIM(queixa) <> ''),
  CONSTRAINT chk_atend_finalizado CHECK (
    status = 'rascunho'
    OR (diagnostico IS NOT NULL AND TRIM(diagnostico) <> ''
        AND conduta IS NOT NULL AND TRIM(conduta) <> '')
  ),
  CONSTRAINT fk_atend_animal FOREIGN KEY (animal_id)      REFERENCES animal (id),
  CONSTRAINT fk_atend_vet    FOREIGN KEY (veterinario_id) REFERENCES veterinario (id)
) ENGINE=InnoDB;

CREATE TABLE medicamento (
  id    SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome  VARCHAR(80) NOT NULL,
  CONSTRAINT uq_medicamento_nome  UNIQUE (nome),
  CONSTRAINT chk_medicamento_nome CHECK (TRIM(nome) <> '')
) ENGINE=InnoDB;

CREATE TABLE prescricao (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  atendimento_id  INT UNSIGNED NOT NULL,
  medicamento_id  SMALLINT UNSIGNED NOT NULL,
  dose            VARCHAR(60) NOT NULL,
  frequencia      VARCHAR(60) NOT NULL,
  duracao_dias    SMALLINT UNSIGNED NOT NULL,
  CONSTRAINT uq_prescricao      UNIQUE (atendimento_id, medicamento_id),
  CONSTRAINT chk_presc_dose     CHECK (TRIM(dose) <> ''),
  CONSTRAINT chk_presc_freq     CHECK (TRIM(frequencia) <> ''),
  CONSTRAINT chk_presc_duracao  CHECK (duracao_dias BETWEEN 1 AND 365),
  CONSTRAINT fk_presc_atend     FOREIGN KEY (atendimento_id) REFERENCES atendimento (id),
  CONSTRAINT fk_presc_medic     FOREIGN KEY (medicamento_id) REFERENCES medicamento (id)
) ENGINE=InnoDB;

CREATE TABLE log_auditoria (
  id               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tabela           VARCHAR(40) NOT NULL,
  operacao         ENUM('UPDATE','DELETE') NOT NULL,
  registro_id      INT UNSIGNED NOT NULL,
  usuario          VARCHAR(100) NOT NULL,
  data_hora        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  valores_antigos  JSON NULL,
  valores_novos    JSON NULL
) ENGINE=InnoDB;

CREATE TABLE migracao_rejeitados (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  tabela      VARCHAR(40) NOT NULL,
  id_legado   INT NOT NULL,
  errno       INT NOT NULL,
  motivo      VARCHAR(400) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE resultado_testes (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  grupo      VARCHAR(40) NOT NULL,
  descricao  VARCHAR(200) NOT NULL,
  esperado   ENUM('ACEITAR','REJEITAR') NOT NULL,
  resultado  ENUM('ACEITO','REJEITADO') NOT NULL,
  errno      INT NULL,
  motivo     VARCHAR(400) NULL,
  passou     ENUM('OK','FALHOU') NOT NULL
) ENGINE=InnoDB;

INSERT INTO especie (nome) VALUES ('Cão'),('Gato'),('Ave'),('Coelho'),('Réptil');

INSERT INTO raca (nome, especie_id)
SELECT r.n, e.id
FROM (SELECT 'Labrador' AS n, 'Cão' AS esp   UNION ALL SELECT 'Poodle','Cão'
      UNION ALL SELECT 'SRD','Cão'           UNION ALL SELECT 'Siamês','Gato'
      UNION ALL SELECT 'Persa','Gato'        UNION ALL SELECT 'SRD','Gato'
      UNION ALL SELECT 'Calopsita','Ave'     UNION ALL SELECT 'Periquito','Ave'
      UNION ALL SELECT 'Mini Lop','Coelho'   UNION ALL SELECT 'SRD','Coelho') r
JOIN especie e ON e.nome = r.esp;

INSERT INTO veterinario (nome, crmv) VALUES
  ('Dra. Ana Souza','SE-1001'), ('Dr. Carlos Lima','SE-1002'),
  ('Dra. Beatriz Rocha','SE-1003'), ('Dr. Paulo Mendes','SE-1004');

INSERT INTO medicamento (nome) VALUES ('Amoxicilina'),('Dipirona'),('Meloxicam'),('Prednisolona');

DELIMITER $$

CREATE FUNCTION f_motivo(p_errno INT, p_msg TEXT)
RETURNS VARCHAR(400) DETERMINISTIC NO SQL
BEGIN
  RETURN LEFT(CASE
    WHEN p_errno IN (1048, 1364) THEN CONCAT('NOT NULL: ', p_msg)
    WHEN p_errno = 1062          THEN CONCAT('UNIQUE: ', SUBSTRING_INDEX(p_msg, ' for key ', -1))
    WHEN p_errno IN (1451, 1452) THEN CONCAT('FOREIGN KEY: ',
                                        SUBSTRING_INDEX(SUBSTRING_INDEX(p_msg, 'CONSTRAINT `', -1), '`', 1))
    WHEN p_errno = 3819          THEN CONCAT('CHECK: ', p_msg)
    WHEN p_errno = 1265          THEN CONCAT('TIPO/ENUM: ', p_msg)
    WHEN p_errno = 1644          THEN CONCAT('TRIGGER: ', p_msg)
    ELSE CONCAT('OUTRO (', p_errno, '): ', p_msg)
  END, 400);
END$$

CREATE TRIGGER trg_animal_bi BEFORE INSERT ON animal FOR EACH ROW
BEGIN
  IF NEW.data_nascimento > CURDATE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data de nascimento não pode ser futura';
  END IF;
END$$

CREATE TRIGGER trg_animal_bu BEFORE UPDATE ON animal FOR EACH ROW
BEGIN
  IF NEW.data_nascimento > CURDATE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data de nascimento não pode ser futura';
  END IF;
END$$

CREATE TRIGGER trg_atend_bi BEFORE INSERT ON atendimento FOR EACH ROW
BEGIN
  DECLARE v_nasc DATE;
  IF NEW.data_atendimento > NOW() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data do atendimento não pode ser futura';
  END IF;
  SELECT data_nascimento INTO v_nasc FROM animal WHERE id = NEW.animal_id;
  IF v_nasc IS NOT NULL AND DATE(NEW.data_atendimento) < v_nasc THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Atendimento anterior ao nascimento do animal';
  END IF;
END$$

CREATE TRIGGER trg_atend_bu BEFORE UPDATE ON atendimento FOR EACH ROW
BEGIN
  DECLARE v_nasc DATE;
  IF OLD.status = 'finalizado' AND NEW.status = 'rascunho' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Atendimento finalizado não pode voltar a rascunho';
  END IF;
  IF NEW.data_atendimento > NOW() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data do atendimento não pode ser futura';
  END IF;
  SELECT data_nascimento INTO v_nasc FROM animal WHERE id = NEW.animal_id;
  IF v_nasc IS NOT NULL AND DATE(NEW.data_atendimento) < v_nasc THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Atendimento anterior ao nascimento do animal';
  END IF;
END$$

CREATE TRIGGER trg_atend_au AFTER UPDATE ON atendimento FOR EACH ROW
BEGIN
  INSERT INTO log_auditoria (tabela, operacao, registro_id, usuario, valores_antigos, valores_novos)
  VALUES ('atendimento', 'UPDATE', OLD.id, CURRENT_USER(),
          JSON_OBJECT('status', OLD.status, 'diagnostico', OLD.diagnostico, 'conduta', OLD.conduta),
          JSON_OBJECT('status', NEW.status, 'diagnostico', NEW.diagnostico, 'conduta', NEW.conduta));
END$$

CREATE TRIGGER trg_atend_ad AFTER DELETE ON atendimento FOR EACH ROW
BEGIN
  INSERT INTO log_auditoria (tabela, operacao, registro_id, usuario, valores_antigos)
  VALUES ('atendimento', 'DELETE', OLD.id, CURRENT_USER(),
          JSON_OBJECT('animal_id', OLD.animal_id, 'status', OLD.status,
                      'diagnostico', OLD.diagnostico, 'conduta', OLD.conduta));
END$$

CREATE PROCEDURE sp_cadastrar_responsavel_animal(
  IN  p_resp_nome   VARCHAR(100),
  IN  p_cpf         CHAR(11),
  IN  p_telefone    VARCHAR(11),
  IN  p_animal_nome VARCHAR(60),
  IN  p_especie     VARCHAR(30),
  IN  p_sexo        CHAR(1),
  IN  p_nascimento  DATE,
  IN  p_peso        DECIMAL(5,2),
  OUT p_responsavel_id INT UNSIGNED)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
  INSERT INTO responsavel (nome, cpf, telefone) VALUES (p_resp_nome, p_cpf, p_telefone);
  SET p_responsavel_id = LAST_INSERT_ID();
  INSERT INTO animal (nome, especie_id, raca_id, sexo, data_nascimento, peso_kg, responsavel_id)
  VALUES (p_animal_nome, (SELECT id FROM especie WHERE nome = p_especie), NULL,
          p_sexo, p_nascimento, p_peso, p_responsavel_id);
  COMMIT;
END$$

CREATE PROCEDURE sp_registrar_rejeicao(IN p_tabela VARCHAR(40), IN p_id INT, IN p_errno INT, IN p_msg TEXT)
BEGIN
  INSERT INTO migracao_rejeitados (tabela, id_legado, errno, motivo)
  VALUES (p_tabela, p_id, p_errno, f_motivo(p_errno, p_msg));
END$$

CREATE PROCEDURE sp_migrar_legado()
BEGIN
  DECLARE fim    INT DEFAULT 0;
  DECLARE erro   INT DEFAULT 0;
  DECLARE v_errno INT DEFAULT 0;
  DECLARE v_msg  TEXT DEFAULT '';

  DECLARE r_id INT;            DECLARE r_nome VARCHAR(100); DECLARE r_cpf VARCHAR(20);
  DECLARE r_tel VARCHAR(20);   DECLARE r_email VARCHAR(120); DECLARE r_end VARCHAR(200);

  DECLARE a_id INT;            DECLARE a_nome VARCHAR(60);  DECLARE a_esp VARCHAR(30);
  DECLARE a_raca VARCHAR(40);  DECLARE a_sexo VARCHAR(5);   DECLARE a_nasc DATE;
  DECLARE a_peso DECIMAL(7,2); DECLARE a_resp INT;

  DECLARE t_id INT;            DECLARE t_animal INT;        DECLARE t_vet VARCHAR(100);
  DECLARE t_data DATETIME;     DECLARE t_queixa TEXT;       DECLARE t_diag TEXT;
  DECLARE t_cond TEXT;

  DECLARE c_resp CURSOR FOR
    SELECT id, nome, cpf, telefone, email, endereco FROM clinica_legado.responsavel ORDER BY id;
  DECLARE c_animal CURSOR FOR
    SELECT id, nome, especie, raca, sexo, data_nascimento, peso, responsavel_id
    FROM clinica_legado.animal ORDER BY id;
  DECLARE c_atend CURSOR FOR
    SELECT id, animal_id, veterinario, data_atendimento, queixa, diagnostico, conduta
    FROM clinica_legado.atendimento ORDER BY id;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET fim = 1;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLSTATE '01000'
  BEGIN
    GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
    SET erro = 1;
  END;

  DELETE FROM migracao_rejeitados;

  OPEN c_resp;
  loop_resp: LOOP
    FETCH c_resp INTO r_id, r_nome, r_cpf, r_tel, r_email, r_end;
    IF fim = 1 THEN LEAVE loop_resp; END IF;
    SET erro = 0;
    INSERT INTO responsavel (id, nome, cpf, telefone, email, endereco)
    VALUES (r_id, r_nome, r_cpf, r_tel, r_email, r_end);
    IF erro = 1 THEN CALL sp_registrar_rejeicao('responsavel', r_id, v_errno, v_msg); END IF;
  END LOOP;
  CLOSE c_resp;
  SET fim = 0;

  OPEN c_animal;
  loop_animal: LOOP
    FETCH c_animal INTO a_id, a_nome, a_esp, a_raca, a_sexo, a_nasc, a_peso, a_resp;
    IF fim = 1 THEN LEAVE loop_animal; END IF;
    SET erro = 0;
    INSERT INTO animal (id, nome, especie_id, raca_id, sexo, data_nascimento, peso_kg, responsavel_id)
    VALUES (a_id, a_nome,
            (SELECT id FROM especie WHERE nome = a_esp),
            (SELECT r.id FROM raca r JOIN especie e ON e.id = r.especie_id
              WHERE r.nome = a_raca AND e.nome = a_esp),
            a_sexo, a_nasc, a_peso, a_resp);
    IF erro = 1 THEN CALL sp_registrar_rejeicao('animal', a_id, v_errno, v_msg); END IF;
  END LOOP;
  CLOSE c_animal;
  SET fim = 0;
  OPEN c_atend;
  loop_atend: LOOP
    FETCH c_atend INTO t_id, t_animal, t_vet, t_data, t_queixa, t_diag, t_cond;
    IF fim = 1 THEN LEAVE loop_atend; END IF;
    SET erro = 0;
    INSERT INTO atendimento (id, animal_id, veterinario_id, data_atendimento, queixa, diagnostico, conduta, status)
    VALUES (t_id, t_animal,
            (SELECT id FROM veterinario WHERE nome = t_vet),
            t_data, t_queixa, t_diag, t_cond, 'finalizado');
    IF erro = 1 THEN CALL sp_registrar_rejeicao('atendimento', t_id, v_errno, v_msg); END IF;
  END LOOP;
  CLOSE c_atend;
END$$

CREATE PROCEDURE sp_teste(
  IN p_grupo    VARCHAR(40),
  IN p_desc     VARCHAR(200),
  IN p_sql      TEXT,
  IN p_esperado ENUM('ACEITAR','REJEITAR'))
BEGIN
  DECLARE v_erro  TINYINT DEFAULT 0;
  DECLARE v_errno INT DEFAULT NULL;
  DECLARE v_msg   TEXT DEFAULT NULL;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION, SQLSTATE '01000'
  BEGIN
    GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
    SET v_erro = 1;
  END;

  SET @sql_teste = p_sql;
  PREPARE st FROM @sql_teste;
  IF v_erro = 0 THEN
    EXECUTE st;
    DEALLOCATE PREPARE st;
  END IF;

  INSERT INTO resultado_testes (grupo, descricao, esperado, resultado, errno, motivo, passou)
  VALUES (p_grupo, p_desc, p_esperado,
          IF(v_erro = 1, 'REJEITADO', 'ACEITO'),
          v_errno,
          IF(v_erro = 1, f_motivo(v_errno, v_msg), NULL),
          IF((p_esperado = 'REJEITAR') = (v_erro = 1), 'OK', 'FALHOU'));
END$$

DELIMITER ;

CALL sp_migrar_legado();

SELECT t.tabela,
       t.total                                   AS registros_legado,
       COALESCE(r.rej, 0)                        AS rejeitados,
       t.total - COALESCE(r.rej, 0)              AS aceitos,
       ROUND(100 * COALESCE(r.rej, 0) / t.total, 1) AS pct_rejeitado
FROM (SELECT 'responsavel' AS tabela, COUNT(*) AS total FROM clinica_legado.responsavel
      UNION ALL SELECT 'animal', COUNT(*) FROM clinica_legado.animal
      UNION ALL SELECT 'atendimento', COUNT(*) FROM clinica_legado.atendimento) t
LEFT JOIN (SELECT tabela, COUNT(*) AS rej FROM migracao_rejeitados GROUP BY tabela) r
       ON r.tabela = t.tabela;

SELECT tabela, motivo, COUNT(*) AS qtd
FROM migracao_rejeitados
GROUP BY tabela, motivo
ORDER BY tabela, qtd DESC;

SELECT 'animal sem responsável' AS verificacao, COUNT(*) AS qtd FROM animal a
  LEFT JOIN responsavel r ON r.id = a.responsavel_id WHERE r.id IS NULL
UNION ALL
SELECT 'atendimento finalizado sem diagnóstico', COUNT(*) FROM atendimento
  WHERE status = 'finalizado' AND (diagnostico IS NULL OR TRIM(diagnostico) = '')
UNION ALL
SELECT 'responsável sem telefone', COUNT(*) FROM responsavel
  WHERE telefone IS NULL OR TRIM(telefone) = '';

USE clinica_protegida;
DELETE FROM resultado_testes;

CALL sp_teste('A. Controle positivo', 'Responsável válido',
  "INSERT INTO responsavel (nome, cpf, telefone, email) VALUES ('Controle Teste','99999999901','79988887777','controle@exemplo.com')", 'ACEITAR');
CALL sp_teste('A. Controle positivo', 'Animal válido (Cão, sem raça)',
  "INSERT INTO animal (nome, especie_id, raca_id, sexo, data_nascimento, peso_kg, responsavel_id) VALUES ('Controle Teste', (SELECT id FROM especie WHERE nome='Cão'), NULL, 'M', DATE_SUB(CURDATE(), INTERVAL 365 DAY), 12.5, (SELECT id FROM responsavel WHERE cpf='99999999901'))", 'ACEITAR');
CALL sp_teste('A. Controle positivo', 'Atendimento em rascunho, sem diagnóstico ainda',
  "INSERT INTO atendimento (animal_id, veterinario_id, data_atendimento, queixa, status) VALUES ((SELECT id FROM animal WHERE nome='Controle Teste'), (SELECT MIN(id) FROM veterinario), DATE_SUB(NOW(), INTERVAL 1 DAY), 'Apatia', 'rascunho')", 'ACEITAR');

CALL sp_teste('B. Responsável', 'Telefone NULL (NOT NULL)',
  "INSERT INTO responsavel (nome, cpf, telefone) VALUES ('Teste Sem Fone','99999999902',NULL)", 'REJEITAR');
CALL sp_teste('B. Responsável', 'Nome só com espaços (CHECK anti string vazia)',
  "INSERT INTO responsavel (nome, cpf, telefone) VALUES ('   ','99999999902','79988887777')", 'REJEITAR');
CALL sp_teste('B. Responsável', 'CPF duplicado (UNIQUE)',
  "INSERT INTO responsavel (nome, cpf, telefone) VALUES ('Teste Duplicado','99999999901','79988887777')", 'REJEITAR');
CALL sp_teste('B. Responsável', 'CPF com formato inválido (CHECK regex)',
  "INSERT INTO responsavel (nome, cpf, telefone) VALUES ('Teste CPF','ABC','79988887777')", 'REJEITAR');
CALL sp_teste('B. Responsável', 'Telefone com formato inválido (CHECK regex)',
  "INSERT INTO responsavel (nome, cpf, telefone) VALUES ('Teste Tel','99999999902','123')", 'REJEITAR');
CALL sp_teste('B. Responsável', 'E-mail sem arroba (CHECK regex)',
  "INSERT INTO responsavel (nome, cpf, telefone, email) VALUES ('Teste Email','99999999902','79988887777','semarroba')", 'REJEITAR');

CALL sp_teste('C. Animal', 'Sem responsável (NOT NULL)',
  "INSERT INTO animal (nome, especie_id, sexo, data_nascimento, peso_kg, responsavel_id) VALUES ('Orfao', 1, 'M', '2020-01-01', 5, NULL)", 'REJEITAR');
CALL sp_teste('C. Animal', 'Responsável inexistente (FOREIGN KEY)',
  "INSERT INTO animal (nome, especie_id, sexo, data_nascimento, peso_kg, responsavel_id) VALUES ('Orfao', 1, 'M', '2020-01-01', 5, 999999)", 'REJEITAR');
CALL sp_teste('C. Animal', 'Espécie inexistente (FOREIGN KEY)',
  "INSERT INTO animal (nome, especie_id, sexo, data_nascimento, peso_kg, responsavel_id) VALUES ('Teste', 99, 'M', '2020-01-01', 5, (SELECT id FROM responsavel WHERE cpf='99999999901'))", 'REJEITAR');
CALL sp_teste('C. Animal', 'Raça de outra espécie: cão com raça Siamês (FK composta)',
  "INSERT INTO animal (nome, especie_id, raca_id, sexo, data_nascimento, peso_kg, responsavel_id) VALUES ('Controle Raca', (SELECT id FROM especie WHERE nome='Cão'), (SELECT id FROM raca WHERE nome='Siamês'), 'M', '2020-01-01', 5, (SELECT id FROM responsavel WHERE cpf='99999999901'))", 'REJEITAR');
CALL sp_teste('C. Animal', 'Peso negativo (CHECK)',
  "INSERT INTO animal (nome, especie_id, sexo, data_nascimento, peso_kg, responsavel_id) VALUES ('Teste', 1, 'M', '2020-01-01', -3.5, (SELECT id FROM responsavel WHERE cpf='99999999901'))", 'REJEITAR');
CALL sp_teste('C. Animal', 'Peso absurdo de 500 kg (CHECK)',
  "INSERT INTO animal (nome, especie_id, sexo, data_nascimento, peso_kg, responsavel_id) VALUES ('Teste', 1, 'M', '2020-01-01', 500, (SELECT id FROM responsavel WHERE cpf='99999999901'))", 'REJEITAR');
CALL sp_teste('C. Animal', 'Sexo inválido (CHECK)',
  "INSERT INTO animal (nome, especie_id, sexo, data_nascimento, peso_kg, responsavel_id) VALUES ('Teste', 1, 'X', '2020-01-01', 5, (SELECT id FROM responsavel WHERE cpf='99999999901'))", 'REJEITAR');
CALL sp_teste('C. Animal', 'Data de nascimento futura (TRIGGER)',
  "INSERT INTO animal (nome, especie_id, sexo, data_nascimento, peso_kg, responsavel_id) VALUES ('Teste', 1, 'M', DATE_ADD(CURDATE(), INTERVAL 10 DAY), 5, (SELECT id FROM responsavel WHERE cpf='99999999901'))", 'REJEITAR');
CALL sp_teste('C. Animal', 'Data de nascimento NULL (NOT NULL)',
  "INSERT INTO animal (nome, especie_id, sexo, data_nascimento, peso_kg, responsavel_id) VALUES ('Teste', 1, 'M', NULL, 5, (SELECT id FROM responsavel WHERE cpf='99999999901'))", 'REJEITAR');

CALL sp_teste('D. Atendimento', 'Finalizar sem diagnóstico/conduta (CHECK)',
  "INSERT INTO atendimento (animal_id, veterinario_id, data_atendimento, queixa, status) VALUES ((SELECT id FROM animal WHERE nome='Controle Teste'), 1, DATE_SUB(NOW(), INTERVAL 1 DAY), 'Febre', 'finalizado')", 'REJEITAR');
CALL sp_teste('D. Atendimento', 'Finalizar com diagnóstico em branco (CHECK)',
  "INSERT INTO atendimento (animal_id, veterinario_id, data_atendimento, queixa, diagnostico, conduta, status) VALUES ((SELECT id FROM animal WHERE nome='Controle Teste'), 1, DATE_SUB(NOW(), INTERVAL 1 DAY), 'Febre', '   ', 'Repouso', 'finalizado')", 'REJEITAR');
CALL sp_teste('D. Atendimento', 'Queixa vazia (CHECK)',
  "INSERT INTO atendimento (animal_id, veterinario_id, data_atendimento, queixa) VALUES ((SELECT id FROM animal WHERE nome='Controle Teste'), 1, DATE_SUB(NOW(), INTERVAL 1 DAY), '')", 'REJEITAR');
CALL sp_teste('D. Atendimento', 'Data futura (TRIGGER)',
  "INSERT INTO atendimento (animal_id, veterinario_id, data_atendimento, queixa) VALUES ((SELECT id FROM animal WHERE nome='Controle Teste'), 1, DATE_ADD(NOW(), INTERVAL 5 DAY), 'Febre')", 'REJEITAR');
CALL sp_teste('D. Atendimento', 'Data anterior ao nascimento do animal (TRIGGER)',
  "INSERT INTO atendimento (animal_id, veterinario_id, data_atendimento, queixa) VALUES ((SELECT id FROM animal WHERE nome='Controle Teste'), 1, '2000-01-01 10:00:00', 'Febre')", 'REJEITAR');
CALL sp_teste('D. Atendimento', 'Animal inexistente (FOREIGN KEY)',
  "INSERT INTO atendimento (animal_id, veterinario_id, data_atendimento, queixa) VALUES (999999, 1, DATE_SUB(NOW(), INTERVAL 1 DAY), 'Febre')", 'REJEITAR');
CALL sp_teste('D. Atendimento', 'Veterinário NULL (NOT NULL)',
  "INSERT INTO atendimento (animal_id, veterinario_id, data_atendimento, queixa) VALUES ((SELECT id FROM animal WHERE nome='Controle Teste'), NULL, DATE_SUB(NOW(), INTERVAL 1 DAY), 'Febre')", 'REJEITAR');
CALL sp_teste('D. Atendimento', 'Status inválido (ENUM)',
  "INSERT INTO atendimento (animal_id, veterinario_id, data_atendimento, queixa, status) VALUES ((SELECT id FROM animal WHERE nome='Controle Teste'), 1, DATE_SUB(NOW(), INTERVAL 1 DAY), 'Febre', 'pendente')", 'REJEITAR');
CALL sp_teste('D. Atendimento', 'UPDATE: finalizar rascunho sem diagnóstico (CHECK)',
  "UPDATE atendimento SET status='finalizado' WHERE animal_id=(SELECT id FROM animal WHERE nome='Controle Teste')", 'REJEITAR');
CALL sp_teste('D. Atendimento', 'UPDATE: preencher diagnóstico e finalizar (válido)',
  "UPDATE atendimento SET diagnostico='Gastrite', conduta='Repouso e hidratação', status='finalizado' WHERE animal_id=(SELECT id FROM animal WHERE nome='Controle Teste')", 'ACEITAR');
CALL sp_teste('D. Atendimento', 'UPDATE: voltar finalizado para rascunho (TRIGGER)',
  "UPDATE atendimento SET status='rascunho' WHERE animal_id=(SELECT id FROM animal WHERE nome='Controle Teste')", 'REJEITAR');

CALL sp_teste('E. Prescrição', 'Sem dose (NOT NULL)',
  "INSERT INTO prescricao (atendimento_id, medicamento_id, dose, frequencia, duracao_dias) VALUES ((SELECT id FROM atendimento WHERE animal_id=(SELECT id FROM animal WHERE nome='Controle Teste')), 1, NULL, '8/8h', 5)", 'REJEITAR');
CALL sp_teste('E. Prescrição', 'Dose em branco (CHECK)',
  "INSERT INTO prescricao (atendimento_id, medicamento_id, dose, frequencia, duracao_dias) VALUES ((SELECT id FROM atendimento WHERE animal_id=(SELECT id FROM animal WHERE nome='Controle Teste')), 1, '  ', '8/8h', 5)", 'REJEITAR');
CALL sp_teste('E. Prescrição', 'Duração zero (CHECK)',
  "INSERT INTO prescricao (atendimento_id, medicamento_id, dose, frequencia, duracao_dias) VALUES ((SELECT id FROM atendimento WHERE animal_id=(SELECT id FROM animal WHERE nome='Controle Teste')), 1, '10 mg/kg', '8/8h', 0)", 'REJEITAR');
CALL sp_teste('E. Prescrição', 'Prescrição completa (válida)',
  "INSERT INTO prescricao (atendimento_id, medicamento_id, dose, frequencia, duracao_dias) VALUES ((SELECT id FROM atendimento WHERE animal_id=(SELECT id FROM animal WHERE nome='Controle Teste')), (SELECT id FROM medicamento WHERE nome='Amoxicilina'), '10 mg/kg', '8/8h', 7)", 'ACEITAR');
CALL sp_teste('E. Prescrição', 'Mesmo medicamento duas vezes no atendimento (UNIQUE)',
  "INSERT INTO prescricao (atendimento_id, medicamento_id, dose, frequencia, duracao_dias) VALUES ((SELECT id FROM atendimento WHERE animal_id=(SELECT id FROM animal WHERE nome='Controle Teste')), (SELECT id FROM medicamento WHERE nome='Amoxicilina'), '10 mg/kg', '8/8h', 7)", 'REJEITAR');

CALL sp_teste('F. Veterinário', 'CRMV com formato inválido (CHECK)',
  "INSERT INTO veterinario (nome, crmv) VALUES ('Dr. Teste Formato','XX1')", 'REJEITAR');
CALL sp_teste('F. Veterinário', 'CRMV duplicado (UNIQUE)',
  "INSERT INTO veterinario (nome, crmv) VALUES ('Dr. Teste Duplicado','SE-1001')", 'REJEITAR');

CALL sp_teste('G. Exclusão', 'Apagar responsavel que possui animais (RESTRICT)',
  "DELETE FROM responsavel WHERE cpf='99999999901'", 'REJEITAR');
CALL sp_teste('G. Exclusão', 'Apagar animal que possui atendimentos (RESTRICT)',
  "DELETE FROM animal WHERE nome='Controle Teste'", 'REJEITAR');
CALL sp_teste('G. Exclusão', 'Desativar responsável (soft delete)',
  "UPDATE responsavel SET ativo = FALSE WHERE cpf='99999999901'", 'ACEITAR');

CALL sp_teste('H. Transação', 'Responsável + animal válidos pela procedure',
  "CALL sp_cadastrar_responsavel_animal('Transacao Valida','99999999904','79977776666','Bidu','Cão','M', DATE_SUB(CURDATE(), INTERVAL 200 DAY), 8.0, @novo_id)", 'ACEITAR');
CALL sp_teste('H. Transação', 'Animal inválido (peso -1): procedure deve falhar',
  "CALL sp_cadastrar_responsavel_animal('Transacao Falha','99999999903','79977776666','Bidu','Cão','M', DATE_SUB(CURDATE(), INTERVAL 200 DAY), -1, @novo_id)", 'REJEITAR');
CALL sp_teste('H. Transação', 'ROLLBACK: o responsável da chamada falha nao ficou gravado',
  "SELECT 1 FROM responsavel WHERE cpf='99999999903' HAVING COUNT(*) = 0", 'ACEITAR');

SELECT id, grupo, descricao, esperado, resultado, motivo, passou
FROM resultado_testes ORDER BY id;

SELECT passou, COUNT(*) AS qtd FROM resultado_testes GROUP BY passou;

SELECT SUBSTRING_INDEX(motivo, ':', 1) AS tipo_protecao, COUNT(*) AS bloqueios
FROM resultado_testes WHERE resultado = 'REJEITADO'
GROUP BY tipo_protecao ORDER BY bloqueios DESC;

SELECT id, tabela, operacao, registro_id, valores_antigos, valores_novos FROM log_auditoria ORDER BY id;

DELETE FROM prescricao WHERE atendimento_id IN (
  SELECT id FROM atendimento WHERE animal_id IN (
    SELECT id FROM animal WHERE responsavel_id IN (SELECT id FROM responsavel WHERE cpf LIKE '999999999%')));
DELETE FROM atendimento WHERE animal_id IN (
  SELECT id FROM animal WHERE responsavel_id IN (SELECT id FROM responsavel WHERE cpf LIKE '999999999%'));
DELETE FROM animal WHERE responsavel_id IN (SELECT id FROM responsavel WHERE cpf LIKE '999999999%');
DELETE FROM responsavel WHERE cpf LIKE '999999999%';

CREATE VIEW vw_historico_animal AS
SELECT a.id AS animal_id, a.nome AS animal, e.nome AS especie,
       r.nome AS responsavel, r.telefone,
       t.data_atendimento, v.nome AS veterinario,
       t.queixa, t.diagnostico, t.conduta, t.status
FROM animal a
JOIN especie e      ON e.id = a.especie_id
JOIN responsavel r  ON r.id = a.responsavel_id
LEFT JOIN atendimento t ON t.animal_id = a.id
LEFT JOIN veterinario v ON v.id = t.veterinario_id;

CREATE VIEW vw_atendimentos_por_vet_mes AS
SELECT v.nome AS veterinario, DATE_FORMAT(t.data_atendimento, '%Y-%m') AS mes, COUNT(*) AS total
FROM atendimento t
JOIN veterinario v ON v.id = t.veterinario_id
GROUP BY v.nome, DATE_FORMAT(t.data_atendimento, '%Y-%m');

SELECT * FROM vw_historico_animal WHERE animal_id = 1;               
SELECT * FROM vw_atendimentos_por_vet_mes ORDER BY mes, veterinario;

SELECT a.id, a.nome FROM animal a
LEFT JOIN atendimento t ON t.animal_id = a.id
WHERE t.id IS NULL ORDER BY a.id LIMIT 10;

SELECT 'responsavel.telefone' AS coluna, COUNT(*) AS total,
       ROUND(100 * SUM(telefone IS NOT NULL AND TRIM(telefone) <> '') / COUNT(*), 1) AS pct_completo
FROM responsavel
UNION ALL
SELECT 'atendimento.diagnostico', COUNT(*),
       ROUND(100 * SUM(diagnostico IS NOT NULL AND TRIM(diagnostico) <> '') / COUNT(*), 1)
FROM atendimento WHERE status = 'finalizado';

SHOW INDEX FROM atendimento;

USE clinica_protegida;
DROP TABLE IF EXISTS bench_atendimento;
DROP TABLE IF EXISTS bench_animal;

CREATE TABLE bench_atendimento (
  id                INT UNSIGNED PRIMARY KEY,
  animal_id         INT UNSIGNED NOT NULL,
  veterinario_id    TINYINT UNSIGNED NOT NULL,
  data_atendimento  DATETIME NOT NULL,
  queixa            VARCHAR(40) NOT NULL
) ENGINE=InnoDB;

INSERT INTO bench_atendimento (id, animal_id, veterinario_id, data_atendimento, queixa)
WITH RECURSIVE s (n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM s WHERE n < 100000)
SELECT n, 1 + (n * 7919) % 5000, 1 + n % 4,
       DATE_SUB(NOW(), INTERVAL (n * 37) % 1440000 MINUTE),
       ELT(1 + n % 5, 'Vômito','Apatia','Febre','Claudicação','Coceira')
FROM s;

CREATE TABLE bench_animal (
  id    INT UNSIGNED PRIMARY KEY,
  nome  VARCHAR(60) NOT NULL
) ENGINE=InnoDB;

INSERT INTO bench_animal (id, nome)
WITH RECURSIVE s (n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM s WHERE n < 100000)
SELECT n, CONCAT(ELT(1 + n % 10, 'Rex','Mel','Thor','Luna','Bolt','Nina','Simba','Mimi','Fred','Pandora'), ' ', n)
FROM s;

ANALYZE TABLE bench_atendimento, bench_animal;

EXPLAIN SELECT id, data_atendimento, queixa FROM bench_atendimento
WHERE animal_id = 1234 ORDER BY data_atendimento DESC;
EXPLAIN ANALYZE SELECT id, data_atendimento, queixa FROM bench_atendimento
WHERE animal_id = 1234 ORDER BY data_atendimento DESC;

CREATE INDEX idx_bench_animal_data ON bench_atendimento (animal_id, data_atendimento);

EXPLAIN SELECT id, data_atendimento, queixa FROM bench_atendimento
WHERE animal_id = 1234 ORDER BY data_atendimento DESC;
EXPLAIN ANALYZE SELECT id, data_atendimento, queixa FROM bench_atendimento
WHERE animal_id = 1234 ORDER BY data_atendimento DESC;

CREATE INDEX idx_bench_animal_nome ON bench_animal (nome);

EXPLAIN SELECT id, nome FROM bench_animal WHERE nome LIKE 'Pandora 9999%';
EXPLAIN SELECT id, nome FROM bench_animal WHERE nome LIKE '%Pandora 9999';

EXPLAIN SELECT id, nome FROM responsavel WHERE cpf = '10000123457';

EXPLAIN SELECT * FROM atendimento WHERE animal_id = 1 ORDER BY data_atendimento DESC;

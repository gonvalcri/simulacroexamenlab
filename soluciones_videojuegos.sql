


##Soluciones 

##1
DROP TABLE IF EXISTS Valoraciones;

CREATE TABLE Valoraciones (
    valoracionId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    jugadorId INT NOT NULL,
    videojuegoId INT NOT NULL,
    puntuacion DECIMAL	 CHECK (puntuacion > 0 AND puntuacion <= 5),
    likes INT DEFAULT(0),
    opinion TEXT NOT NULL,
    veredicto ENUM('Imprescindible', 'Recomendado', 'Comprar en rebajas', 'No merece la pena'),
    fechaValoracion DATE DEFAULT(CURDATE()),
    FOREIGN KEY(jugadorId) REFERENCES jugadores(jugadorId)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    FOREIGN KEY(videojuegoId) REFERENCES videojuegos(videojuegoId)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    UNIQUE(jugadorId,videojuegoId)
    
    
);

## usuario, videojuegoId, puntuacion,comentario, veredicto, fecha

#2

INSERT INTO Valoraciones(jugadorId,videojuegoId,opinion,veredicto,puntuacion) VALUES(1,2, 'Me encantó','Imprescindible',5); 
INSERT INTO Valoraciones(jugadorId,videojuegoId,opinion,veredicto,puntuacion) VALUES(2,4, 'Muy chulo','Comprar en rebajas',3); 
INSERT INTO Valoraciones(jugadorId,videojuegoId,opinion,veredicto,puntuacion) VALUES(3,3, 'Me gusta','Recomendado',4); 
INSERT INTO Valoraciones(jugadorId,videojuegoId,opinion,veredicto,puntuacion) VALUES(4,5, 'Me encantó','No merece la pena',1); 
INSERT INTO Valoraciones(jugadorId,videojuegoId,opinion,veredicto,puntuacion) VALUES(5,2, 'Me encantó','Imprescindible',4.5); 

INSERT INTO Valoraciones(jugadorId,videojuegoId,opinion,veredicto,puntuacion) VALUES(5,2, 'bomba','Imprescindible',4.5); 

###FORMA CORRECTA 
DELIMITER //
CREATE OR REPLACE PROCEDURE p_insertar_valoracion(p_jugadorId INT, p_videojuegoId INT, p_fecha DATE, p_puntuacion
DECIMAL(2,1), p_opinion VARCHAR(250), p_veredicto VARCHAR(250))
BEGIN
INSERT INTO Valoraciones(jugadorId, videojuegoId, fechaValoracion, puntuacion, opinion, veredicto)
VALUES (p_jugadorId, p_videojuegoId, p_fecha, p_puntuacion, p_opinion, p_veredicto);
END;
//
DELIMITER ;


CALL p_insertar_valoracion(2,2,CURDATE(), 5.0, "ideal", "Imprescindible");



#3
SELECT * 
FROM jugadores j 
JOIN valoraciones val ON j.jugadorId = val.jugadorId
JOIN videojuegos v ON val.videojuegoId= v.videojuegoId
ORDER BY v.videojuegoId;

#4

DELIMITER //
CREATE OR REPLACE TRIGGER tFechaValoracion
	BEFORE INSERT ON Valoraciones 
	FOR EACH ROW
	BEGIN
		#meter la fecha de lanzamiento de la tabla videojuegos
		DECLARE fecha_lanzamiento DATE;
		SELECT v.fechaLanzamiento INTO fecha_lanzamiento FROM videojuegos v
		WHERE v.videojuegoId= NEW.videojuegoId;
		
		    IF NEW.fechaValoracion > CURDATE() OR NEW.fechaValoracion < fecha_lanzamiento THEN #fechaValoracion esta dentro de valoraciones(NEW)pero la fechaLanzamiento no, por eso hacemos el DECLARE y el SELECT
			    SIGNAL SQLSTATE '45000'
		       SET MESSAGE_TEXT = 'La fecha de la valoración tiene que ser anterior a la fecha de lanzamiento y posterior a la fecha actual.';
		    END IF;
	END //
DELIMITER ;

CALL p_insertar_valoracion(1,2,"2026-01-01", 5, "ideal", "Imprescindible");


#5

DELIMITER //
CREATE OR REPLACE FUNCTION numValoraciones(jugadorId INT) RETURNS INT
BEGIN
	DECLARE numValoraciones INT;
	SELECT COUNT(*) INTO numValoraciones FROM Valoraciones
   	WHERE valoraciones.jugadorId= jugadorId;
	RETURN numValoraciones;
END //
DELIMITER ;

SELECT numValoraciones(2);





#6

SELECT v.*, AVG(val.puntuacion) AS media_val ##selecciona todas las columnas de videojuegos y calcula el promedio de la columna puntuacion de la tabla valoraciones
FROM videojuegos v LEFT JOIN valoraciones val ON v.videojuegoId=val.videojuegoId
GROUP BY v.videojuegoId
ORDER BY media_val DESC;


#7

DELIMITER //
CREATE TRIGGER check_estado BEFORE INSERT ON Valoraciones
FOR EACH ROW
BEGIN
    DECLARE estado_juego VARCHAR(250);
    SELECT v.estado INTO estado_juego FROM videojuegos v
    WHERE v.videojuegoId= NEW.videojuegoId;

    IF estado_juego = 'Beta' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El videojuego no puede ser valorado al estar en fase beta';
    END IF;
    
END //
DELIMITER ;

CALL p_insertar_valoracion(1,9, CURDATE(), 5, "bueno", "Recomendado"); 


#8
DELIMITER // 
CREATE OR REPLACE PROCEDURE pAddUsuarioValoracion(usuarioId INT, 
juegosId INT, puntuacion INT, fecha DATE, veredicto VARCHAR(64))
	BEGIN 
			START TRANSACTION; 
			tblock: BEGIN 
			DECLARE exit handler FOR SQLEXCEPTION, SQLWARNING 
			BEGIN 
				ROLLBACK; 
				RESIGNAL; 
			END; 
			
		INSERT INTO juegos (usuarioId, juegosId, puntuacion, fecha, veredicto) 
		VALUES (idPhotoGanadora1, nombre1, premio1, fecha1); 
	
		COMMIT; 
		END tblock; 
	END // 
DELIMITER ;


####

DROP TABLE IF EXISTS valoracioninfo;

CREATE TABLE valoracioninfo (
    valoracioninfoId INT PRIMARY KEY AUTO_INCREMENT,
    userId INT UNIQUE NOT NULL, 
    fecha DATE, 
    email VARCHAR(255) UNIQUE NOT NULL,
    contraseña VARCHAR(255) NOT NULL CHECK (CHAR_LENGTH(contraseña) >= 8),
    nombre VARCHAR(255) NOT NULL
    FOREIGN KEY (userId) REFERENCES USER	
);

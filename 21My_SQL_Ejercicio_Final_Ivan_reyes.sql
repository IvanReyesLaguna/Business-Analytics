/*************/
/* INSERTAR */
/*************/

/*EJ 1 - inserta un nuevo usuario en la tabla de usuarios. Ojo, como los ids no pueden estar duplicados, tendras que encontrar cuál es el primero libre que puedes usar */
/* VALUES (xxx, 25, 1, 8, 28029) */
SELECT MAX(id) from users;

INSERT INTO users
VALUES
(944, 25, 1, 8, 28029)

/*EJ2 - Comprueba que lo has añadido correctamente */
SELECT * from users
where id=944;

/*EJ 3 - Busca los ids de las películas: "Return of the Jedi" y "Star Wars" */
SELECT id, title from movies
where title like "%return of the jedi%" or title like "%Star wars%";

/*EJ 4-  Mete en la tabla de ratings, el rating del nuevo usuario para cada esas películas (evaluada cada una de ellas con un 3) */
INSERT INTO ratings
VALUES
(944, 50, 3),
(944, 181, 3);

/* EJ5-Comprueba que lo has añadido correctamente */
SELECT * from ratings
where user_id=944;

/************/
/* ACTUALIZAR */
/************/

/*EJ6 -  Corrige la edad (35 años) y la ocupación (15) del nuevo usuario  */
UPDATE users
SET age="35", occupation_id="15"
WHERE id=944;

/*EJ 7 - Comprueba que lo has modificado correctamente */
SELECT * FROM users
WHERE id=944;

/*EJ8 - Corrige los ratings del nuevo usuario a las películas "Return of the Jedi" y "Star Wars" (cambia el 3 por un 5) */
UPDATE ratings 
SET rating=5
WHERE user_id=944;
  
/* EJ9 - Comprueba que lo has modificado correctamente */
SELECT * from ratings
where user_id=944;
  
  
/************/
/* BORRAR */
/************/

/* EJ10 -Borra el nuevo usario ¿qué ocurre? */
DELETE 
FROM users
where id=944;

#Se eliminaron los registros de la fila a la que afecta la condición.

/* EJ11- Borra los ratings del nuevo usuario */
DELETE 
FROM ratings
WHERE user_id=944;

/* EJ12 -Intenta borrar de nuevo el nuevo usuario */
DELETE 
FROM users
where id=944;

#Se ejecuta la query pero al no encontrar coincidencia en la tabla con la condicición introducida no afecta a ningun resgistro.




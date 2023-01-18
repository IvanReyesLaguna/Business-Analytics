/************/
/* QUERYING */
/************/
/* No hace falta usar joins en esta bloque */

use ej_movielens;

/* EJ1- Muestra los 100 primeros registros de la tabla movies */
SELECT *
FROM movies 
LIMIT 0,100;

/* EJ2- Muestra el título y la fecha de lanzamiento de todas las películas */
SELECT title, release_date
FROM movies;

/* EJ3-Muestra el título y la URL de todas las peículas, renombrando el campo URS por "resumen" */
SELECT title, imdb_url AS resumen
FROM movies;

/*************************/
/* FILTERING - FILTRADO*/
/***********************/
/* No hace falta usar joins en esta bloque */

/*EJ4-Muestra el título y la fecha de lanzamiento de todas las películas que se extrenaron durante el primer semestre de 1997*/ 
SELECT title, release_date FROM movies
WHERE release_date 
BETWEEN '1997-01-01' AND '1997-07-01';

/* EJ5-Muestra el identificador de 'mujer' */
SELECT Id AS identificador_de_Mujer 
from genders 
where description='F';

/* EJ6-Muestra los ids para las ocupaciones: technician, programmer y engineer*/

SELECT id, description as ocupacion
from occupations 
WHERE description='technician' or description='programmer' or description='engineer';

/* EJ7- Muestra todos los usuarios que sean mujeres y que tengan una ocupación técnica (usa los códigos del ejercicio anterior) */
SELECT id as usuarios_mujeres
from users 
WHERE gender_id='2' and occupation_id='1';
#Ocupación tecnica no es especifica, y el id de ocupación tecnico seria el 1.
  
/*EJ8- Muestra todas las peículas que tengan la palabra "story" en el título */
SELECT title 
from movies
WHERE title LIKE "%story%";

/***********************/
/* SORTING - ORDENAR*/
/**********************/
/* No hace falta usar joins en esta bloque */

/*EJ9-Muestra una lista de los usuarios más jóvenes */
SELECT id, age as usuarios_mas_jovenes
from users
order by age asc limit 20;

/* EJ10-Muestra una lista de las películas que se han estrenado más recientemente */
SELECT title, RELEASE_DATE
from movies
order by RELEASE_DATE desc limit 30; 

/*************************/
/* ELILMINAR DUPLICADOS */
/***********************/
/* No hace falta usar joins en esta bloque */

/* EJ11- Muestra un listado de edades únicos por usuarios */
SELECT age, count(age)=1
from users
group by age
having count(age)=1;


/* EJ12- Muestra un listado de edades y códigos postales únicos para usuarios varones */
SELECT distinct age, zipcode
FROM users
WHERE gender_id='1';

/****************************/
/* AGRUPAR Y AGREGAR */
/****************************/
/* No hace falta usar joins en esta bloque */

/* EJ13-Muestra el número de usuarios en la tabla 'users' */
SELECT count(*) 
from users;

/* EJ14-Muestra la fecha máxima de lanzamiento en 1995 */
SELECT max(RELEASE_DATE)
from movies
WHERE RELEASE_DATE LIKE "1995%";

/* EJ15-Muestra las peliculas de mayor a menor géneros asignados */
 SELECT movie_id, count(genre_id)
 from movie_genres
 group by movie_id
 Order by count(genre_id) DESC;

/* EJ16-Muestra un listado de los usuarios y sus calificaciones medias ordenado de más bajas a más altas */

SELECT user_id, avg(rating)
from ratings
group by user_id
order by avg(rating) ASC;


/* EJ17-Muestra un listado de los generos (genre) que tienen más de 100 películas asignadas */
SELECT genre_id AS generos_con_mas_de_100_peliculas_asignadas from movie_genres
GROUP BY genre_id
HAVING count(genre_id)>100;

/*EJ18- ¿cuál es el id de la película ToyStory? */
SELECT id
from movies
Where title like "%Toy%Story%";

/*EJ19-¿cuántos generos (genres) tiene la película Toy Story? */
SELECT movie_id AS TOY_STORY, count(movie_id) AS generos
from movie_genres
WHERE movie_id=1;

/* EJ20- Calcula el rating medio de Toy Story */

SELECT movie_id as toy_story, avg(rating)
from ratings
where movie_id=1;



/* EJ21- Calculalo de nuevo en una única query si desconocieses el id de la película (pista: usa subqueries) */
SELECT avg(rating) FROM ratings
WHERE movie_id=(
SELECT id FROM movies
WHERE title like "%toy%story%");
				  

  
/***********/
/* JOINING */
/***********/
/* Bloque para usar joins */

/*EJ22 - Muestra a todos los usuarios pero en lugar de ids para genero y ocupación, muestra su descripción */

SELECT u.id, u.age, g.description as genero, oc.description as ocupacion, u.zipcode
from users AS u 
left join occupations AS oc on u.occupation_id=oc.id
left join genders as g on u.gender_id=g.ID;


/* EJ23 Calcula el rating medio para cada usuario y genero de la tabla users */
SELECT u.id, u.gender_id, avg(r.rating)
from users AS u
LEFT JOIN ratings AS r ON  u.id=r.user_id
GROUP BY  u.id;

#genero de peliculas 


/* EJ24-Calcula el rating medio para cada usuario de la tabla users */
SELECT u.id, avg(r.rating)
from users AS u
LEFT JOIN ratings AS r ON  u.id=r.user_id
GROUP BY  u.id;

/*EJ25-¿cuál es el máximo número de usuarios y el máximo número de generos(genres) que tenemos? */
SELECT max(u.id), max(ratings.user_id)
from users AS u
join ratings on u.id=ratings.user_id;

SELECT max(genres.id), max(movie_genres.genre_id)
from genres 
join movie_genres on genres.id=movie_genres.genre_id;


/*EJ26- Muestra todo el set de combinaciones posibles entre usuarios y generos(genres)  */
SELECT R.user_id, MG.genre_id 
FROM ratings AS R
INNER JOIN movie_genres AS MG
ON R.movie_id = MG.movie_id;

/*EJ27-Muestra el usuario más joven (solo ese) */
SELECT id,Min(age)
From users
Group by id
order by age ASC limit 1;

/*EJ28-Muestra las 10 peliculas con mayor rating que contengan al menos 10 ratings*/
SELECT m.title, avg(r.rating)
From movies AS m
left join ratings AS r on m.id=r.movie_id
Group by m.title
Having count(rating)>10
Order by avg(r.rating) DESC limit 10;
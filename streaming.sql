Create DATABASE streaming;
Use streaming;

CREATE TABLE Utilisateur(
    id_utilisateur INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(255),
    email VARCHAR(255) UNIQUE, 
    date_inscription DATE
);
CREATE TABLE Film(
    id_film INT PRIMARY KEY AUTO_INCREMENT,
    titre VARCHAR(255),
    genre VARCHAR(100), 
    annee_sortie YEAR, 
    duree INT
);

CREATE TABLE Abonnement(
    id_abonnement INT PRIMARY KEY AUTO_INCREMENT, 
    id_utilisateur INT NOT NULL,
    type_abonnement ENUM('Basic', 'Standard', 'Premium'),
    date_debut DATE, 
    date_fin DATE,
    CONSTRAINT fk_utilisateur FOREIGN KEY(id_utilisateur) REFERENCES utilisateur(id_utilisateur) 
    on DELETE CASCADE 
    on UPDATE CASCADE
);

CREATE TABLE Historique_Visionnage(
    id_historique INT PRIMARY KEY AUTO_INCREMENT,
    id_utilisateur INT NOT NULL,
    id_film INT NOT NULL,
    date_visionnage DATE,
    CONSTRAINT fk_visio_utilisateur FOREIGN KEY(id_utilisateur) REFERENCES utilisateur(id_utilisateur)
    on UPDATE CASCADE
    on DELETE CASCADE,
    CONSTRAINT fk_visio_film FOREIGN KEY(id_film) REFERENCES film(id_film)
    on UPDATE CASCADE
    on DELETE CASCADE
);



SELECT * 
FROM utilisateur
WHERE date_inscription < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

SELECT * FROM `film` 
WHERE genre = 'Science Fiction'
ORDER BY annee_sortie;

SELECT u.id_utilisateur, u.nom, u.email, u.date_inscription, a.type_abonnement, a.date_debut, a.date_fin 
FROM `utilisateur` u, `abonnement` a 
WHERE u.id_utilisateur = a.id_utilisateur and a.type_abonnement = 'Premium' and a.date_fin BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND CURDATE();

SELECT u.id_utilisateur, u.nom, f.id_film, f.titre, h.date_visionnage
FROM `utilisateur` u, `film` f, `Historique_Visionnage` h
WHERE u.id_utilisateur = h.id_utilisateur and f.id_film = h.id_film and h.date_visionnage BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 WEEK) AND CURDATE();

SELECT f.*
FROM Film f
LEFT JOIN Historique_Visionnage hv ON f.id_film = hv.id_film
WHERE hv.id_film IS NULL;

SELECT u.*,COUNT(id_film) as total 
FROM `utilisateur` u, `historique_visionnage` hv 
WHERE u.id_utilisateur = hv.id_utilisateur 
GROUP by hv.id_utilisateur 
HAVING total>10;

SELECT *
FROM Abonnement a;


SELECT u.*, a.type_abonnement, a.date_debut, a.date_fin
FROM `utilisateur` u
LEFT JOIN abonnement a on u.id_utilisateur = a.id_utilisateur;

SELECT u.id_utilisateur, u.nom, u.email, f.titre 
FROM utilisateur u
JOIN historique_visionnage hv ON u.id_utilisateur = hv.id_utilisateur
JOIN film f ON f.id_film = hv.id_film
GROUP BY u.id_utilisateur, f.titre
HAVING COUNT(hv.id_film) > 1;

SELECT f.titre, COUNT(hv.id_film) AS total
FROM film f
JOIN historique_visionnage hv ON f.id_film = hv.id_film
WHERE hv.date_visionnage BETWEEN DATE_SUB(CURDATE(), INTERVAL 6 MONTH) AND CURDATE()
GROUP BY f.titre
ORDER BY total DESC
LIMIT 3;

SELECT u.* 
FROM utilisateur u
JOIN abonnement a on u.id_utilisateur = a.id_utilisateur
LEFT JOIN Historique_Visionnage hv ON a.id_utilisateur = hv.id_utilisateur
WHERE hv.id_utilisateur IS NULL and a.date_fin > CURDATE();

CREATE USER 'Saad'@'localhost' IDENTIFIED BY 'Saad123';
GRANT SELECT, SHOW VIEW ON streaming.* TO 'Saad'@'localhost';
FLUSH PRIVILEGES;

GRANT INSERT, UPDATE, DELETE ON streaming.Film TO 'admin'@'localhost';
GRANT INSERT, UPDATE, DELETE ON streaming.Abonnement TO 'admin'@'localhost';
FLUSH PRIVILEGES;

SELECT f.titre, f.duree,a.id_utilisateur, a.type_abonnement 
FROM Film f
JOIN Historique_Visionnage hv ON f.id_film = hv.id_film
JOIN Abonnement a ON hv.id_utilisateur = a.id_utilisateur
WHERE f.duree > 120
  AND a.type_abonnement = 'Standard';

SELECT u.nom, u.email, f.titre, f.genre, a.type_abonnement
FROM Utilisateur u
JOIN Historique_Visionnage hv ON u.id_utilisateur = hv.id_utilisateur
JOIN Film f ON hv.id_film = f.id_film
JOIN Abonnement a ON u.id_utilisateur = a.id_utilisateur
WHERE f.genre = 'Science Fiction'
  AND a.type_abonnement != 'Premium';
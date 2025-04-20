
Projet final BIO500 : Équipe libidoptères

Objectifs : Dans le cadre du cours, nous avons reçus l'accès à plusieurs jeux de données.
Nous avons choisi de travailler sur celui des lépidoptères. Cela nous donnais accès à tout
les recensements de lépidoptères en Amérique du Nord, depuis 1859. Avec l'aide de rstudio et Github,
nous avons commencé par créer une base de données rassemblant toutes les années, car à la base,
elles sont séparées en fichier excel par année. Ensuite, un coup la base de données créée, 
nous avons passé sur celle-ci à l'aide de fonction pour s'assurer qu'il n'y ait pas de données erronées.
Lorsque l'on observait une erreur ou une colonne vide, par exemple, nous la corrigions. Par la suite, nous 
avons utilisé le language SQL pour créer des subdivisions imaginaires de la base de données,
pour ensuite, les relier ensemble par des clés primaires et secondaires nous permettant ainsi
d'effectuer des requêtes pour la conceptualisation des figures. Pour continuer, nous avons rendu 
le tout plus reproductible en créant un pipeline grâce au package "targets". Et pour finir, nous avons 
fait notre rapport dans un Markdown.


Notre répertoire github est structuré ainsi:

1. Dossier Libidoptères : Dossier regroupant tout les fichiers excels de données par année
2. Dossier fonctions_libidoptères : Dossier regroupant tout scripts à sourcer dans le script principal
3. Fichier taxonomie : Fichier des noms d'espèces, utilisé pour le nettoyage
4. Script _targets.R : Script du target
5. Dossier _targets : Dossier de tout le nécessaire en target


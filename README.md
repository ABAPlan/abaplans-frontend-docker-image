# Image docker abaplans-frontend

## Table des matières

- [Le fichier Dockerfile](#le-fichier-dockerfile)
- [L'image de base](#limage-de-base)
- [La configuration Apache](#la-configuration-apache)
    - [Consulter la configuration de base](#consulter-la-configuration-de-base)
        - [Copier un fichier d'une image à la machine hôte](#copier-un-fichier-dune-image-a-la-machine-hote)
        - [Obtenir une console dans le container](#obtenir-une-console-dans-le-container)
    - [Changements apportés à la configuration de base](#changements-apportes-a-la-configuration-de-base)
        - [Activation de modules](#activation-de-modules)
        - [Réécriture d'URL](#reecriture-durl)

## Le fichier Dockerfile

Cette image se base sur l'image `httpd:2.4`.

On y copie les fichiers statiques du frontend (lesquels doivent se trouver dans le dossier `frontend-dist` à la construction de l'image).

On y copie la configuration Apache (laquelle doit se nommer `httpd.conf` à la construction de l'image) ce qui a pour effet d'écraser la configuration par défaut présente dans l'image.
Voir plus bas pour plus d'information sur la configuration Apache.

On y copie les certificats (lesquels doivent se trouver dans le dossier `certs` et se nommer `server.crt` et `server.key`) pour permettre le HTTPS.
Si les clés ne sont pas correctement copiées, l'image va quitter tout de suite au lancement: La configuration Apache indique la nécéssité des clés pour continuer.

On expose ensuite les ports 80 et 443, respectivement HTTP et HTTPS.

## L'image de base

La documentation de l'image de base se trouve ici: <https://hub.docker.com/_/httpd/>

## La configuration Apache

Comme indiqué dans le paragraphe "Configuration" de la documentation de l'image de base, la configuration d'Apache se trouve dans l'image au chemin suivant: `/usr/local/apache2/conf/httpd.conf`.
Pour copier la configuration de base afin de la consulter et de la modifier pour en faire la configuration voulue avant de l'envoyer à nouveau dans l'image, la solution suivante a été utilisée:

### Consulter la configuration de base

#### Copier un fichier d'une image à la machine hôte

Lien d'une solution SO: <https://stackoverflow.com/a/22050116/4032282>

`docker cp <containerId>:/file/path/within/container /host/path/target`

Il faut pour celà que le container soit lancé.

Il est apparement possible de monter une image en container, sans pour autant la lancer, avec la commande `docker create <nom de l'image>`.

Ce post SO compare `docker run` et `docker start`: <https://stackoverflow.com/questions/37744961/docker-run-vs-create>

Les réponses suivantes sont interessantes:

- <https://stackoverflow.com/a/37745261/4032282>
- <https://stackoverflow.com/a/42039994/4032282>

#### Obtenir une console dans le container

Il suffit de monter l'image de la manière suivante: `docker exec -it <mycontainer> bash`.

### Changements apportés à la configuration de base

#### Activation de modules

En plus de l'indication donnée dans le paragraphe "SSL/HTTPS" de la documentation de l'image de base, qui indique qu'il faut décommenter la ligne `#Include conf/extra/httpd-ssl.conf`, deux autres modules sont à décommenter comme indiqué dans ce commentaire GitHub: <https://github.com/Neilpang/acme.sh/issues/214#issuecomment-226090604>

Il s'agit des lignes suivantes:

- `LoadModule ssl_module modules/mod_ssl.so`
- `LoadModule socache_shmcb_module modules/mod_socache_shmcb.so`

Pour pouvoir activer la redirection de toutes les recherches sur le front-end Angular, il faut également activer le module de ré-écriture d'url: `LoadModule rewrite_module modules/mod_rewrite.so`.

#### Réécriture d'URL

Dans le bloc suivant:

```httpd.conf
<Directory "/usr/local/apache2/htdocs">
    [...]
</Directory>
```

Il faut ajouter les lignes suivantes:

```httpd.conf
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    RewriteRule ^index\.html$ - [L]
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.html [L]
</IfModule>
```
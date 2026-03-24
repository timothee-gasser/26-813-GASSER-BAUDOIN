# Partie IV : Projet Prometheus / Grafana / Netflow / Logs

### Question 24 : 


1. Installation de Docker sur les VM

Nous avons commencé par installer Docker sur la machine virtuelle (ici machine A).

Commandes : `
sudo dnf update -y
/ sudo dnf install -y dnf-plugins-core
/ sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
/ sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`

2. Création des fichiers YAML

Nous avons ensuite créé les fichiers de configuration YAML nécessaires au projet, notamment pour :

- Prometheus
- SNMP exporter
- Graphana

Fichiers utilisés dans le projet :

- [`docker-compose.yml`](docker-compose.yml)
- [`prometheus.yml`](prometheus.yml)
- [`snmp.yml`](snmp.yml)

3. Vérification du démarrage des conteneurs Docker

Une fois les fichiers créés, nous avons lancé les conteneurs et vérifié qu’ils fonctionnaient correctement.

Commande : docker ps

4. Vérification de l’accès à Prometheus

Après le lancement des conteneurs, nous avons vérifié que Prometheus était bien accessible depuis un navigateur à l’adresse suivante :

- [Prometheus](http://192.168.141.112:9090)

Cette étape nous a permis de confirmer que le service était bien lancé et accessible sur le réseau.

5. Vérification de la récupération des interfaces avec SNMP

Nous avons ensuite utilisé les commandes `snmpwalk` pour vérifier que les interfaces réseau des équipements étaient bien détectées.

Cela nous a permis de confirmer que la collecte SNMP fonctionnait correctement et que les informations nécessaires à la supervision étaient bien disponibles.

Exemple equête SNMP depuis Prometheus : `ifDescr / up`

6. Liaison de Grafana avec Prometheus

Une fois la collecte vérifiée, nous avons relié Grafana à Prometheus afin de pouvoir afficher les métriques sous forme de Dashboard.

Grafana est accessible à l’adresse :

- [Grafana](http://192.168.141.112:3000/d/cisco-snmp-supervision/supervision-routeurs-cisco-snmp?orgId=1&from=now-15m&to=now&timezone=browser&var-datasource=PBFA97CFB590B2093&var-router=10.100.4.253)

Login : admin / Password : admin123

7. Création du dashboard Grafana

Nous avons ensuite créé un dashboard Grafana pour visualiser les métriques récupérées depuis Prometheus.

Fichers :

- [`dashboards/`](dashboard_grafana1.json)

8. Test de charge avec iperf

Enfin, nous avons réalisé un test avec iperf entre nos deux PC de manière à faire passer le trafic par le routeur.

Pendant le test, nous avons observé sur le dashboard Grafana une augmentation de la charge réseau sur les interfaces concernées.

<img width="967" height="646" alt="image" src="https://github.com/user-attachments/assets/c1ea888e-18b5-419c-9abc-da42bcbf2ece" />


Lorsque le test iperf a été arrêté, le trafic est revenu à la normale, ce qui a confirmé que la supervision fonctionnait correctement et reflétait bien l’activité réelle du réseau.



## Question 25 :

Prometheus est un système open source de monitoring conçu pour collecter, stocker et exploiter des métriques sous forme de séries temporelles. Son architecture repose sur un modèle de collecte de type pull : le serveur Prometheus interroge périodiquement les systèmes à superviser via des endpoints HTTP afin de récupérer leurs métriques. Chaque donnée collectée est horodatée et associée à des labels permettant d’identifier précisément l’origine, le type de ressource et le contexte de la mesure.

Le composant central est le serveur Prometheus. Celui-ci planifie les opérations de collecte (scrape), interroge les cibles configurées et stocke les résultats dans une base de données locale optimisée pour les séries temporelles (TSDB). Cette base est conçue pour gérer efficacement de grandes quantités de données numériques évoluant dans le temps, avec un accès rapide pour l’analyse historique ou temps réel. Prometheus ne se contente donc pas d’afficher l’état instantané d’un équipement ou d’un service : il permet aussi de suivre l’évolution des performances dans le temps, ce qui est essentiel pour repérer une saturation progressive, une baisse inhabituelle d’activité ou un incident ponctuel.

Les éléments supervisés sont appelés targets. Il peut s’agir de serveurs, d’applications, de conteneurs, d’équipements réseau ou de services cloud. Les targets doivent exposer leurs métriques via un endpoint compatible avec Prometheus. Lorsque ce n’est pas possible, on utilise des exportateurs. Un exportateur est un composant intermédiaire chargé de récupérer des informations via un protocole spécifique (SNMP, système d’exploitation, base de données, etc.) et de les transformer en métriques compréhensibles par Prometheus. On retrouve par exemple des exportateurs pour les systèmes Linux, pour des bases de données, pour des services web, ou encore pour des équipements réseau.

Dans un contexte réseau, SNMP Exporter joue ce rôle en interrogeant les équipements via le protocole SNMP. Il récupère notamment les compteurs d’interface (octets entrants et sortants, erreurs, paquets, état du lien) et les convertit en métriques Prometheus. Cela permet de superviser des routeurs, commutateurs ou firewalls sans modifier leur configuration interne. Ce principe est particulièrement intéressant dans un environnement hétérogène, car de nombreux équipements réseau supportent déjà SNMP nativement, ce qui évite d’installer des agents supplémentaires sur chaque machine.

Prometheus fonctionne sans agent lourd installé sur les machines surveillées. La collecte s’effectue depuis le serveur central, ce qui simplifie le déploiement et la maintenance. Le fichier de configuration définit les cibles, les intervalles de collecte, les paramètres d’accès et les labels associés. Prometheus peut également utiliser des mécanismes de découverte automatique pour adapter dynamiquement la liste des cibles dans des environnements évolutifs. Cette capacité devient utile dans des infrastructures modernes où des services peuvent apparaître, disparaître ou changer d’adresse régulièrement, par exemple dans des architectures conteneurisées ou cloud-native.

Les données collectées sont stockées localement sur le serveur Prometheus. La rétention dépend de l’espace disque disponible et de la configuration choisie. Cette base permet d’analyser l’évolution des performances dans le temps, d’identifier des tendances ou de diagnostiquer des incidents passés. Pour exploiter ces données, Prometheus propose son propre langage de requête, appelé PromQL. Ce langage permet d’effectuer des filtres, des agrégations, des calculs de débit ou des comparaisons entre plusieurs métriques. Il devient alors possible, par exemple, de calculer le trafic moyen d’une interface sur une période donnée ou de comparer la charge de plusieurs équipements en parallèle.

Prometheus intègre également un système d’alerting. Des règles peuvent être définies pour détecter des situations anormales, par exemple une interface saturée, une machine indisponible ou une absence de trafic. Lorsqu’une condition est vérifiée pendant une durée donnée, une alerte est déclenchée. Ces alertes sont généralement envoyées vers Alertmanager, qui se charge de les regrouper, d’éviter les duplications et de les transmettre vers des canaux de notification externes (mail, messagerie, ticketing). Ce mécanisme permet d’automatiser la détection des problèmes au lieu d’attendre qu’un administrateur les remarque manuellement sur un tableau de bord.

L’interface web de Prometheus permet d’explorer les métriques collectées et de tester des requêtes, mais elle reste limitée pour un usage opérationnel. Pour la visualisation avancée, on utilise généralement Grafana. Grafana est une plateforme open source de visualisation de données capable de se connecter à de nombreuses sources, dont Prometheus. Elle permet de construire des tableaux de bord interactifs affichant les métriques sous forme de graphiques temporels, jauges, histogrammes ou tableaux. Les dashboards sont composés de panneaux indépendants, chacun exécutant une requête vers la source de données.

Grafana permet également d’ajouter des variables pour filtrer dynamiquement les données (choix d’une machine, d’une interface ou d’un site). Cela facilite l’analyse d’infrastructures comportant de nombreux équipements. Des annotations peuvent être ajoutées pour marquer des événements importants, comme un déploiement ou une panne. L’intérêt principal de Grafana est de transformer des données brutes en informations directement lisibles. Là où Prometheus est surtout orienté collecte, stockage et interrogation des métriques, Grafana apporte une couche de visualisation qui rend l’ensemble plus exploitable en situation réelle. Il devient ainsi plus simple d’identifier une montée de charge, une rupture de trafic ou un comportement anormal d’un équipement.

Dans un environnement de supervision réseau, la chaîne complète de fonctionnement est la suivante :
- les équipements réseau exposent des informations via SNMP
- SNMP Exporter interroge ces équipements et convertit les OID en métriques Prometheus
- le serveur Prometheus collecte régulièrement ces métriques et les stocke
- Grafana interroge Prometheus pour afficher les données sous forme graphique

Cette architecture permet de mesurer précisément les performances du réseau, notamment les débits d’interface, les taux d’erreur ou l’état des liens. 

--- 

## Question 26 :

Dans cette partie, nous avons rédigé une procédure de tests pour valider la mise en place de la supervision du serveur Web et de la machine B. Nous avons d’abord créé le serveur Web via Docker sur la machine B, avec trois pages différentes accessibles à des URL distinctes. Ensuite, nous avons mis en place Blackbox Exporter afin de pouvoir tester ce service Web par requêtes HTTP. Après cela, nous avons ajouté la configuration correspondante dans Prometheus puis nous avons vérifié dans l’interface Prometheus que les métriques remontaient correctement à l’aide de plusieurs requêtes. Une fois cette partie validée, nous avons créé le dashboard Grafana pour afficher les informations classiques de supervision d’un serveur Web. Enfin, nous avons réalisé plusieurs scripts de tests afin de simuler différents comportements du système et observer leur effet dans la supervision.

## 1. Création du serveur Web via Docker

La première étape a consisté à créer le serveur Web sur la machine A à l’aide de Docker. Le serveur reposait sur un conteneur nginx, auquel était associé un dossier local contenant les fichiers HTML du site.

Le but était d’héberger au moins trois pages différentes, accessibles par des URL distinctes, conformément au sujet. Les pages créées étaient :
- `index.html`
- `page1.html`
- `page2.html`

Les fichiers associés ont été déposés sur GitHub :
- [`docker-compose.yml`](./docker-compose_web.yml)
- [`index.html`](./index.html)
- [`page1.html`](./page1.html)
- [`page2.html`](./page2.html)

### 2. Mise en place de Blackbox Exporter

Une fois le serveur Web fonctionnel, nous avons ajouté Blackbox Exporter. Son rôle est de tester un service vu de l’extérieur, ici notre serveur Web, en effectuant des requêtes HTTP. Cela permet de superviser la disponibilité du site, le code de retour HTTP ainsi que le temps de réponse.

Nous avons également mis en place `node-exporter` sur la machine B afin de pouvoir superviser la machine hébérgeant le service web.

Le principe retenu est le suivant :
- le serveur Web est hébergé sur la machine B ;
- Blackbox Exporter teste les différentes URLs du site ;
- Prometheus interroge Blackbox Exporter pour récupérer les métriques ;
- Grafana utilise ensuite ces métriques pour créer le dashboard de supervision Web.

Les fichiers liés à cette étape ont été déposés sur GitHub :
- [`blackbox.yml`](./blackbox.yml)
- [`docker-compose.yml`](./docker-compose_blackbox.yml)

Les trois pages testées étaient les suivantes :
- `http://10.100.4.2:8080/`
- `http://10.100.4.2:8080/page1.html`
- `http://10.100.4.2:8080/page2.html`

### 3. Ajout de la configuration dans Prometheus

Après la mise en place de Blackbox Exporter, nous avons ajouté sa configuration dans le fichier prometheus.yml. Cette configuration permet à Prometheus d’interroger régulièrement Blackbox Exporter en lui demandant de tester les différentes pages du site.

Le fichier correspondant est disponible ici :

- [`prometheus.yml`](./prometheus.yml)

Après modification du fichier de configuration, Prometheus a été redémarré afin de prendre en compte ce nouveau job.

### 4. Vérification dans Prometheus

Après avoir ajouté la configuration, nous avons testé directement dans l’interface Prometheus pour vérifier que les métriques remontaient correctement. Cette étape nous a permis de valider le bon fonctionnement du job blackbox-http avant de passer à Grafana.

Les principales requêtes testées étaient :

- probe_success{job="blackbox-http"} -> Disponibilité des pages 
- probe_duration_seconds{job="blackbox-http"} -> Disponibilité des pages 
- probe_duration_seconds{job="blackbox-http"} -> Temps de réponse HTTP

### 5. Création du dashboard Grafana

Une fois la collecte validée dans Prometheus et le serveur Web opérationnel, nous avons créé le dashboard Grafana correspondant à la supervision classique d’un serveur Web.

L’objectif du dashboard était de visualiser les informations suivantes :

disponibilité du site ;
disponibilité page par page ;
temps de réponse HTTP ;
code de retour HTTP ;
nombre de pages disponibles.

Les métriques utilisées provenaient directement du job blackbox-http déjà validé dans Prometheus. Le dashboard permettait donc d’avoir une vue claire et immédiate de l’état du serveur Web.

## 6. Scripts de tests réalisés

Afin de valider le bon comportement du dashboard et de la supervision, nous avons réalisé trois scripts de tests différents. Chaque script permettait de simuler un comportement précis du système afin d’observer la réaction de Prometheus et de Grafana.

Les scripts ont été déposés sur GitHub :
- [`scripts/test_cpu_load.sh`](./test_cpu_load.sh)
- [`scripts/test_http_load.sh`](./test_http_load.sh)
- [`scripts/test_page1_down.sh`](./test_page1_down.sh)

### 6.1 Script de charge CPU

Ce script permet de générer temporairement une charge CPU sur la machine B.

Résultat attendu :
- hausse de la charge CPU sur la machine B ;
- possible impact léger sur le temps de réponse du site.

### 6.2 Script de test du temps de réponse du site

Ce script envoie de nombreuses requêtes HTTP vers une page du site pendant un temps donné afin d’augmenter l’activité Web.

Résultat attendu :
- augmentation de l’activité HTTP sur le serveur ;
- variation du temps de réponse dans Grafana.

### 6.3 Script de panne partielle de la page 1

Ce script rend temporairement indisponible la page `page1.html`, puis la restaure automatiquement.

Résultat attendu :
- la page `page1.html` devient temporairement indisponible ;
- le code HTTP passe à `404` ;
- `probe_success` passe à `0` pour cette page ;
- les autres pages restent accessibles.

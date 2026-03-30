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

- [`docker-compose.yml`](./machine_A/monitoring/docker-compose.yml)
- [`prometheus.yml`](./machine_A/monitoring/docker-compose.yml)
- [`snmp.yml`](./machine_A/monitoring/snmp_exporter/snmp.yml)

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

- [`Dashboards`](./grafana/Supervision_Routeurs_Cisco_SNMP.json)

8. Test de charge avec iperf

Enfin, nous avons réalisé un test avec iperf entre nos deux PC de manière à faire passer le trafic par le routeur.

Pendant le test, nous avons observé sur le dashboard Grafana une augmentation de la charge réseau sur les interfaces concernées.

<img width="967" height="646" alt="image" src="https://github.com/user-attachments/assets/c1ea888e-18b5-419c-9abc-da42bcbf2ece" />


Lorsque le test iperf a été arrêté, le trafic est revenu à la normale, ce qui a confirmé que la supervision fonctionnait correctement et reflétait bien l’activité réelle du réseau.

---

## Question 25 :

Prometheus est un système open source de monitoring conçu pour collecter, stocker et exploiter des métriques sous forme de séries temporelles. Son architecture repose sur un modèle de collecte de type pull : le serveur Prometheus interroge périodiquement les systèmes à superviser via des endpoints HTTP afin de récupérer leurs métriques. Chaque donnée collectée est horodatée et associée à des labels permettant d’identifier l’origine, le type de ressource et le contexte de la mesure.

Le composant central est le serveur Prometheus. Celui-ci planifie les opérations de collecte (scrape), interroge les cibles configurées et stocke les résultats dans une base de données locale optimisée pour les séries temporelles, appelée TSDB. Cette base permet de conserver l’évolution des mesures dans le temps et de faire aussi bien une analyse en temps réel qu’une analyse historique. Prometheus ne sert donc pas seulement à connaître l’état instantané d’un équipement ou d’un service, mais aussi à suivre l’évolution des performances, repérer une saturation progressive ou revenir sur un incident passé.

Les éléments supervisés sont appelés targets. Il peut s’agir de serveurs, d’applications, de conteneurs, d’équipements réseau ou de services divers. Les targets doivent exposer leurs métriques via un endpoint compatible avec Prometheus. Lorsque ce n’est pas possible, on utilise des exportateurs. Un exportateur est un composant intermédiaire chargé de récupérer des informations via un protocole spécifique, comme SNMP ou les métriques système Linux, puis de les transformer en données compréhensibles par Prometheus. Il existe ainsi des exportateurs pour les systèmes Linux, pour des services web, pour des bases de données ou encore pour des équipements réseau.

Dans un contexte réseau, SNMP Exporter joue ce rôle en interrogeant les équipements via le protocole SNMP. Il récupère notamment les compteurs d’interface, comme les octets entrants et sortants, les erreurs, les paquets ou l’état du lien, puis les convertit en métriques Prometheus. Cela permet de superviser des routeurs, commutateurs ou firewalls sans modifier leur configuration interne. Ce principe est particulièrement intéressant dans un environnement hétérogène, car de nombreux équipements réseau supportent déjà SNMP nativement, ce qui évite d’installer des agents supplémentaires. Dans notre TP, cette étape a été validée avec des commandes de type `snmpwalk`, qui nous ont permis de vérifier que les interfaces du routeur étaient bien visibles avant même de les exploiter dans Prometheus.

Prometheus fonctionne sans agent lourd installé sur les machines surveillées. La collecte s’effectue depuis le serveur central, ce qui simplifie le déploiement et la maintenance. Le fichier de configuration définit les cibles, les intervalles de collecte, les paramètres d’accès et les labels associés. Les données collectées sont ensuite stockées localement, avec une durée de rétention qui dépend de la configuration choisie et de l’espace disque disponible. Dans notre cas, l’environnement a été déployé sous Docker, ce qui a permis de lancer rapidement les différents services de supervision et de vérifier leur fonctionnement avec des commandes simples comme `docker ps` ou `docker compose up -d`.

Pour exploiter ces données, Prometheus propose son propre langage de requête, appelé PromQL. Ce langage permet d’effectuer des filtres, des agrégations, des calculs de débit ou des comparaisons entre plusieurs métriques. Il devient alors possible, par exemple, de calculer le trafic moyen d’une interface sur une période donnée, de comparer plusieurs équipements ou encore de suivre l’évolution d’une charge CPU. Dans notre TP, nous avons justement vérifié la remontée des métriques à l’aide de requêtes simples dans Prometheus, par exemple sur la disponibilité de pages web avec `probe_success{job="blackbox-http"}`, sur le temps de réponse avec `probe_duration_seconds{job="blackbox-http"}` ou encore sur le code HTTP avec `probe_http_status_code{job="blackbox-http"}`.

Prometheus intègre aussi un système d’alerting. Des règles peuvent être définies pour détecter des situations anormales, comme une interface saturée, une machine indisponible ou une absence de trafic. Les alertes peuvent ensuite être transmises à Alertmanager, qui se charge de les regrouper et de les envoyer vers des canaux de notification externes. 

L’interface web de Prometheus permet d’explorer les métriques collectées et de tester des requêtes, mais elle reste limitée pour un usage opérationnel. Pour la visualisation avancée, on utilise généralement Grafana. Grafana est une plateforme open source de visualisation de données capable de se connecter à de nombreuses sources, dont Prometheus. Elle permet de construire des tableaux de bord interactifs affichant les métriques sous forme de graphiques temporels, jauges, histogrammes ou tableaux. Les dashboards sont composés de panneaux indépendants, chacun exécutant une requête vers la source de données. Grafana permet aussi d’ajouter des variables pour filtrer dynamiquement les données et rendre l’analyse plus lisible.

L’intérêt principal de Grafana est de transformer des données brutes en informations directement exploitables. Là où Prometheus est surtout orienté collecte, stockage et interrogation des métriques, Grafana apporte une couche de visualisation qui rend l’ensemble plus clair. Il devient ainsi plus simple d’identifier une montée de charge, une rupture de trafic ou un comportement anormal sur une machine ou sur un service. Dans notre TP, cette étape a été concrète puisque nous avons relié Grafana à Prometheus, puis créé des dashboards pour visualiser les métriques réseau, les métriques système classiques et la supervision du serveur web.

Dans le cadre de notre TP, cette architecture a été mise en œuvre de façon concrète. Nous avons d’abord utilisé Prometheus et SNMP Exporter pour superviser les équipements réseau et récupérer les métriques liées aux interfaces. Les données collectées concernaient notamment le trafic entrant et sortant, ce qui nous a permis de suivre l’activité du réseau. Ensuite, nous avons relié Grafana à Prometheus afin d’afficher ces métriques sous forme de dashboards. Cela nous a permis d’observer visuellement l’évolution de la charge et de vérifier que les valeurs remontées correspondaient bien au comportement réel du réseau. Par exemple, lors d’un test `iperf` entre deux machines, nous avons pu constater sur le dashboard une hausse du trafic sur les interfaces concernées, puis un retour à la normale à l’arrêt du test.

Cette architecture permet de mesurer précisément les performances du réseau et des services, d’identifier rapidement une anomalie et de valider expérimentalement l’effet d’un test ou d’un incident sur l’infrastructure supervisée.

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
- [`Docker-compose.yml`](./machine_B/docker-compose_web.yml)
- [`index.html`](./machine_B/index.html)
- [`page1.html`](./machine_B/page1.html)
- [`page2.html`](./machine_B/page2.html)

### 2. Mise en place de Blackbox Exporter

Une fois le serveur Web fonctionnel, nous avons ajouté Blackbox Exporter. Son rôle est de tester un service vu de l’extérieur, ici notre serveur Web, en effectuant des requêtes HTTP. Cela permet de superviser la disponibilité du site, le code de retour HTTP ainsi que le temps de réponse.

Nous avons également mis en place `node-exporter` sur la machine B afin de pouvoir superviser la machine hébérgeant le service web.

Le principe retenu est le suivant :
- le serveur Web est hébergé sur la machine B ;
- Blackbox Exporter teste les différentes URLs du site ;
- Prometheus interroge Blackbox Exporter pour récupérer les métriques ;
- Grafana utilise ensuite ces métriques pour créer le dashboard de supervision Web.

Les fichiers liés à cette étape ont été déposés sur GitHub :
- [`Blackbox.yml`](./machine_B/blackbox.yml)
- [`Docker-compose.yml`](./machine_B/docker-compose.yml)

Les trois pages testées étaient les suivantes :
- `http://10.100.4.2:8080/`
- `http://10.100.4.2:8080/page1.html`
- `http://10.100.4.2:8080/page2.html`

### 3. Ajout de la configuration dans Prometheus

Après la mise en place de Blackbox Exporter, nous avons ajouté sa configuration dans le fichier prometheus.yml. Cette configuration permet à Prometheus d’interroger régulièrement Blackbox Exporter en lui demandant de tester les différentes pages du site.

Le fichier correspondant est disponible ici :

- [`Prometheus.yml`](./machine_A/monitoring/prometheus/prometheus.yml)

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
- [`scripts_test_charge_cpu`](./machine_B/test_cpu_load.sh)
- [`scripts_test_charge_http`](./machine_B/test_http_load.sh)
- [`scripts_test_page1_down`](./machine_B/test_page1_down.sh)

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

--- 

## Question 27

Dans cette partie, nous avons mis en place une supervision avancée basée sur l’analyse des flux réseau à l’aide de NetFlow, couplée à Prometheus, Ktranslate et Grafana.

### 1. Mise en place de Ktranslate

Dans un premier temps, nous avons déployé Ktranslate via Docker afin de collecter et transformer les flux NetFlow en métriques exploitables par Prometheus.  
Ktranslate agit comme un collecteur de flux (collector) et un convertisseur vers un format compatible avec Prometheus.

-[`Docker compose`](./machine_A/monitoring/docker-compose.yml)

### 2. Configuration de NetFlow sur les routeurs

Nous avons ensuite configuré NetFlow sur les routeurs afin d’exporter les flux vers la machine hébergeant Ktranslate.

Configuration réalisée :

```bash
flow record RECORD
 match ipv4 source address
 match ipv4 destination address
 match transport source-port
 match transport destination-port
 match ipv4 protocol
 collect counter bytes
 collect counter packets

flow exporter EXPORTER
 destination 10.100.4.1
 transport udp 2055
 source GigabitEthernet1
 export-protocol netflow-v9

flow monitor MONITOR
 record RECORD
 exporter EXPORTER
 cache timeout active 60

interface GigabitEthernet1
 ip flow monitor MONITOR input
 ip flow monitor MONITOR output
```

### 3. Vérification côté Prometheus

Une fois NetFlow et Ktranslate configurés, nous avons vérifié que les métriques étaient bien collectées en interrogeant Prometheus via son interface web.

Nous avons testé différentes requêtes afin de vérifier la présence des données issues des flux réseau, ce qui confirme que Ktranslate fonctionne correctement et que les données sont bien intégrées dans Prometheus.

### 4. Mise en place du dashboard Grafana

Nous avons ensuite ajouté un dashboard Grafana permettant de visualiser les flux réseau.

- [`Dashboards`](./grafana/Ktranslate.json)

<img width="2553" height="1195" alt="image" src="https://github.com/user-attachments/assets/b5808ddb-9794-44a6-96f7-1c23ad0cef7b" />


Ce dashboard permet notamment d’observer :

- Le volume de trafic
- Les adresses IP sources et dest les plus utilisées
- Courbe sur la répartition par application et protocole

### 5. Validation avec génération de trafic

Enfin, nous avons validé le fonctionnement de la supervision en générant du trafic à l’aide d’un script envoyant des requêtes HTTP (curl) vers une URL.

- [`Script_ktranslate`](./machine_B/script_ktranslate.sh)

Lors de l’exécution de ce script, nous avons observé une montée en charge sur le dashboard Grafana, ce qui confirme que :

- Les flux NetFlow sont bien exportés par les routeurs
- Ktranslate collecte et transforme correctement les données
- Prometheus stocke les métriques
- Grafana affiche les données en temps réel


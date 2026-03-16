# Partie III : Script bash de mesure de débit en SNMP (1 séance)

### Question 19 : 
L’utilisation de cron ou des timers systemd est plus pertinente que la fonction sleep car cela évite de laisser un processus actif en permanence en arrière-plan.  
Le système ne lance le script qu’au moment nécessaire, ce qui consomme moins de ressources.  
De plus, cron et systemd permettent une exécution régulière, fiable et facile à administrer.  
Cette solution est donc plus propre et plus adaptée à une supervision sur une longue durée.

# 5.1 Récupération du compteur d’octets : 
# 5.2 Gestion de la date et enregistrement des résultats dans un fichier.
# 5.3 Lecture de la dernière ligne du fichier, calcul et enregistrement du débit

---

### Question 20 : 
Pour tester le fonctionnement du script, nous avons exécuté plusieurs fois le script ['snmp-1.sh'](snmp-1.sh) afin de relever les valeurs du compteur SNMP et calculer le débit moyen entre deux mesures successives.

Chaque exécution du script ajoute une ligne dans le fichier `throughput_int3.txt` contenant :
- la date de la mesure (en secondes depuis le 01/01/1970),
- la valeur du compteur d’octets,
- le débit moyen calculé depuis la dernière mesure.

Après plusieurs exécutions du script, nous avons obtenu le fichier suivant :

1773071065;105234665  
1773071167;105241766;556  
1773071179;105242190;282  
1773071191;105242380;126  
1773071206;105242858;254  
1773071234;105244094;353 
Lancement iperf :
1773071246;105309063;43312  
1773071257;105309521;333  

On observe que la valeur du compteur d’octets augmente à chaque mesure, ce qui est cohérent avec le fonctionnement du compteur SNMP.  
Le script calcule ensuite le débit moyen en bits par seconde entre deux mesures successives.

Les valeurs de débit obtenues varient en fonction du trafic présent sur l’interface au moment de la mesure. Par exemple, on observe des débits de 556 bit/s, 282 bit/s ou encore 43312 bit/s lors d’un pic de trafic.

---

# 5.4 Gestion du fichier vide et gestion du rebouclage du compteur d'octets.

### Question 21 : 

Un compteur d’octets SNMP est un compteur cumulatif qui augmente en permanence. Lorsqu’il atteint sa valeur maximale, il reboucle et repart à zéro. Ce phénomène est appelé rebouclage ou overflow.

Le problème est que la nouvelle valeur devient alors inférieure à l’ancienne. Si l’on calcule simplement la différence entre les deux valeurs, on obtient un résultat négatif ou incorrect, ce qui fausse le calcul du débit.

La solution consiste à détecter ce cas dans le script. Si la nouvelle valeur est inférieure à l’ancienne, on considère qu’il y a eu rebouclage. Le nombre réel d’octets transférés est alors calculé en ajoutant la portion restante jusqu’à la valeur maximale du compteur à la nouvelle valeur relevée après rebouclage.

Dans notre cas, nous avons lancé le script ['snmp-4.sh'](snmp-4.sh), mais aucun rebouclage n’a été observé lors des tests, ce qui est normal car les compteurs utilisés sont sur 64 bits et leur capacité est très grande. Néanmoins, le script implémente la gestion de ce cas afin d’assurer un calcul correct du débit sur de longues périodes.

--- 

# 5.5 Utilisation du cron pour que le script s’exécute toutes les minutes 

### Question 22 : 


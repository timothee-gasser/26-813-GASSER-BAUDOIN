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
Pour tester le fonctionnement du script, nous avons exécuté plusieurs fois le script `snmp-3.sh` afin de relever les valeurs du compteur SNMP et calculer le débit moyen entre deux mesures successives.

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

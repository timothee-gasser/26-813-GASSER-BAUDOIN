# Partie II : Supervision et métrologie avec SNMP

# 4.1 Configuration de SNMPv3 dans les routeurs

### Question 9 :
Commande pour obtenir le sysLcoccation de R1:
`snmpget -v3 -l authPriv -u snmpuser -a SHA -A auth_pass -x AES -X crypt_pass 10.100.4.252 SNMPv2-MIB::sysLocation.0`

Cette commande donne en sortie :
` SNMPv2-MIB::sysLocation.0 = STRING: Salle TP - Groupe 4`

# 4.2 Configuration de SNMPv2 dans les routeurs 

### Question 10 :

SNMP utilise l'encodage ASN1 avec BER(Basic encoding rules)

---

### Question 11 :

Nous effectuons un SNMP GET sur le MTU de la deuxième interface du routeur : snmpget -v2c -c 123test123 10.250.0.7 IF-MIB::ifMtu.2

La capture est réalisée avec la commande : tshark -i ens18 -x udp port 161

Extrait de la trame capturée :

0000 30 29 02 01 01 04 0a 31 32 33 74 65 73 74 31
0010 32 33 a0 1a 02 04 19 84 13 35 02 01 00 02 01
0020 00 30 10 30 0e 06 0a 2b 06 01 02 01 02 02 01
0030 04 02 01 00

La trame SNMP est encodée en ASN.1 selon les règles BER.

On retrouve les champs suivants :

- `02 01 01` : version SNMP (v2c)
- `04` : champ communauté
- `31 32 33 74 65 73 74 31 32 33` : chaîne ASCII correspondant à la communauté `123test123`
- `A0` : type de PDU correspondant à une requête GET
- `06` : identifiant d’objet (OID)
- `2b 06 01 02 01` : racine de la MIB (mib-2)
- `02 02 01 04` : objet ifMtu.2

La réponse du routeur contient la valeur de l’objet demandé :

IF-MIB::ifMtu.2 = INTEGER: 1500

---

### Question 12 :

La branche VRRP dans la MIB est définie dans le fichier VRRP-MIB par la ligne :

vrrpMIB OBJECT IDENTIFIER ::= { mib-2 68 }

Cela signifie que la MIB VRRP se situe sous la branche mib-2 avec l’identifiant 68.
L’OID correspondant est donc :

1.3.6.1.2.1.68

---

### Question 13 :

La commande suivante échoue : snmpwalk -v2c -c 123test123 10.100.X.Y vrrpMIB car l’outil SNMP ne connaît pas le nom symbolique `vrrpMIB`. En effet, la MIB VRRP n’est pas chargée localement sur la machine qui exécute la commande, donc l’outil ne peut pas traduire ce nom en OID numérique.

En revanche, la commande suivante fonctionne : snmpwalk -v2c -c 123test123 10.100.X.Y mib-2.68 car elle utilise directement l’OID numérique correspondant à la branche VRRP dans la MIB (mib-2.68). L’agent SNMP du routeur comprend cet OID et peut donc renvoyer les informations associées aux objets de la MIB VRRP.

---

### Question 14 :

La table `vrrpOperTable` possède l’OID suivant par rapport à mib-2 : mib-2.68.1.3

Elle peut être consultée avec la commande : snmpwalk -v2c -c 123test123 10.100.4.253 mib-2.68.1.3

La commande retourne les informations de fonctionnement du protocole VRRP sur le routeur.  
Voici un extrait des valeurs obtenues :

- mib-2.68.1.3.1.2.1.4 = Hex-STRING: 00 00 5E 00 01 04
- mib-2.68.1.3.1.3.1.4 = INTEGER: 3
- mib-2.68.1.3.1.4.1.4 = INTEGER: 1
- mib-2.68.1.3.1.5.1.4 = INTEGER: 100
- mib-2.68.1.3.1.6.1.4 = INTEGER: 1
- mib-2.68.1.3.1.7.1.4 = IpAddress: 10.100.4.253
- mib-2.68.1.3.1.8.1.4 = IpAddress: 10.100.4.254
- mib-2.68.1.3.1.9.1.4 = INTEGER: 1

Ces valeurs correspondent aux premières colonnes de la table `vrrpOperTable` :

- `vrrpOperVrId` : identifiant du groupe VRRP  
- `vrrpOperVirtualMacAddr` : adresse MAC virtuelle VRRP (00:00:5E:00:01:04)  
- `vrrpOperState` : état du routeur dans le groupe VRRP (master ou backup)  
- `vrrpOperPriority` : priorité VRRP configurée sur le routeur  
- `vrrpOperIpAddrCount` : nombre d’adresses IP virtuelles configurées  
- `vrrpOperMasterIpAddr` : adresse IP du routeur master  
- `vrrpOperPrimaryIpAddr` : adresse IP principale de l’interface  
- `vrrpOperAuthType` : type d’authentification utilisé

L’index de cette table est composé de deux éléments :
- l’index de l’interface réseau (`ifIndex`)
- l’identifiant du groupe VRRP (`VRID`).


# 4.3 Métrologie

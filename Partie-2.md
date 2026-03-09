# Partie II : Supervision et métrologie avec SNMP

# 4.1 Configuration de SNMPv3 dans les routeurs

### Question 9 :
Commande pour obtenir le sysLcoccation de R1:
`snmpget -v3 -l authPriv -u snmpuser -a SHA -A auth_pass -x AES -X crypt_pass 10.100.4.252 SNMPv2-MIB::sysLocation.0`

Cette commande donne en sortie :
` SNMPv2-MIB::sysLocation.0 = STRING: Salle TP - Groupe 4`

---

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

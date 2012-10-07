Siriproxy Plugin Homematic Version 0.1
10'2012 basti, hobbyquaker@gmail.com

IP-Adresse der CCU in Zeile 31 anpassen.

Das Plugin liest beim ersten Aufruf, nach dem (Neu-)start des Siriproxy, die verfügbaren
Schalt-, Dimm- und Rollladenaktoren sowie Zentralenprogramme via XMLAPI aus der 
Homematic CCU aus. 

Mit dem Befehl "Licht <homematic-kanal-name> 30 Prozent" kann dann z.b. eine Lampe gedimmt werden,
neben Prozentangaben sind hier auch die Worte "an" und "aus" möglich. Ausser auf "Licht" reagiert
das Plugin auch auf die Worte "Rollladen", "Markise" und "Steckdose".
Zentralen-Programme lassen sich über den Befehl "Automatik" gefolgt von Namen des Programms starten.

###Siriproxy Homematic Plugin Version 0.1

Das Plugin liest beim ersten Aufruf, nach dem (Neu-)start des Siriproxy, die verfügbaren
Schalt-, Dimm- und Rollladenaktoren sowie Zentralenprogramme via XMLAPI aus der 
Homematic CCU aus. 

Mit dem Befehl "Licht <homematic-kanal-name> 30 Prozent" kann dann z.b. eine Lampe gedimmt werden,
neben Prozentangaben sind hier auch die Worte "an" und "aus" möglich. Ausser auf "Licht" reagiert
das Plugin auch auf die Worte "Rollladen", "Markise" und "Steckdose".
Zentralen-Programme lassen sich über den Befehl "Automatik" gefolgt von Namen des Programms starten.

###Installation
in config.yml eintragen, Pfad und IP Adresse der CCU anpassen!

```ruby
    - name: 'Homematic'
      path: '/path/to/plugins/siriproxy-homematic'
      ccu_ip: '172.16.23.3'
```


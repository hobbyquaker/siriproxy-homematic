###Siriproxy Homematic Plugin Version 0.1

Ein kleines Demo-Video: http://www.youtube.com/watch?v=PRAo6GPoI2Y

Das Plugin liest beim ersten Aufruf, nach dem (Neu-)start des Siriproxy, die verfügbaren
Schalt-, Dimm- und Rollladenaktoren sowie Zentralenprogramme via XMLAPI aus der 
Homematic CCU aus. 


###Befehle
**Siri:** Licht *(Bezeichner)* *(0-100)* Prozent     
**Siri:** Licht *(Bezeichner)* an     
**Siri:** Licht *(Bezeichner)* aus     
Steuert Schalt-, Dimm- und Rollladen-Aktoren     
Statt dem Befehl "Licht" kann auch "Steckdose", "Rollladen" und "Markise" verwendet werden. Dies hat allerdings keine Auswirkung auf den gesteuerten Kanal, dieser wird nur über den Bezeichner gesucht.

**Siri:** Automatik *(Bezeichner)*    
Startet ein Zentralenprogramm


###Installation

Getestet mit TLP 0.11.3

Benötigt xmlsimple:
```bash
gem install xml-simple
```

in config.yml eintragen, Pfad und IP Adresse der CCU anpassen!

```ruby
    - name: 'Homematic'
      path: '/path/to/plugins/siriproxy-homematic'
      ccu_ip: '172.16.23.3'
```


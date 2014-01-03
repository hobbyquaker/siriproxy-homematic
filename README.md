#Siriproxy Homematic Plugin Version 0.2

#Dieses Plugin wird mangels iOS7-kompatiblem Siriproxy nicht mehr weiterentwickelt. Sobald es einen iOS7 fähigen Siriproxy gibt wird ein Nachfolgeprojekt gestartet: ein Siriproxy-Adapter für CCU.IO http://ccu.io

Ein kleines Demo-Video: http://www.youtube.com/watch?v=PRAo6GPoI2Y

Mit diesem Plugin können Homematic Dimm-, Schalt-, und Rollladen-Aktoren über Siri gesteuert werden. Auch Programme starten und Systemvariablen lesen ist möglich. Das Plugin liest die Bezeichner der Kanäle, Variablen und Programme aus der CCU aus, daher muss ausser der CCU-IP keine weitere Konfiguration vorgenommen werden. Siehe auch diesen Forums-Thread: http://homematic-forum.de/forum/viewtopic.php?f=31&t=10237

###Befehle
#### Aktoren steuern
**Siri:** [Licht|Lampe|Beleuchtung|Steckdose|Stromkreis] *(Bezeichner)* *(0-100)* Prozent     
**Siri:** [Licht|Lampe|Beleuchtung|Steckdose|Stromkreis] *(Bezeichner)* [an|aus|anschalten|ausschalten|abschalten]   
**Siri:** [Rolladen|Markise] *(Bezeichner)* *(0-100)* Prozent    
**Siri:** [Rolladen|Markise] *(Bezeichner)* [auf|zu|öffnen|schließen]    
#### Variablen abfragen
**Siri:** Status *(Bezeichner)*
#### Programme starten
**Siri:** Automatik *(Bezeichner)*


### Vorraussetzungen
####Homematic CCU
Auf der CCU muss die Firmware-Erweiterung XML-API eingerichtet sein. Damit Variablen auch mit den Text-Bezeichnern aus ihren Wertelisten gelesen und gesetzt werden können ist eine modifizierte Version der XML-API notwendig: https://github.com/hobbyquaker/hq-xmlapi
####Siriproxy
Dieses Software benötigt einen fertig eingerichteten, funktionierenden Siri-Proxy: https://github.com/jimmykane/The-Three-Little-Pigs-Siri-Proxy    


###Einrichtung des Plugins
Verzeichnis siriproxy-homematic in das plugins Verzeichnis des Siriproxy kopieren

in config.yml des Siriproxy eintragen, Pfad und IP Adresse der CCU anpassen!

```ruby
    - name: 'Homematic'
      path: '/path/to/plugins/siriproxy-homematic'
      ccu_ip: '172.16.23.3'
```

Siriproxy beenden, lokales Update durchführen: ```siriproxy update .```, Siriproxy neu starten.


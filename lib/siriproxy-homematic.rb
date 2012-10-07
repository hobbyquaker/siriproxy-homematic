# -*- encoding : utf-8 -*-

#######
#
#   Siriproxy Plugin Homematic Version 0.1
#   10'2012 basti, hobbyquaker@gmail.com
#
#   IP-Adresse der CCU in Zeile 31 anpassen.
#
#   Das Plugin liest beim ersten Aufruf, nach dem (Neu-)start des Siriproxy, die verfügbaren
#   Schalt-, Dimm- und Rollladenaktoren sowie Zentralenprogramme via XMLAPI aus der 
#   Homematic CCU aus. 
#
#   Mit dem Befehl "Licht <homematic-kanal-name> 30 Prozent" kann dann z.b. eine Lampe gedimmt werden,
#   neben Prozentangaben sind hier auch die Worte "an" und "aus" möglich. Ausser auf "Licht" reagiert
#   das Plugin auch auf die Worte "Rollladen", "Markise" und "Steckdose".
#   Zentralen-Programme lassen sich über den Befehl "Automatik" gefolgt von Namen des Programms starten.
#
######

require 'cora'
require 'siri_objects'
require 'pp'
require 'net/http'
require 'xmlsimple'

class SiriProxy::Plugin::Homematic < SiriProxy::Plugin
  def initialize(config)

    # Hier die IP-Adresse der CCU anpassen!
    @hm_url = "http://172.16.23.3/config/xmlapi/"

    if !$hm_channels
      $hm_channels = Hash.new
      $hm_programs = Hash.new
      $hm_sysvars = Hash.new
      hm_get_config
    end
  end

  # Schalt-, Dimm-, und Rollladen-Aktoren steuern
  listen_for /(licht|rollladen|markise|steckdose) ([a-zäöüA-ZÄÖÜß ]+) (an|aus|[0-9]+ %)/i  do |type,description,value|
  #Syntaxhighlighting kaputt)
    response = "parsed: type=" + type + " description=" + description + " value=" + value
    say response, spoken: ""
    case value.downcase
      when "an"
        value = "1"
      when "aus"
        value = "0"
      else
        value = value.to_f / 100
        value = "%.2f" % value
    end
    search = description.downcase.strip
    result = $hm_channels.keys.grep(/#{search}/i)
    if result.size == 1
      response = "found: " + result[0]
      say response, spoken: ""
      hm_statechange $hm_channels[result[0]], value, "Befehl an Zentrale gesendet.", "Ok."
    elsif result.size > 1
      response = ""
      result.each do |channel|
         response = response + channel + ", "
      end 
      say "found: " + response, spoken: "" 
      say description + " nicht eindeutig.", spoken: description + " habe ich mehrfach gefunden."
      request_completed
    else
      say description + " nicht gefunden.", spoken: description + " konnte ich leider nicht finden."
      request_completed
    end
  end

  # Programme ausführen
  listen_for /automatik ([a-zäöüA-ZÄÖÜß ]+)/i  do |description|
    response = "parsed: description=" + description
    say response, spoken: ""
    search = description.downcase.strip
    result = $hm_programs.keys.grep(/#{search}/i)
    if result.size == 1
      response = "found: " + result[0]
      say response, spoken: ""
      hm_runprogram $hm_programs[result[0]], "Befehl an Zentrale gesendet.", "Ok."
    elsif result.size > 1
      response = ""
      result.each do |channel|
         response = response + channel + ", "
      end 
      say "found: " + response, spoken: "" 
      say description + " nicht eindeutig.", spoken: description + " habe ich mehrfach gefunden."
      request_completed
    else
      say description + " nicht gefunden.", spoken: description + " konnte ich leider nicht finden."
      request_completed
    end
  end

  def hm_get_config
    # kann dauern...
    Thread.new do
      url = @hm_url + "devicelist.cgi"
      puts "[Info - Plugin Homematic] requesting Devices"
      xml_data = Net::HTTP.get_response(URI.parse(url)).body
      puts "[Info - Plugin Homematic] received Devices"
      data = XmlSimple.xml_in(xml_data)
      data['device'].each do |item|
        item['channel'].each do |channel|
          case channel['type']
            when "26","27","36"
            $hm_channels[channel['name']] = channel['ise_id']
          end
        end
      end
      url = @hm_url + "programlist.cgi"
      puts "[Info - Plugin Homematic] requesting Programs"
      xml_data = Net::HTTP.get_response(URI.parse(url)).body
      puts "[Info - Plugin Homematic] received Programs"
      data = XmlSimple.xml_in(xml_data)
      data['program'].each do |item|
          $hm_programs[item['name']] = item['id']
      end
      url = @hm_url + "sysvarlist.cgi"
      puts "[Info - Plugin Homematic] requesting Sysvars"
      xml_data = Net::HTTP.get_response(URI.parse(url)).body
      puts "[Info - Plugin Homematic] received Sysvars"
      data = XmlSimple.xml_in(xml_data)
      data['systemVariable'].each do |item|
          $hm_sysvars[item['name']] = item['ise_id']
      end    
    end
  end

  def hm_statechange(id, value, text="Ok.", voice="")
    url = @hm_url + "statechange.cgi?ise_id=" + id + "&new_value=" + value
    say "command: statechange ise_id=" + id + " new_value=" + value, spoken: ""
    result = Net::HTTP.get_response(URI.parse(url)).body
    say text, spoken: voice
    request_completed
  end

  def hm_runprogram(id, text="Ok.", voice="")
    url = @hm_url + "runprogram.cgi?ise_id=" + id
    say url, spoken: ""
    result = Net::HTTP.get_response(URI.parse(url)).body
    say text, spoken: voice
    request_completed
  end

end
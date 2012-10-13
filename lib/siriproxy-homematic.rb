# -*- encoding : utf-8 -*-

#######
#
#   Siriproxy Homematic Plugin Version 0.1
#   10'2012 basti, hobbyquaker@gmail.com
#
#
######

require 'cora'
require 'siri_objects'
require 'pp'
require 'net/http'
require 'xmlsimple'

class SiriProxy::Plugin::Homematic < SiriProxy::Plugin
  def initialize(config = {})
    @hm_url = "http://" + config['ccu_ip'] + "/config/xmlapi/"
    if !$hm_channels
      $hm_channels = Hash.new
      $hm_programs = Hash.new
      $hm_sysvars = Hash.new
      $hm_valuelist = Hash.new
      hm_get_config
    end
  end

  # Schalt-, Dimm-, und Rollladen-Aktoren steuern
  listen_for /(licht|rollladen|markise|steckdose|stromkreis|beleuchtung|lampe|lampen|lichter) ([a-zäöüß ]+) (auf|zu|öffnen|schließen|abschalten|anschalten|ausschalten|aktivieren|deaktivieren|an|aus|[0-9]+ %)/i  do |type,description,value|  #Syntaxhighlighting kaputt)
    response = "parsed: type=switch/dimmer/shutter description=" + type + " " + description + " value=" + value
    say response, spoken: ""
    case value.downcase
      when "an", "auf", "öffnen", "aktivieren", "anschalten"
        value = "1"
      when "aus", "zu", "schließen", "deaktivieren", "abschalten", "ausschalten"
        value = "0"
      else
        value = value.to_f / 100
        value = "%.2f" % value
    end
    search = description.downcase.strip
    result = $hm_channels.keys.grep(/#{search}/i)
    if result.size > 1
      result2 = $hm_channels.keys.grep(/#{type} #{search}/i) 
      if result.size2 == 1
        reusult = result2
      end
    end
    if result.size == 1
      response = "found: " + result[0]
      say response, spoken: ""
      hm_statechange $hm_channels[result[0]], value
      say "Befehl an Zentrale gesendet.", spoken: "Ok."
      request_completed
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
  listen_for /(automatik|haus) ([a-zäöüß ]+)/i  do |type,description|
    response = "parsed: type=runprogram description=" + description
    say response, spoken: ""
    search = description.downcase.strip
    result = $hm_programs.keys.grep(/#{search}/i)
    if result.size == 1
      response = "found: " + result[0]
      say response, spoken: ""
      hm_runprogram $hm_programs[result[0]]
      say "Befehl an Zentrale gesendet.", spoken: "Ok."
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

  # Variablen abfragen
  listen_for /(status) ([a-zäöüß ]+)/i do |type,description|
    response = "parsed: type=status description=" + description
    say response, spoken: ""
    search = description.downcase.strip
    result = $hm_sysvars.keys.grep(/#{search}/i)
    if result.size == 1
      response = "found: " + result[0]
      say response, spoken: ""
      response = hm_sysvar_value $hm_sysvars[result[0]]
      say response.to_s
      request_completed
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
      url = @hm_url + "sysvarlist.cgi?text=true"
      puts "[Info - Plugin Homematic] requesting Sysvars"
      xml_data = Net::HTTP.get_response(URI.parse(url)).body
      puts "[Info - Plugin Homematic] received Sysvars"
      data = XmlSimple.xml_in(xml_data)
      data['systemVariable'].each do |item|
          $hm_sysvars[item['name']] = item['ise_id']
          $hm_valuelist[item['name']] = item['value_list']
      end
      puts $hm_sysvars
      puts $hm_valuelist
    end
  end

  def hm_statechange(id, value)
    url = @hm_url + "statechange.cgi?ise_id=" + id + "&new_value=" + value
    say "command: statechange ise_id=" + id + " new_value=" + value, spoken: ""
    result = Net::HTTP.get_response(URI.parse(url)).body
  end

  def hm_sysvar_value(id)
    url = @hm_url + "sysvar.cgi?ise_id=" + id
    say "command: sysvar ise_id=" + id, spoken: ""
    xml_data = Net::HTTP.get_response(URI.parse(url)).body
    data = XmlSimple.xml_in(xml_data)
    puts data
    puts data['systemVariable'][0]
    if data['systemVariable'][0]['value_text'] != ""
      result = data['systemVariable'][0]['value_text']
    else 
      result = data['systemVariable'][0]['value']
    end
    response = "result: value=" + result
    say response, spoken: ""
    return result
  end

  def hm_runprogram(id)
    url = @hm_url + "runprogram.cgi?ise_id=" + id
    say "command: runprogram ise_id=" + id, spoken: ""
    result = Net::HTTP.get_response(URI.parse(url)).body
  end

end
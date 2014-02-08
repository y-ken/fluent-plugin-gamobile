fluent-plugin-gamobile, a plugin for [Fluentd](http://fluentd.org)
=====================

## Component
Fluentd Output plugin to send access report with "Google Analytics for mobile".

## Installation

### native gem
`````
gem install fluent-plugin-gamobile
`````

### td-agent gem
`````
/usr/lib64/fluent/ruby/bin/fluent-gem install fluent-plugin-gamobile
`````

## Configuration

### Sample
Please setup "gem install fluent-plugin-rewrite-tag-filter" before trying this sample.
`````
<source>
  type tail
  path /var/log/httpd/access_log
  format /^(?<domain>[^ ]*) (?<host>[^ ]*) [^ ]* (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^ ]*) +\S*)?" (?<status>[^ ]*) (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)" (?<response_time>[^ ]*))?$/
  time_format %d/%b/%Y:%H:%M:%S %z
  tag td.apache.access
  pos_file /var/log/td-agent/apache_access.pos
</source>

<match td.apache.access>
  type copy
  <store>
    type rewrite_tag_filter
    rewriterule1 agent (spider|bot|crawler|\+http\:) apache.access.robot
  </store>
</match>

<match apache.access.robot>
  type gamobile
  ga_account       MO-12345678-1
  # toggle logger mode
  development      yes           # Optional (default: no)
  # set UserVar from record
  set_var          agent         # Optional
  # treat same user these keys are same.
  unique_ident_key host,agent  # Optional
  # mapping internal name with record
  map_domain       domain        # Optional (default: domain)
  map_remoteaddr   host          # Optional (default: host)
  map_path         path          # Optional (default: path)
  map_referer      referer       # Optional (default: referer)
  map_useragent    agent         # Optional (default: agent)
  map_guid         guid          # Optional (default: guid)
  map_acceptlang   lang          # Optional (default: lang)
</match>
`````

## Use Case
* track crawler access activity
* track internal api access activity

## Backend Service
http://www.google.com/intl/ja/analytics/

## TODO
patches welcome!

## Copyright
Copyright © 2012- Kentaro Yoshida (@yoshi_ken)

## License
Apache License, Version 2.0


fluent-plugin-gamobile [![Build Status](https://travis-ci.org/y-ken/fluent-plugin-gamobile.png?branch=master)](https://travis-ci.org/y-ken/fluent-plugin-gamobile)
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
  format apache2
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
  map_dh           domain
  map_remoteaddr   host
  map_dp           path
  map_referer      referer
  map_useragent    agent
</match>
`````

## Use Case
* track crawler access activity
* track internal api access activity

## Backend Service
http://www.google.com/intl/ja/analytics/
https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters?hl=ja

## TODO
patches welcome!

## Copyright
Copyright © 2012- Kentaro Yoshida (@yoshi_ken)

## License
Apache License, Version 2.0

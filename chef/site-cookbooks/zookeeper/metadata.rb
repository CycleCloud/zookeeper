name             'zookeeper'
maintainer       'Cycle Computing LLC'
maintainer_email 'bryan.berry@cyclecoputing.com'
license          'All rights reserved'
description      'Installs/Configures zookeeper'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

%w{ thunderball cyclecloud cycle-stunnel }.each {|ckbk| depends ckbk }

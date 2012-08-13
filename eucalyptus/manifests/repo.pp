# This class sets up the repos for Eucalyptus and dependencies. 
#
# == Parameters
#
# [*version*] The version of Eucalyptus we are installing. Defaults to 3.1.
#
# == Authors
#
# Teyo Tyree <teyo@puppetlabs.com\>
# David Kavanagh <david.kavanagh@eucalyptus.com\>
# Tom Ellis <tom.ellis@eucalyptus.com\>
# Olivier Renault <olivier.renault@eucalyptus.com\>
#
# == Copyright
#
# Copyright 2012 Eucalyptus INC under the Apache 2.0 license
#

class eucalyptus::repo {
  # Check which OS we are installing on
  case $operatingsystem  {
    # there should a way to distinguish 
    redhat, centos : {
      yumrepo { "Eucalyptus-repo":
        name    => "eucalyptus",
        descr   => "Eucalyptus Repository",
        enabled => 1,
        baseurl => "http://downloads.eucalyptus.com/software/eucalyptus/3.1/rhel/\$releasever/\$basearch",
        gpgkey  => "http://www.eucalyptus.com/sites/all/files/c1240596-eucalyptus-release-key.pub",
      }
      yumrepo { "Euca2ools-repo":
        name    => "euca2ools",
        descr   => "Euca2ools Repository",
        enabled => 1,
        baseurl => "http://downloads.eucalyptus.com/software/euca2ools/2.1/rhel/\$releasever/\$basearch",
        gpgkey  => "http://www.eucalyptus.com/sites/all/files/c1240596-eucalyptus-release-key.pub",
      }
    }
    ubuntu : {
      # Check which version of Ubuntu
      File{
        owner   => "root",
        group   => "root",
        mode    => 644,
      }
      file{"/etc/apt/sources.list.d/eucalyptus.list":
        content => "deb http://downloads.eucalyptus.com/software/eucalyptus/3.1/ubuntu ${lsbdistcodename} main\n",
      }
      file{"/etc/apt/sources.list.d/euca2ools.list":
        content => "deb http://downloads.eucalyptus.com/software/euca2ools/2.1/ubuntu $lsbdistcodename main\n",
      }
      file{"/tmp/c1240596-eucalyptus-release-key.pub":
        source => "puppet:///modules/eucalyptus/c1240596-eucalyptus-release-key.pub",
      }
      exec {"update-repo":
        command => "/usr/bin/apt-key add /tmp/c1240596-eucalyptus-release-key.pub; /usr/bin/apt-get update",
        onlyif => "/usr/bin/test -f /etc/apt/sources.list.d/euca2ools.list",
      }
    }
  }
}

class eucalyptus::extrarepo {
  case $operatingsystem  {
    centos, redhat : {
      # Install other repository required for Eucalyptus
      # Eucalyptus is keeping a copy of their repository RPM 
      # So we can install their repo package directly from Eucalyptus repo
      $repo_packages = ['elrepo-release', 'epel-release']
        package { $repo_packages:
          ensure  => latest,
          require => Class[eucalyptus::repo],
      }
    }
  }
} 

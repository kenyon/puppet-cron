# @summary This class wraps *cron::install* for ease of use
# @param service_name Can be set to define a different cron service name.
# @param package_name Can be set to install a different cron package.
# @param manage_package Can be set to disable package installation.
# @param manage_service Defines if puppet should manage the service.
# @param service_ensure Defines if the service should be running.
# @param service_enable Defines if the service should be enabled at boot.
# @param users_allow A list of users which are exclusively able to create, edit, display, or remove crontab files. Only used if manage_users_allow == true.
# @param users_deny A list of users which are prohibited from create, edit, display, or remove crontab files. Only used if manage_users_deny == true.
# @param manage_users_allow If the /etc/cron.allow should be managed.
# @param manage_users_deny If the /etc/cron.deny should be managed.
# @example
#  include cron
# @example
#  class { 'cron':
#    manage_package => false,
#  }
class cron (
  String[1]            $service_name,
  String[1]            $package_name,
  Boolean              $manage_package     = true,
  Boolean              $manage_service     = true,
  Cron::Service_ensure $service_ensure     = 'running',
  Cron::Service_enable $service_enable     = true,
  Cron::Package_ensure $package_ensure     = 'installed',
  Array[Cron::User]    $users_allow        = [],
  Array[Cron::User]    $users_deny         = [],
  Boolean              $manage_users_allow = false,
  Boolean              $manage_users_deny  = false,
) {
  contain 'cron::install'
  contain 'cron::service'

  Class['cron::install'] -> Class['cron::service']

  # Manage cron.allow and cron.deny
  if $manage_users_allow {
    file { '/etc/cron.allow':
      ensure  => file,
      mode    => '0644',
      owner   => 'root',
      group   => 0,
      content => epp('cron/users.epp', { 'users' => $users_allow }),
    }
  }

  if $manage_users_deny {
    file { '/etc/cron.deny':
      ensure  => file,
      mode    => '0644',
      owner   => 'root',
      group   => 0,
      content => epp('cron/users.epp', { 'users' => $users_deny }),
    }
  }

  # Create jobs from hiera

  $cron_job = lookup('cron::job', Optional[Hash], 'hash', {})
  $cron_job.each | String $t, Hash $params | {
    cron::job { $t:
      * => $params,
    }
  }

  $cron_job_multiple = lookup('cron::job::multiple', Optional[Hash], 'hash', {})
  $cron_job_multiple.each | String $t, Hash $params | {
    cron::job::multiple { $t:
      * => $params,
    }
  }

  $cron_hourly = lookup('cron::hourly', Optional[Hash], 'hash', {})
  $cron_hourly.each | String $t, Hash $params | {
    cron::hourly { $t:
      * => $params,
    }
  }

  $cron_daily = lookup('cron::daily', Optional[Hash], 'hash', {})
  $cron_daily.each | String $t, Hash $params | {
    cron::daily { $t:
      * => $params,
    }
  }

  $cron_weekly = lookup('cron::weekly', Optional[Hash], 'hash', {})
  $cron_weekly.each | String $t, Hash $params | {
    cron::weekly { $t:
      * => $params,
    }
  }

  $cron_monthly = lookup('cron::monthly', Optional[Hash], 'hash', {})
  $cron_monthly.each | String $t, Hash $params | {
    cron::monthly { $t:
      * => $params,
    }
  }
}

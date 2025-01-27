# Copyright 2014 RetailMeNot, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @summary Jenkins credentials via the CloudBees Credentials plugin
define jenkins::credentials (
  String $password,
  String $description               = 'Managed by Puppet',
  String $private_key_or_path       = '',
  Enum['present', 'absent'] $ensure = 'present',
  String $uuid                      = '',
) {
  include jenkins
  include jenkins::cli_helper

  Class['jenkins::cli_helper']
  -> Jenkins::Credentials[$title]
  -> Anchor['jenkins::end']

  case $ensure {
    'present': {
      jenkins::cli::exec { "create-jenkins-credentials-${title}":
        command => [
          'create_or_update_credentials',
          $title,
          "'${password}'",
          "'${uuid}'",
          "'${description}'",
          "'${private_key_or_path}'",
        ],
        unless  => "for i in \$(seq 1 ${jenkins::cli_tries}); do \$HELPER_CMD credential_info ${title} && break || sleep ${jenkins::cli_try_sleep}; done | grep ${title}", # lint:ignore:140chars
      }
    }
    'absent': {
      # XXX not idempotent
      jenkins::cli::exec { "delete-jenkins-credentials-${title}":
        command => [
          'delete_credentials',
          $title,
        ],
      }
    }
    default: {
      fail "ensure must be 'present' or 'absent' but '${ensure}' was given"
    }
  }
}

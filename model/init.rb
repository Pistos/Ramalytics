require 'm4dbi'

$dbh = DBI.connect(
  "DBI:#{Ramalytics.options.db.adapter}:#{Ramalytics.options.db.name}",
  Ramalytics.options.db.user,
  Ramalytics.options.db.password
)

require 'model/tld'
require 'model/domain'
require 'model/subdomain'
require 'model/subdomain_path'
require 'model/uri'
require 'model/hit'
require 'model/user'
require 'model/subdomain_access'
require 'model/referrer_sighting'

require 'model/referrer'

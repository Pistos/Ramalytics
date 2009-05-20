require 'm4dbi'

$dbh = DBI.connect(
  "DBI:#{Ramalytics.options.db.adapter}:#{Ramalytics.options.db.name}",
  Ramalytics.options.db.user,
  Ramalytics.options.db.password
)

require 'model/tld'
require 'model/domain'
require 'model/subdomain'
require 'model/uri'
require 'model/hit'

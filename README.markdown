## Ramalytics

### Rationale

Ramalytics is an attempt at a fresh, new approach to web analytics.
Specifically, it seeks to answer one simple, burning question:

    "What's new?"

Traditional web analytics buries you with an avalanche of data which, no doubt,
was interesting to you at *some* point in time in the past.  Yet, as the
novelty of your web stats wears off, the unflagging tenacity of your analyzer
does not.  Day after day, you stare at the same reports telling you the same
myriad of details, again and again.  "Yes," you cry, "I _know_ I get five
thousand referrals a week from Super Duper Search Engine[1]!  Tell me
something I _don't_ know!"

Enter Ramalytics.  Go ahead; use those other web analytics tools for mining
the usual stuff.  But if you simply want to know (or be notified about) the
juicy latest about your website, turn to Ramalytics.

Ramalytics was created in the same spirit as [Selfmarks](http://sm.purepistos.net),
that is: "Why blame third parties when you can blame yourself?"  Run and serve
your web analytics yourself, and when your tracking code slows down your site,
it's your own fault!  No guts, no glory, as they say.

### Requirements

Well, what can I say, I was a bit lazy whipping this project together, so I
just used all my familiar tools and technologies.

 * PostgreSQL
 * M4DBI
 * Ramaze
 * Ruby 1.9

### Installation

1. Ensure you have the Requirements installed.
2. Create your database and database user; name them whatever you like.
3. Copy config.rb.sample to config.rb and adjust to taste.
4. Execute schema.sql into your database.
5. Execute views.sql into your database.
6. Run start.rb with your version 1.9 ruby binary.  e.g. ruby19 start.rb
7. Insert this snippet before the closing </body> tag on every page or layout
you want to track on:
<script src="http://ram.purepistos.net/ramalytics.js"></script>
Of course, substitute the domain with your own.

[1]: # "Not an actual search engine.  I know you wanted to google that, but don't
bother."
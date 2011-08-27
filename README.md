Cardo
=====

Cardo is a DSL we created at Highgroove to create recurring stories in
Pivotal Tracker.

**It is currently the result of a spike, and doesn't quite function
exactly as you might expect. Furthermore, there are (as of yet) little
to no tests.**

Requirements
------------

* Ruby >= 1.9.x (developed with MRI 1.9.2)

Examples
--------

Given a file **highgroove.rb**:

```ruby
require 'rubygems'
require 'cardo'

Cardo.describe do
  WEEKLY_REVIEWER = 'Charles Brian Quinn'
  DEVELOPERS      = ['Andy Lindeman', 'Chris Kelly']
  BLOGGERS        = DEVELOPERS + ['Megan Key']

  # Tracker API key required
  # Can be copied from <https://www.pivotaltracker.com/profile>
  api_key ENV['API_KEY']

  project_id 123456

  pivot_day "Wednesday"

  weekly do
    feature "Weekly Review", estimate: 1,
                             labels:   'weekly-review',
                             owned_by: WEEKLY_REVIEWER

    feature "Team Lunch", estimate: 1,
                          labels:   'team-lunch'

    feature "Demo Day", estimate: 1,
                        labels:   'demo-day'

    random_pairing "Code Review of %s", DEVELOPERS, estimate: 1,
                                                    labels: 'code-review'

    random_pairing "Pair with %s", DEVELOPERS, estimate: 1,
                                               labels:   'pairings'

    random "Blog Post", BLOGGERS, estimate: 1,
                                  labels:   'blog-post'
  end
end
```

Create the stories with:

```bash
API_KEY='abc123' ruby highgroove.rb
```

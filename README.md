# redmine_sla

<div style=" width:480px; height:166px; " >

![Redmine SLA - Issue Patch](doc/images/redmine_sla_issue_patch.png)
</div>


## Overview

- Website: [https://github.com/likehopper/redmine_sla](https://github.com/likehopper/redmine_sla)
- Code repository: [git@github.com:likehopper/redmine_sla.git](git@github.com:likehopper/redmine_sla.git)
- Redmine plugins directory: [https://www.redmine.org/plugins/redmine_sla](https://www.redmine.org/plugins/redmine_sla)


### Digest

Redmine SLA plugin gives the possibility of managing service levels. 
It provides flexible configuration of calendars, times and terms.
It calculates types of response times for project trackers.


### Features

These are the features of this plugin :
- Definition at plugin level
  - SLA update step
  - SLA calculation time zone
  - SLA log level (but no log currently)
- Manage at the global administration ( with full API support )
  - SLAs
  - SLA Types
  - SLA Statuses
  - SLA Holidays
  - SLA Calendars withs SLA Schedules
  - SLA Calendars' Holidays
  - SLA Levels
  - SLA Terms
- Rights by rôles
  - Manage SLA in project
  - View SLA in issue ( with link to SLA Calendar & SLA Level )
  - And therefore the lack of access to SLAs
- At the project's configuration
  - Specifies SLA for each tracker
- For the issues
  - In list
    - Filter on SLAs
    - Viewing SLA Columns
  - In view
    - Summary by type
    - Responsive display
- For the time log
  - In list
    - Filter on SLAs
    - Viewing SLA Columns
- Tasks
  - Build fixture base on CSV file
  - Update SLA manualy or by crontab

### Localisations

- English
- French


### Todo

Here is a list of possible evolutions without prioritization :
- Time zone by projets 
- Ability to sort lists
- Have a corrector for a status log issue
- Clear cache completely or after a given date
- Mask SLA plugin columns and filters if module is disabled or user doesn't have access
- Improve display and editing week' schedules of calendars ( e.g. with [https://github.com/starsirius/day-schedule-selector.git](https://github.com/starsirius/day-schedule-selector.git) )
- Display of public holidays per year in nested ## form in calendars
- Ability to export and import all or part of each element
- Improve display and editing of terms in tabular form
- Propose schedule editions in a more graphical format
- Issues list groupable by SLA level or SLA respect
- Manage alert thresholds for sending notifications
- Add summary in the issues report
- Write functional tests

> **_NOTE:_** And many others: if you have ideas or time, don't hesitate to participate!


## Howto install / uninstall

### Prerequisites

| Name               | requirement                      |
|--------------------|----------------------------------|
| `Redmine`          | >= 5.0                           |
| `Ruby`             | >= 2.7                           |
| `Rails`            | >= 6.1                           |
| `Database`         | PostgreSQL >= 11                 |

> **_NOTE:_** It is important to note that, to calculate the SLAs, the plugin uses the features of Posgtres, including the Pl/Pgsql procedures. And for this, in `config/application.rb` file, **you must add this line `config.active_record.schema_format = :sql`** in `RedmineApp::Application section`.


> **_REMINDER:_** Make sure your database datestyle is set to ISO (Postgresql default setting). You can set it using: ALTER DATABASE "redmine_db" SET datestyle="ISO,MDY".

> **_TIP:_** Prefer the global configuration of the time zone on "Etc/UTC" ( and with `config.active_record.default_timezone = :local` in `RedmineApp::Application` section of `config/application.rb` file ).

### Install

1. Download plugin and copy plugin folder redmine_sla go to Redmine's plugins folder
2. Goto redmine root folder to install necessary gems with `bundle install`
3. Launch install plugin to create tables, functions and view `rake redmine:plugins:migrate NAME=redmine_sla`
4. Restart your application server (apache with passenger, nginx with passenger, unicorn, puma, etc.) and Additionals is ready to use.

More information about installation of Redmine plugins, you can find in the official [Redmine plugin documentation](https://www.redmine.org/projects/redmine/wiki/Plugins).


### Uninstall

1. Launch uninstall plugin to drop tables, functions and view `rake redmine:plugins:migrate NAME=redmine_sla VERSION=0`
2. Go to plugins folder, delete plugin folder redmine_sla `rm -r redmine_more_previews`
3. restart server f.i. `sudo /etc/init.d/apache2 restart`


## More informations

- [Functional tests](doc/TESTING.md)
- [Conceptual Data Model](doc/MCD.md)
- [Step-by-step use case](doc/USECASE.md)
  - [Example 01](doc/EXAMPLE-01.md) ( and API implementation [Script Example 01](doc/scripts/EXAMPLE-01.bash) )
  - [Example 02](doc/EXAMPLE-02.md) ( and API implementation [Script Example 02](doc/scripts/EXAMPLE-02.bash) )
  - [Example 03](doc/EXAMPLE-03.md) ( and API implementation [Script Example 03](doc/scripts/EXAMPLE-03.bash) )
- [SLA Compute Explanation](doc/COMPUTE.md)
- [Plugin settings](doc/SETTINGS.md)
- [API Rest for SLA](doc/API.md)
- [Tasks](doc/TASKS.md)
- [Change log](CHANGELOG.md)
- [License](LICENSE)


### sources / thanks

- [Icons created by Freepik - Flaticon](https://www.flaticon.com/authors/freepik)

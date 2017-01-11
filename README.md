# Solaris Performance Analytics

## Web Interface

### PA Server
A connection to a PA Server must be made before you can select from the list of available hosts, and view any available performance visualizations.

### Host
A list of all hosts that performance metrics have been collected for can be selected from.

### Date / Date Range
Once the host has been selected, a single date or date range can be selected out of those for which any metric has been collected.  **NOTE**: Just because a date is available doesn't mean that *all* metrics have been collected for that date.

### Categories
There are several categories of performance metrics that can be collected.  At present, the list of categories is:

* CPU
* Memory
* Filesystem
* Network
* Stacks

### Metrics
Once a category has been selected, the associated metrics list for it is displayed.  At present, the list of available Category / Metric mappings is:

* CPU
* Memory
    * memstat
    * VM scan rate
    * freemem
* Filesystem
* Network
* Stacks
  * Kernel Stacks

### Visualization
The visualization for the selected Host => Date Range => Category => Metric is displayed here.

## Catalyst Web Server

### REST APIs

## PA Database Back-End

### DBIx::Class ResultSet access to Database

## Dev vs Prod

## PA Client Host Scripts

## PA Client Web Interface



## PA RabbitMQ Publish/Subscribe


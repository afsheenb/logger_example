#!/usr/bin/env python
import sys, psycopg2
import datetime
import time
import os

while True:
    cs = "dbname=adminui user=ozone password=%s host=%s port=5432" % (os.environ['DB_PASS'], os.environ['DB_HOST'])
    conn = psycopg2.connect(cs)
    cur = conn.cursor()
    ## Create CSV of page names, inbound placement ids, and new ids to swap to - appnexus
    apn_mappings_sql = "COPY (select p.page,m.dmp,m.ingress,m.egress,u.id,p.email from pages p left join users u on p.email = u.email left join mappings m on u.id=m.user_id where m.dmp='AppNexus' and m.Enabled='Active') TO STDOUT WITH CSV DELIMITER ','"
    with open("/usr/src/ozone/prebid-server/static/mappings/appnexus_mappings.csv", "w") as file:
            cur.copy_expert(apn_mappings_sql, file)
    ## Create CSV of page names, inbound unit ids, and new ids to swap to - OpenX
    ox_mappings_sql = "COPY (select p.page,m.dmp,m.ingress,m.egress,u.id,p.email from pages p left join users u on p.email = u.email left join mappings m on u.id=m.user_id where m.dmp='OpenX' and m.Enabled='Active') TO STDOUT WITH CSV DELIMITER ','"
    with open("/usr/src/ozone/prebid-server/static/mappings/openx_mappings.csv", "w") as file:
            cur.copy_expert(ox_mappings_sql, file)
    ## Create CSV of netblocks to filter access from
    netblocks_sql = "COPY (select p.page,n.netblock,u.id,p.email from pages p left join users u on p.email = u.email left join netblocks n on u.id=n.user_id where n.Enabled='Enabled') TO STDOUT WITH CSV DELIMITER ','"
    with open("/usr/src/ozone/prebid-server/static/netblocks.csv", "w") as file:
            cur.copy_expert(netblocks_sql, file)
    ## Create CSV of countries to filter access from
    geoblocks_sql = "COPY (select p.page,g.country,u.id,p.email from pages p left join users u on p.email = u.email left join geoblocks g on u.id=g.user_id where g.Enabled='Enabled') TO STDOUT WITH CSV DELIMITER ','"
    with open("/usr/src/ozone/prebid-server/static/geoblocks.csv", "w") as file:
            cur.copy_expert(geoblocks_sql, file)
    ## Create CSV of page names, partners, and status
    # Note the logic change - we care about rules that have been enabled and partners that have been 
    # *disabled*!
    partners_sql = "COPY (select p.page,d.partner,u.id,p.email from pages p left join users u on p.email = u.email left join partners d on u.id=d.user_id where d.Enabled='Inactive') TO STDOUT WITH CSV DELIMITER ','"
    with open("/usr/src/ozone/prebid-server/static/partners.csv", "w") as file:
            cur.copy_expert(partners_sql, file)
    cur.close()
    print ("Last pulled configuration from admin database at", str(datetime.datetime.now()))
    time.sleep(60)

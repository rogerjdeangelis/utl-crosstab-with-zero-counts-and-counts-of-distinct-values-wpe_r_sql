%let pgm=utl-crosstab-with-zero-counts-and-counts-of-distinct-values-wpe_r_sql;

Crosstab with zero counts and counts of distinct values proc freq and sql

Would be nice if we had a simpler solution

github
https://tinyurl.com/2r9fez23
https://github.com/rogerjdeangelis/utl-crosstab-with-zero-counts-and-counts-of-distinct-values-wpe_r_sql

Problem

  Count distinct miieages by number of carburators for cyinders=8 but include the 0 counts for
  8 and 6 cylinder vehicles that do nay have mileage data (set counts to 0)

  I can do this with two proc summaries. two proc freqs(spares) or one complex proc summary (completetypes).
  I need an output datset. Maybe a sinple Hash/Tabulate/Report.

  Pretty sure it can be down with a dow loop or dosubl to sql.

I have never been able to simplify this problem maybe the sas-l brain trust can

https://stackoverflow.com/questions/76900184/use-a-filter-within-n-distinct-while-using-sym

     SOLUTIONS

          1 wps sql
          2 wps r solution by (there is a longer secon solution)
            https://stackoverflow.com/users/2372064/mrflick
          3 wps proc sql
          4 wps proc python

/**************************************************************************************************************************/
/*                              |                               |                                           |             */
/* SD1.HAVE total obs=32        |  STEP 1                       |  Step 2 Join and count                    | OUTPUT      */
/*                              |                               |                                           |             */
/* Obs     MPG    CYL    CARB   |  SQL LIST ALL CARB Values     |  proc sql;                                |      Unique */
/*                              |  WE NEED THIS FOR 0 counts    |    create                                 | CARB Mileage*/
/*   1    21.0     6       4    |                               |       table sd1.want as                   |             */
/*   2    21.0     6       4    |  select                       |    select                                 |    1     0  */
/*   3    22.8     4       1    |     distinct carb as unqcarb  |       l.carb                              |    2     4  */
/*   4    21.4     6       1    |  from                         |      ,count(distinct r.mpg) as unqMpg     |    3     3  */
/*   5    18.7     8       2    |     sd1.have                  |    from                                   |    4     5  */
/*   6    18.1     6       1    |  group                        |       allCmb as l left join sd1.have as r |    6     0  */
/*   7    14.3     8       4    |     by carb                   |    on                                     |    8     1* */
/*   8    24.4     4       2    |                               |           l.carb = r.carb                 |             */
/*   9    22.8     4       2    |                               |       and l.cyl  = r.cyl                  | Distinct    */
/*  10    19.2     6       4    | Need this for 0 counts        |       and l.count ne 0                    | Mileage by  */
/*  11    17.8     6       4    | of distinct mileage           |    group                                  | Carburator  */
/*  12    16.4     8       3    |                               |       by l.carb                           | Note 0's    */
/*  13    17.3     8       3    |                               |  ;quit;                                   | for 8       */
/*  14    15.2     8       3    |                               |                                           | cylinders   */
/*  15    10.4     8       4    |                               |                                           |             */
/*  16    10.4     8       4    |  unCarb for all cylinders     |                                           |             */
/*  17    14.7     8       4    |  -------                      |                                           |             */
/*  18    32.4     4       1    |        1                      |                                           |             */
/*  19    30.4     4       2    |        2                      |                                           |             */
/*  20    33.9     4       1    |        3                      |                                           |             */
/*  21    21.5     4       1    |        4                      |                                           |             */
/*  22    15.5     8       2    |        6                      |                                           |             */
/*  23    15.2     8       2    |        8                      |                                           |             */
/*  24    13.3     8       4    |                               |                                           |             */
/*  25    19.2     8       2    |                               |                                           |             */
/*  26    27.3     4       1    |                               |                                           |             */
/*  27    26.0     4       2    |                               |                                           |             */
/*  28    30.4     4       2    |                               |                                           |             */
/*  29    15.8     8       4    |                               |                                           |             */
/*  30    19.7     6       6    |                               |                                           |             */
/*                              |                               |                                           |             */
/* *31    15.0     8       8 --Only one mileage for 8 cylinder  |                                           |             */
/*                             and  8 carburators               |                                           |             */
/*  32    21.4     4       2    |                               |                                           |             */
/*                              |                               |                                           |             */
/**************************************************************************************************************************/





/*                                  _
/ | __      ___ __  ___   ___  __ _| |
| | \ \ /\ / / `_ \/ __| / __|/ _` | |
| |  \ V  V /| |_) \__ \ \__ \ (_| | |
|_|   \_/\_/ | .__/|___/ |___/\__, |_|
             |_|                 |_|
*/

proc datasets lib=sd1 nolist nodetails;delete want; run;quit;

%utl_submit_wps64('
libname sd1 "d:/sd1";
options validvarname=any;
proc sql;
  create
     table sd1.want as
  select
     l.carb
    ,count(distinct r.mpg) as unqMpg
  from (
     select
       distinct carb
     from
        sd1.have ) as l left join (
     select
        carb
       ,cyl
       ,mpg
     from
        sd1.have
     where
        cyl = 8 ) as r
  on
     l.carb = r.carb
  group
     by l.carb
;quit;
proc print;
run;quit;
');

/**************************************************************************************************************************/
/*                                                                                                                        */
/* The WPS System                                                                                                         */
/*                                                                                                                        */
/*                unq                                                                                                     */
/* Obs    CARB    Mpg                                                                                                     */
/*                                                                                                                        */
/*  1       1      0                                                                                                      */
/*  2       2      4                                                                                                      */
/*  3       3      3                                                                                                      */
/*  4       4      5                                                                                                      */
/*  5       6      0                                                                                                      */
/*  6       8      1                                                                                                      */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*___
|___ \  __      ___ __  ___   _ __  _ __ ___   ___   _ __
  __) | \ \ /\ / / `_ \/ __| | `_ \| `__/ _ \ / __| | `__|
 / __/   \ V  V /| |_) \__ \ | |_) | | | (_) | (__  | |
|_____|   \_/\_/ | .__/|___/ | .__/|_|  \___/ \___| |_|
                 |_|         |_|
*/

proc datasets lib=sd1 nolist nodetails;delete want; run;quit;

%utl_submit_wps64x('
libname sd1 "d:/sd1";
proc r;
submit;
library(dplyr);
my_var <- "mpg";
want <- mtcars %>%
  group_by(carb) %>%
  summarise(x = n_distinct(.data[[my_var]][cyl == 8]));
want;
endsubmit;
import data=sd1.want r=want;
run;quit;
proc print;
run;quit;
');

/**************************************************************************************************************************/
/*                                                                                                                        */
/* R                                                                                                                      */
/*                                                                                                                        */
/* The WPS System                                                                                                         */
/*                                                                                                                        */
/* # A tibble: 6 x 2                                                                                                      */
/*    carb     x                                                                                                          */
/*                                                                                                                        */
/* 1     1     0                                                                                                          */
/* 2     2     4                                                                                                          */
/* 3     3     3                                                                                                          */
/* 4     4     5                                                                                                          */
/* 5     6     0                                                                                                          */
/* 6     8     1                                                                                                          */
/*                                                                                                                        */
/* WPS                                                                                                                    */
/*                                                                                                                        */
/* The WPS System                                                                                                         */
/*                                                                                                                        */
/* bs    CARB    X                                                                                                        */
/*                                                                                                                        */
/* 1       1     0                                                                                                        */
/* 2       2     4                                                                                                        */
/* 3       3     3                                                                                                        */
/* 4       4     5                                                                                                        */
/* 5       6     0                                                                                                        */
/* 6       8     1                                                                                                        */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*____                                                         _
|___ /  __      ___ __  ___   _ __  _ __ ___   ___   ___  __ _| |
  |_ \  \ \ /\ / / `_ \/ __| | `_ \| `__/ _ \ / __| / __|/ _` | |
 ___) |  \ V  V /| |_) \__ \ | |_) | | | (_) | (__  \__ \ (_| | |
|____/    \_/\_/ | .__/|___/ | .__/|_|  \___/ \___| |___/\__, |_|
                 |_|         |_|                            |_|
*/

proc datasets lib=sd1 nolist nodetails;delete want; run;quit;

%utl_submit_wps64('
libname sd1 "d:/sd1";
proc r;
export data=sd1.have r=have;
submit;
library(sqldf);
want <-sqldf("
   select
     l.carb
    ,count(distinct r.mpg) as unqMpg
  from (
     select
       distinct carb
     from
        have ) as l left join (
     select
        carb
       ,cyl
       ,mpg
     from
        have
     where
        cyl = 8 ) as r
  on
     l.carb = r.carb
  group
     by l.carb
  ");
want;
endsubmit;
import r=want data=sd1.want;
run;quit;
');

/*  _                                                            _   _
| || |   __      ___ __  ___   _ __  _ __ ___   ___  _ __  _   _| |_| |__   ___  _ __
| || |_  \ \ /\ / / `_ \/ __| | `_ \| `__/ _ \ / __|| `_ \| | | | __| `_ \ / _ \| `_ \
|__   _|  \ V  V /| |_) \__ \ | |_) | | | (_) | (__ | |_) | |_| | |_| | | | (_) | | | |
   |_|     \_/\_/ | .__/|___/ | .__/|_|  \___/ \___|| .__/ \__, |\__|_| |_|\___/|_| |_|
                  |_|         |_|                   |_|    |___/
*/

 %utl_submit_wps64x('

libname sd1 "d:/sd1";
proc datasets lib=sd1 nolist nodetails;delete want; run;quit;

proc python;
export data=sd1.have python=have;
submit;
 from os import path;
 import pandas as pd;
 import numpy as np;
 from pandasql import sqldf;
 mysql = lambda q: sqldf(q, globals());
 from pandasql import PandaSQL;
 pdsql = PandaSQL(persist=True);
 sqlite3conn = next(pdsql.conn.gen).connection.connection;
 sqlite3conn.enable_load_extension(True);
 sqlite3conn.load_extension("c:/temp/libsqlitefunctions.dll");
 mysql = lambda q: sqldf(q, globals());
 want=pdsql("""
  select
     l.carb
    ,count(distinct r.mpg) as unqMpg
  from (
     select
       distinct carb
     from
        have ) as l left join (
     select
        carb
       ,cyl
       ,mpg
     from
        have
     where
        cyl = 8 ) as r
  on
     l.carb = r.carb
  group
     by l.carb
 """);
print(want);
endsubmit;
import data=sd1.want python=want;
run;quit;
proc print data=sd1.want;
run;quit;
');

/**************************************************************************************************************************/
/*                                                                                                                        */
/* PYTHOON                                                                                                                */
/*                                                                                                                        */
/* The WPS System                                                                                                         */
/*                                                                                                                        */
/* The PYTHON Procedure                                                                                                   */
/*                                                                                                                        */
/*    carb  unqMpg                                                                                                        */
/* 0   1.0       0                                                                                                        */
/* 1   2.0       4                                                                                                        */
/* 2   3.0       3                                                                                                        */
/* 3   4.0       5                                                                                                        */
/* 4   6.0       0                                                                                                        */
/* 5   8.0       1                                                                                                        */
/*                                                                                                                        */
/* WPS                                                                                                                    */
/*                                                                                                                        */
/* Obs    CARB    UNQMPG                                                                                                  */
/*                                                                                                                        */
/*  1       1        0                                                                                                    */
/*  2       2        4                                                                                                    */
/*  3       3        3                                                                                                    */
/*  4       4        5                                                                                                    */
/*  5       6        0                                                                                                    */
/*  6       8        1                                                                                                    */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/

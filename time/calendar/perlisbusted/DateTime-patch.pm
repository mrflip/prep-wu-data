--- DateTime.pm	2007-09-10 10:41:27.000000000 -0500
+++ DateTime-fix.pm	2007-12-01 12:13:37.037559308 -0600
@@ -509,13 +509,21 @@
         # on the given value.  If the object _is_ on a leap second, we'll
         # add that to the generated seconds value later.
         my $leap_seconds = 0;
-        if ( $object->can('time_zone') && ! $object->time_zone->is_floating
+
+	if ( $object->can('time_zone') ) {
+	    my $tz = 
+		( ref $object->time_zone ?
+		  $object->time_zone :
+		  DateTime::TimeZone->new( name => $object->time_zone )
+		);
+
+	    if ( ! $tz->is_floating
              && $rd_secs > 86399 && $rd_secs <= $class->_day_length($rd_days) )
         {
             $leap_seconds = $rd_secs - 86399;
             $rd_secs -= $leap_seconds;
         }
-
+	}
         my %args;
         @args{ qw( year month day ) } = $class->_rd2ymd($rd_days);
         @args{ qw( hour minute second ) } =

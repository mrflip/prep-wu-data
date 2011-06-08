Chronic
=======

## DESCRIPTION

Chronic is a natural language date/time parser written in pure Ruby. See below
for the wide variety of formats Chronic will parse.


## INSTALLATION

The best way to install Chronic is with RubyGems:

    $ [sudo] gem install chronic


## USAGE

You can parse strings containing a natural language date using the
Chronic.parse method.

    require 'rubygems'
    require 'chronic'

    Time.now   #=> Sun Aug 27 23:18:25 PDT 2006

    #---

    Chronic.parse('tomorrow')
      #=> Mon Aug 28 12:00:00 PDT 2006

    Chronic.parse('monday', :context => :past)
      #=> Mon Aug 21 12:00:00 PDT 2006

    Chronic.parse('this tuesday 5:00')
      #=> Tue Aug 29 17:00:00 PDT 2006

    Chronic.parse('this tuesday 5:00', :ambiguous_time_range => :none)
      #=> Tue Aug 29 05:00:00 PDT 2006

    Chronic.parse('may 27th', :now => Time.local(2000, 1, 1))
      #=> Sat May 27 12:00:00 PDT 2000

    Chronic.parse('may 27th', :guess => false)
      #=> Sun May 27 00:00:00 PDT 2007..Mon May 28 00:00:00 PDT 2007

## DETAILED USAGE

Parses a string containing a natural language date or time. If the parser
can find a date or time, either a Time or Chronic::Span will be returned
(depending on the value of <tt>:guess</tt>). If no date or time can be found,
+nil+ will be returned.

Options are:

      default_options = {
        :context              => :future,
        :now                  => Chronic.time_class.now,
        :guess                => true,
        :ambiguous_time_range => 6
        }

* [<tt>:context</tt>]
  <tt>:past</tt> or <tt>:future</tt> (defaults to <tt>:future</tt>)

  If your string represents a birthday, you can set <tt>:context</tt> to <tt>:past</tt>
  and if an ambiguous string is given, it will assume it is in the
  past. Specify <tt>:future</tt> or omit to set a future context.

* [<tt>:now</tt>]
  Time (defaults to Time.now)

  By setting <tt>:now</tt> to a Time, all computations will be based off
  of that time instead of Time.now. If set to nil, Chronic will use Time.now.

* [<tt>:guess</tt>]
  +true+ or +false+ (defaults to +true+)

  By default, the parser will guess a single point in time for the
  given date or time. If you'd rather have the entire time span returned,
  set <tt>:guess</tt> to +false+ and a Chronic::Span will be returned.

* [<tt>:ambiguous_time_range</tt>]
  Integer or <tt>:none</tt> (defaults to <tt>6</tt> (6am-6pm))

  If an Integer is given, ambiguous times (like 5:00) will be
  assumed to be within the range of that time in the AM to that time
  in the PM. For example, if you set it to <tt>7</tt>, then the parser will
  look for the time between 7am and 7pm. In the case of 5:00, it would
  assume that means 5:00pm. If <tt>:none</tt> is given, no assumption
  will be made, and the first matching instance of that time will
  be used.


## EXAMPLES

Chronic can parse a huge variety of date and time formats. Following is a
small sample of strings that will be properly parsed. Parsing is case
insensitive and will handle common abbreviations and misspellings.

Simple

* thursday
* november
* summer
* friday 13:00
* mon 2:35
* 4pm
* 6 in the morning
* friday 1pm
* sat 7 in the evening
* yesterday
* today
* tomorrow
* this tuesday
* next month
* last winter
* this morning
* last night
* this second
* yesterday at 4:00
* last friday at 20:00
* last week tuesday
* tomorrow at 6:45pm
* afternoon yesterday
* thursday last week

Complex

* 3 years ago
* 5 months before now
* 7 hours ago
* 7 days from now
* 1 week hence
* in 3 hours
* 1 year ago tomorrow
* 3 months ago saturday at 5:00 pm
* 7 hours before tomorrow at noon
* 3rd wednesday in november
* 3rd month next year
* 3rd thursday this september
* 4th day last week

Specific Dates

* January 5
* dec 25
* may 27th
* October 2006
* oct 06
* jan 3 2010
* february 14, 2004
* 3 jan 2000
* 17 april 85
* 5/27/1979
* 27/5/1979
* 05/06
* 1979-05-27
* Friday
* 5
* 4:00
* 17:00
* 0800

Specific Times (many of the above with an added time)

* January 5 at 7pm
* 1979-05-27 05:00:00
* etc


## TIME ZONES

Chronic allows you to set which Time class to use when constructing times. By
default, the built in Ruby time class creates times in your system's local
time zone. You can set this to something like ActiveSupport's TimeZone class
to get full time zone support.

    >> Time.zone = "UTC"
    >> Chronic.time_class = Time.zone
    >> Chronic.parse("June 15 2006 at 5:45 AM")
    => Thu, 15 Jun 2006 05:45:00 UTC +00:00


## LIMITATIONS

Chronic uses Ruby's built in Time class for all time storage and computation.
Because of this, only times that the Time class can handle will be properly
parsed. Parsing for times outside of this range will simply return nil.
Support for a wider range of times is planned for a future release.

## CREDITS:

This call is an HTTP facade for @mojombo's chronic:

http://github.com/github/chronic

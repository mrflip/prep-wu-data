If you don't mind, the easiest thing for me is going to be to use github to share scripts, etc back and forth.  Only thing is we have to be a bit careful with diskspace, just to make sure to not import data files (only scripts).

I don't know how comfortable you are sharing your scripts to process the MLB gameday info. Anything that goes into a free github account is visible to the world, so if you want to keep that separate we can talk about the options for doing that.

I'd also like, if you don't mind, to impose my somewhat fussy directory tree on you: we might as well have somewhat compatible dir structures and workflow for passing scripts back & forth.  If you have improvements or alterations to make life easier for you please say.

The following structure has evolved so that I can keep datasets 'sustainable' -- that is, to be able to re-scrape or pull an update, re-run the scripts, and keep my sanity when doing so across thousands of datasets.  I keep ripped originals in one place organized by URL, then symlink into there from the working directory, but by the power of symlinks you can set the physical structure however you like.  So, whether by symlink or subdir, I have:

|
+ weather/ncdc/hourly
  |
  +- (...)                scripts, output, graphics, writeup, etc.
  +- (...)                this is the stuff that's versioned by git; none of the following is.
  +- (...)                
  |
  +- ripd                 
      +- noaa             links into the ...ftp.ncdc.noaa.gov/pub/data/ directory
      +- inventories      
  |
  +- rawd
      +- noaa/2008        gunzipp'ed files from the corresponding ripd/ directory
      +- noaa/2007        ... note that this dir tree and ripd/ keep same structure
      +- noaa/...
  |
  +- temp                 any scratch space for intermediate files
  |
  +- fixd
      +- ???              this is where nice clean reconciled data goes
                          whether it's for sharing back on infochimps
                          or loading into mysql or whatever

  ---------------
  This here does only the chimpanzee work, and only for this one source, of 
  "extract/transform/load data into a generic form we can work with" (CSV 
  for us, into MySQL, with some YAML for glue, is what I like best).  
  ---------------
  Similarly, for the gameday, park info (and any other data *sources*):
  ---------------
|
+ sports/baseball/gameday
  |
  +- (...)                scripts, output, graphics, writeup, etc.
  +- (...)                that extract as much as I'd need of the gameday data
  +- (...)                to do any runs on the computer cluster that are needed
  +- (...)                I'm assuming this already has its own structure
  +- (...)                and there's no sense disrupting it
|
+ sports/baseball/ballparks
  |
  +- (...)                scripts, output, graphics, writeup, etc.
  +- (...)                
  +- ripd                 
  +- rawd
  +- temp
  +- fixd

  ---------------
  Now finally we get to do the fun stuff, drawing on all the data sources
  to actually do data analysis:
  ---------------

|
+ sports/baseball/baseball_weather
  |
  +- (...)                scripts, output, graphics, writeup, etc.
  +- (...)                
  |
  +- rawd                 pointers to the fixd (output) dirs of the various clean & reformat scripts
     +- ballparks         (which now become the inputs to analysis scripts)
     +- ncdc_hourly       -> the same dir as weather/ncdc/hourly/fixd/
     +- ...
  |
  +- temp
  |
  +- fixd                 any generated data files that are themselves interesting enough to share.
     +- ...

$stdout.reopen('foo.log')
$stderr.reopen('foo-error.log')
puts "hi mom"
warn "uh oh"

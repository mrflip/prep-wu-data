
def q_d text, delim=',', quote='"'
  "#{quote}#{text}#{quote}#{delim}"
end

def as_millions(f)
  '%3.1f'%[ f / 1_000_000.0] + 'M'
end

def round2(x)
  (x*100).round()/100.0
end

def round2_str(x, fmt=nil)
  x = x ? round2(x) : ''
  fmt ? (fmt % x) : x
end

def pct(num)
  number_to_percentage(100*num, :precision => 0)
end

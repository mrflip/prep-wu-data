
#
# Generate all pairs [i,j] from 0..n where i < j
def all_ordered_pairs(n)
  (0..n-1).inject([]) do |pairs,i| 
    array_of_i =  [i] * (n-i)             # i, repeated enough times
    array_gt_i = ( i+1 .. n ).to_a        # all the #s from i+1 up to n
    pairs + (array_of_i).zip(array_gt_i)  # transposed
  end
end

#
# For two list-adjacent cities i and j=i+1, 
# give a route that visits all edges from i or j to later cities x (x > i and x > j)
def traverse(i,n)
  return [] if i >= n
  j   = i + 1
  # all the rest of the cities, in pairs of two.
  rst = (j+1 .. n).to_a
  # make the pattern i j j+1 i j+2 j j+3 i j+4 ; pairwise this will exhaust the i and j rows
  # the conditional (y ? [] : []) is to handle (n.odd?) map{ |x,y| (y ? [x, i, y, j] : [x, i]) }.flatten
  trip = [i, j] + rst.zip([i,j] * (1+rst.length/2)).flatten
end

#
# given a journey and an edge list,
# returns all edges not traversed.
def check_traversal(edges, traversal)
  # let's go ahead and check our work: here's each edge in the traversal
  trip_pairs = traversal.most.zip(traversal.rest)
  # make a hash with each edge
  trip_left  = Hash.zip(edges, [false]*edges.length)
  # and tick it off as we see it.
  trip_pairs.each{ |p| trip_left.delete(p.sort) }
  trip_left.keys
end

# 
# break the trip into segments of size sz,
# but make the end city of the previous trip
# the start city of the next trip
def trip_break_into_segments(trip, sz)
  # this gives e.g. [ [1,2,3], [4,5,6], [7,8] ] (for trip=0..8 and sz=3)
  segs = trip.rest.in_groups_of(sz-1).map(&:compact)
  # use the first stop for the first segment, 
  # and the previous segment's last stop for all following
  ends = [trip.first] + segs.map(&:last).most
  ends.zip(segs).map(&:flatten)
end

# given a number of cities node_n,
# make trips with segs_n stops 
# that visit each city-to-city edge
# with reasonable (but imperfect) optimality
def trip_segments(node_n, segs_n)
  # make a traversal for each pair of rows.
  # Note that we'll end up repeating the n,i link for each pair, but who cares: it's O(n).
  nodes      = 0..node_n
  trip_stops = nodes.reject(&:odd?).map{ |i| traverse(i, node_n) }.flatten
  # We need to ask for them k at a time. (this doesn't add extra stops AFAIK)
  trip_segs  = trip_break_into_segments(trip_stops, segs_n)
end

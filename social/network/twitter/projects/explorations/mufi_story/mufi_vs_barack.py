import pylab
from numpy import array, log, histogram

def count_greater(obj, threshold): 
    return len([o for o in obj if o >= threshold])

def users_and_pageranks(path):
    data = {}
    f = open(path)
    line = f.readline()
    while line:
        user_id, pagerank = line.strip().split()
        user_id = int(user_id)
        pagerank = float(pagerank)
        data[user_id] = pagerank
        line = f.readline()
    return data

def pageranks_from_users(user_set, data1, data2):
    pageranks = []
    for user in user_set:
        try:             pagerank = data1[user]
        except KeyError: pagerank = data2[user]
        pageranks.append(pagerank)
    return 10.0 * log(array(pageranks) + 1.0) / log(75882.9 + 1.0)

def bin_pageranks(pageranks, bins=100):
    counts, bins = histogram(pageranks, bins=bins, range=[0,10])
    counts = array(map(float, counts))
    probs = log(counts / float(len(pageranks)))
    return bins[:-1], probs

barack = users_and_pageranks("BARACK_FOLLOWERS")
mufi   = users_and_pageranks('MUFI_FOLLOWERS')
print "read data"

barack_all, mufi_all = map(lambda d: set(d.keys()), [barack, mufi])
common          = barack_all.intersection(mufi_all)
barack_not_mufi = barack_all.difference(mufi_all)
mufi_not_barack = mufi_all.difference(barack_all)
print "found user sets"

barack_pageranks  = pageranks_from_users(barack, barack, mufi)
mufi_pageranks   = pageranks_from_users(mufi, barack, mufi)
common_pageranks = pageranks_from_users(common, barack, mufi)
barack_not_mufi_pageranks = pageranks_from_users(barack_not_mufi, barack, mufi)
mufi_not_barack_pageranks = pageranks_from_users(mufi_not_barack, barack, mufi)
print "found pageranks"


barack_bins, barack_probs = bin_pageranks(barack_pageranks)
mufi_bins, mufi_probs   = bin_pageranks(mufi_pageranks)
common_bins, common_probs = bin_pageranks(common_pageranks)
mufi_not_barack_bins, mufi_not_barack_probs = bin_pageranks(mufi_not_barack_pageranks)
barack_not_mufi_bins, barack_not_mufi_probs = bin_pageranks(barack_not_mufi_pageranks)

print "binned"

pylab.plot(barack_bins, barack_probs, label="Follow Barack (%i)" % len(barack))
pylab.plot(mufi_bins, mufi_probs, label="Follow Mufi (%i)" % len(mufi))
pylab.plot(common_bins, common_probs, label="Follow Both (%i)" % len(common))
pylab.plot(mufi_not_barack_bins, mufi_not_barack_probs, label="Follow Mufi, not Barack (%i)" % len(mufi_not_barack))
pylab.plot(barack_not_mufi_bins, barack_not_mufi_probs, label="Follow Barack, not Mufi (%i)" % len(barack_not_mufi))
pylab.xlim(0, 10)
pylab.ylim(-10, 0)
pylab.legend()
print "plotted"
pylab.show()


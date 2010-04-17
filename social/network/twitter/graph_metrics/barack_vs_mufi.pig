-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- defaults
%default MUFI_OUTPUT '/data/anal/social/network/twitter/barack_vs_mufi/mufi_followers_pageranks';
%default BARACK_OUTPUT '/data/anal/social/network/twitter/barack_vs_mufi/barack_followers_pageranks';
%default A_FOLLOWS_B '/data/fixd/social/network/twitter/models/a_follows_b';
%default PAGERANK '/data/rawd/social/netowrk/twitter/';


a_follows_b = LOAD $A_FOL

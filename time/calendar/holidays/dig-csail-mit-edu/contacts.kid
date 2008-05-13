<html
    xmlns="http://www.w3.org/1999/xhtml"
      xmlns:py="http://purl.org/kid/ns#"
    >
  <!-- in order to get the title, we conver to a list so we
       can peek at the 1st item. There might be something in
       itertools for this. -->
  <?python clist = list(contacts) ?>
  <head profile='http://www.w3.org/2006/03/hcard'>
    <title>${clist[0]['name']['text']}</title>
  </head>
<body>

<h1>Contacts</h1>

<ul>
  <li py:for="c in clist"
      class="vcard">
    <tt class="uid" py:if="c.has_key('uid')">${c['uid']['text']}</tt>

    <?python n = c.get('n', None) ?>
    <div class="n" py:if="n is not None">
      <span class="family-name" py:if="n.has_key('family-name')"
	    >${n['family-name']}</span>

      <span class="given-name" py:if="n.has_key('given-name')"
	    >${n['given-name']}</span>

      <span class="additional-name" py:if="n.has_key('additional-name')"
	    >${n['additional-name']}</span>

      <span class="honorific-prefix" py:if="n.has_key('honorific-prefix')"
	    >${n['honorific-prefix']}</span>

      <span class="honorific-suffix" py:if="n.has_key('honorific-suffix')"
	    >${n['honorific-suffix']}</span>
    </div>
    <strong class="fn" py:if="c.has_key('fn')">${c['fn']['text']}</strong>
    <dfn class="nickname" py:if="c.has_key('nickname')"
	 >${c['nickname']['text']}</dfn>
    <b class="bday" py:if="c.has_key('bday')"
	 >${c['bday']['text']}</b>
    <em class="title" py:if="c.has_key('title')">${c['title']['text']}</em>
    <b class="role" py:if="c.has_key('role')">${c['role']['text']}</b>

    <em class="org" py:if="c.has_key('org')
			   and c['org'].has_key('organization-unit')">
      <span class="organization-name">${c['org']['organization-name']}</span>
      <span class="organization-unit">${c['org']['organization-unit']}</span>
    </em>

    <em class="org" py:if="c.has_key('org')
			   and not c['org'].has_key('organization-unit')
			   ">${c['org']['organization-name']}</em>

    <ul py:if="c.has_key('email')">
      <li class="email" py:for="e in c['email']">
	<!-- @@ handling of multiple types is hosed -->
	<span py:if="e.has_key('type')" py:strip="1">
	  <span class="type" py:for="ty in e['type']">${ty}</span>
	</span>
	<span class="value">${e['text']}</span>
      </li>
    </ul>
    <ul py:if="c.has_key('tel')">
      <li class="tel" py:for="t in c['tel']">
	<span py:if="t.has_key('type')" py:strip="1">
	  <span class="type" py:for="ty in t['type']">${ty}</span>
	</span>
	<span class="value">${t['text']}</span>
      </li>
    </ul>


    <a class="url" py:if="c.has_key('url')"
       href="${c['url']['_']}"
       >url</a>

    <a class="logo" py:if="c.has_key('logo')"
       href="${c['logo']['uri']}"
       >logo</a>

    <a class="photo" py:if="c.has_key('photo')"
       href="${c['photo']['uri']}"
       >photo</a>

    <div class="geo" py:if="c.has_key('geo')">
      <span class="latitude">${c['geo']['latitude']}</span>
      <span class="longitude">${c['geo']['longitude']}</span>
    </div>
    <tt class="tz" py:if="c.has_key('tz')">${c['tz']['text']}</tt>

    <?python adrs = c.get('adr', None) ?>
    <ul py:if="adrs is not None">
      <li class="adr" py:for="adr in adrs">
	<!-- learn how to factor this sort of thing out using kid magic foo -->
	<span class="post-office-box" py:if="adr.has_key('post-office-box')"
	      >${adr['post-office-box']}</span>
	<span class="extended-address" py:if="adr.has_key('extended-address')"
	      >${adr['extended-address']}</span>
	<span class="street-address" py:if="adr.has_key('street-address')"
	      >${adr['street-address']}</span>
	<div>
	  <span class="locality" py:if="adr.has_key('locality')"
		>${adr['locality']}</span>,
	  <span class="region" py:if="adr.has_key('region')"
		>${adr['region']}</span>
	  <span class="postal-code" py:if="adr.has_key('postal-code')"
		>${adr['postal-code']}</span>
	</div>
	<span class="country-name" py:if="adr.has_key('country-name')"
	      >${adr['country-name']}</span>
	<span py:if="adr.has_key('type')" py:strip="1">
	  <span class="type" py:for="ty in adr['type']">${ty}</span>
	</span>
      </li>
    </ul>

    <tt class="class" py:if="c.has_key('class')">${c['class']['text']}</tt>
    <tt class="category" py:if="c.has_key('categories')">${c['categories']['text']}</tt>
    <pre class="note" py:if="c.has_key('note')">${c['note']['text']}</pre>
    <small class="rev" py:if="c.has_key('rev')">${c['rev']['text']}</small>

  </li>
</ul>
</body>
</html>

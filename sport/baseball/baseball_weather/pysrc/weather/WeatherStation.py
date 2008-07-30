

class WeatherStation_ISH:
	__slots__ = (
		'id_USAF',	'id_NCDC',	'name',	
		'region',	'country',	'state',	'callsign',	
		'lat'	,	'lng',		'elev',
		)
	nulls     = (
		'',			'',			'',
		'',			'',			'',			'',
		'-99999',	'-99999',	'-99999',
		)
	def __init__(self, 
		id_USAF, id_NCDC, name, 
		region,	country, state, callsign, lat, lng, elev):
		self.id_USAF	= id_USAF
		self.id_NCDC	= id_NCDC
		self.name		= name 
		self.region		= region
		self.country	= country
		self.state		= state
		self.callsign	= callsign
		self.lat		= int(lat)/1000.0 	if lat	is not None else None
		self.lng		= int(lng)/1000.0 	if lng	is not None else None
		self.elev		= int(elev)/10.0	if elev	is not None else None
		self.hist		= None
		
	@staticmethod
	def fixnulls(flat):
		return [None if (val == null or val == '') else val 
			for (val, null) in zip(flat, WeatherStation_ISH.nulls)]
	
			

class WeatherStation_COOP:
	__slots__ = (
		'id_COOP',	'id_cd',	'id_NCDC',	'id_WMO',	'id_FAA',	'id_NWS',	'id_ICAO',	
		'country',	'state',	'uscounty',	'tz',
		'name_coop','name',
		'svc_beg',	'svc_end',
		'lat',		'lng',						# !!
		'elevgd',	'elev',		'elevtype',	
		'reloc',	'stntype',
		)
	nulls	    = (
		'',			'',			'',			'',			'',			'',			'',			
		'',			'',			'',			'',		
		'',			'',		
		'00000101',	'99991231',	
		'',			'',			'',			'',			
		'',			'',			'',			'',		
		'-99999',	'-99999',	'',			
		'',			'-99999',
		)
	def __init__(self, 
		id_COOP,	id_cd,		id_NCDC,	id_WMO,		id_FAA,		id_NWS,		id_ICAO,	
		country,	state,		uscounty,	tz,
		name_coop,	name,
		svc_beg,	svc_end,
		latsgn,		latdeg,		latmin,		latsec,	
		lngsgn,		lngdeg,		lngmin,		lngsec,	
		elevgd,		elev,		elevtype,	
		reloc,		stntype):
		self.id_COOP	= id_COOP	
		self.id_cd		= id_cd	
		self.id_NCDC	= id_NCDC	
		self.id_WMO		= id_WMO	
		self.id_FAA		= id_FAA	
		self.id_NWS		= id_NWS	
		self.id_ICAO	= id_ICAO
		self.country	= country	
		self.state		= state	
		self.uscounty	= uscounty	
		self.tz			= tz
		self.name_coop	= name_coop
		self.name		= name
		self.svc_beg 	= svc_beg[0:4]+'-'+svc_beg[4:6]+'-'+svc_beg[6:8] if svc_beg is not None else None
		self.svc_end 	= svc_end[0:4]+'-'+svc_end[4:6]+'-'+svc_end[6:8] if svc_end is not None else None
		self.lat		= self.degminsecToDegrees(latsgn, latdeg, latmin, latsec)
		self.lng		= self.degminsecToDegrees(lngsgn, lngdeg, lngmin, lngsec)
		self.elevgd		= elevgd	
		self.elev		= int(elev) * (2.54 * 12 / 100) if elev is not None else None
		self.elevtype	= elevtype	
		self.reloc		= reloc	
		self.stntype	= stntype
		
	@staticmethod
	def fixnulls(flat):
		return [None if (val == null or val == '') else val 
			for (val, null) in zip(flat, WeatherStation_COOP.nulls)]
	
	@staticmethod
	def degminsecToDegrees(sgn, deg, min, sec):
		if (sgn is None and deg is None and min is None and sec is None):
			return None
		else:
			deg = int(deg); 
			min = int(min); 
			sec = int(sec)
			return (deg/1.0 + min/60.0 + sec/3600.0) * (-1 if sgn == "-" else 1)
	
class WeatherStationHistory:
	__slots__ = (
		'id_WMO',	'id_NCDC',	'year',	'month',	'n_records')
	def __init__(self, id_WMO, id_NCDC, year, month, n_records):
		self.id_WMO		= id_WMO
		self.id_NCDC	= id_NCDC
		self.year		= year
		self.month		= month
		self.n_records	= n_records
		
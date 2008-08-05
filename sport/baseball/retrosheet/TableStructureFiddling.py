#!/usr/local/bin/python
from 	itertools		import starmap
import 	csv
from 	NamedTuple		import NamedTuple


# Text tables:
# 	FieldCond:  	0 Unknown, 1 Soaked, 	2 Wet, 		3 Damp,		4 Dry
# 	Precip: 		0 Unknown, 1 None, 		2 Drizzle,	3 Showers,	4 Rain,			5 Snow
# 	Sky: 			0 Unknown, 1 Sunny, 	2 Cloudy,	3 Overcast, 4 Night, 		5 Dome
# 	WindDir: 		0 Unknown, 1 ToLeft, 	2 ToCenter,	3 ToRight, 	4 LeftToRight, 	5 FromLeft, 6 FromCenter, 7 FromRight, 8 RightToLeft
# 	WindSpeed:  	0 Unknown, 1 Known, 	other value is the wind speed
# 	dayofweek: 		1 Mon -- 7 Sun
#	EventType_Text
#	Position_Text
#	BattingStatText		('OPS'	-> 'On Base Plus Slugging', 	'OBP + SLG'), etc.
#	PitchingStatText	('ERA'	-> 'Earned Run Average',		'9 * ER / Inn'), etc.
#	FieldingStatText	('PO'	-> 'Putout',					'Receives the ball to retire a batter or runner'), etc.
#						http://www.nocryinginbaseball.com/glossary/glossary.html
#   Forfeit information:
#             "V" -- the game was forfeited to the visiting team
#             "H" -- the game was forfeited to the home team
#             "T" -- the game was ruled a no-decision
#   Protest information:
#             "P" -- the game was protested by an unidentified team
#             "V" -- a disallowed protest was made by the visiting team
#             "H" -- a disallowed protest was made by the home team
#             "X" -- an upheld protest was made by the visiting team
#             "Y" -- an upheld protest was made by the home team
#			'VH', 'VY', 'XH', 'XY'
#          	Note: two of these last four codes can appear in the field (if both teams protested the game).
##  Pitch type
# 					C  called strike			S  swinging strike	
#					B  ball						I  intentional ball			F foul ball
#					+1 pick to first by P 		+2 pick to 2d by P			+3 pick to 3d by P	
#					+1 pick to first by C 		+2 pick to 2d by C			+3 pick to 3d by C		
#					L  foul bunt				M  missed bunt				H  hit by pitch
#					R  foul ball on pitchout	P  pitchout					Q  swinging strike on pitchout
#					K  strike of unknown type	U  unkown or missing pitch

# get parkcodes file

# within season:
# 	playerID	yearID	stint

# teamID
# playerID
# umpireID
# managerID
# siteID
# rsID
# leagueID

# create gameID from h_teamID, date and gamenum_in_day
# gamedate					convert to date format
# dayofweek					convert to int
# day/night_flag			Map "D"/"N" to 0/1
# umpires:					Map "" 		to NULL
# duration					(minutes)

# pivot umpire 	names 		into umpireID
# pivot manager names 		into managerID
# pivot player 	names 		into playerID

# pivot completeionInfo		into continuationGames

# I've manually fixed the attendance for WS1194107220 (WS1 vs DET) which had '1500 e' as its attendance
# convert	''	to NULL
# convert	-1	to NULL
# escape 	'	in strings

# In SQL: index teams to games (home and visiting)

# add year flag?

# start_time				convert to time format, convert NULL from 0 (unknown)
# DH_flag					Map "T"/"F" to 0/1
# pivot translator/inputter names into rsID
# scored_input_time			convert to time format
# scored_edit_time			convert to time format
# temperature				(deg F)
# wind_direction			convert NULL from 0 (unknown)
# wind_speed				convert NULL from 0 (unknown)
# field_condition			convert NULL from 0 (unknown)
# precipitation				convert NULL from 0 (unknown)
# sky						convert NULL from 0 (unknown)


# 0	gameID
# 4	start_time			  5	DH_flag
#19	scorer_teamID		 20	translator_rsID	 21	inputter_rsID	 	 22	scoredinput_time
#23	scorededit_time		 24	scoredhow_flag	 25	scored_pitches_flag
#26	temperature			 27	wind_direction	 28	wind_speed			 29	field_condition
#30	precipitation		 31	sky
#33	gamelength_innings
#82	v_pitfinish_ID		 83	h_pitfinish_ID

# generate batter_event_num from batter_event_flag and event_num
# 'new_game_flag',		'end_game_flag', <--- completion games don't foul this up; see below
# make pitchevents 		from pitch_sequence
# make weird_hand  		from batter_hand, pitcher_hand, res_batter_hand and res_pitcher_hand
# make bangupplay_flag 	from event
# make fielder_APO		from fielder_PO*_pos, fielder_A*_pos

# uncommon fields:
#	'leadoff_flag', 		'pinchhit_flag',
#	'DP_flag',				'TP_flag',
#	'WP_flag',				'PB_flag',
#	'SH_flag',				'SF_flag',
#	'bunt_flag',			'foul_flag',
#	'bangupplay_flag',
#
# we shouldn't need
#		roster stuff 	'fielder_C_ID',		'fielder_1B_ID', 'fielder_2B_ID',	'fielder_3B_ID',	'fielder_SS_ID',	'fielder_LF_ID',	'fielder_CF_ID',	'fielder_RF_ID',
#		gameinfo stuff	'visiting_team',
#						'new_game_flag',	'end_game_flag',
#						'PR_rnr1_flag',		'PR_rnr2_flag',		'PR_rnr3_flag',		'PR_rnr1_removed_ID',
#						'PR_rnr2_removed_ID',	'PR_rnr3_removed_ID',	'PH_btr_removed_ID',	'PH_btr_removed_pos',

# turn runner*_ID into


fields_GameEvents = (
		# Game info
		'gameID',				'eventnum',				'batter_eventnum',
		# game situation
		'inning',				'homebatting_flag',
		'outs',					'balls',				'strikes',
		'v_score',				'h_score',
		
		# batter, pitcher and runners
		'batter_ID',			'batter_hand',			'resbatter_ID',			'resbatter_hand',
		'batter_pos',   		'batorder_idx',
		'pitcher_ID',			'pitcher_hand',			'respitcher_ID',		'respitcher_hand',
		# Redundant. Keep?
		'event_text',
		'pitch_sequence',
		# event description
		'event_type',
		'batter_event_flag',	'ab_flag',
		'hit_value',			'hit_location',			'batted_ball_type',		'fielded_by_pos',
		'outs_on_play',			'RBI_on_play',
		# advances on play
		'batter_dest',			'runner1_dest',			'runner2_dest',			'runner3_dest',
		'batter_play',			'runner1_play',			'runner2_play',			'runner3_play',
		# event description -- uncommon
		'WP_flag',				'PB_flag',
		'DP_flag',				'TP_flag',
		'SH_flag',				'SF_flag',
		'bunt_flag',			'foul_flag',
		'bangupplay_flag',
		'leadoff_flag',
		# errors
		'num_errors',
		'error1_player_pos',	'error1_type',			'error2_player_pos',	'error2_type',
		'error3_player_pos',	'error3_type',
		
		# baserunning
		'runner1_ID',			'runner2_ID',			'runner3_ID',
		'runner1_SB_flag',		'runner2_SB_flag',		'runner3_SB_flag',	
		'runner1_CS_flag',		'runner2_CS_flag',		'runner3_CS_flag',	
		'runner1_PO_flag',		'runner2_PO_flag',		'runner3_PO_flag',
		'runner1_resppit_ID',	'runner2_resppit_ID',	'runner3_resppit_ID',
	
		# fielding (pickoff and assists)
		'fielder_PO1_pos',		'fielder_PO2_pos',		'fielder_PO3_pos',		'fielder_A1_pos',
		'fielder_A2_pos',		'fielder_A3_pos',		'fielder_A4_pos',		'fielder_A5_pos',
		)

	# These fields are in the event file but are unused.
	# v_team
	# new_game_flag			end_game_flag
	# personnel / substitutions
	# These are unnecessary because of the GameLineup table 
	#   fielder_C_ID			fielder_1B_ID			fielder_2B_ID			fielder_3B_ID
	#   fielder_SS_ID			fielder_LF_ID			fielder_CF_ID			fielder_RF_ID
	#   'pinchhit_flag',		'runner1_PR_flag',		'runner2_PR_flag',		'runner3_PR_flag',	
	#   'batter_PH_removed_ID',	'runner1_PR_removed_ID','runner2_PR_removed_ID','runner3_PR_removed_ID',	
	#   'batter_removed_pos',
	

games       	= {}
subs     		= {}
game_rosters	= {}
eventnum_maxes	= {}


def snarf_eventnum_max(dir, year):
	csvlines = csv.reader(open(dir + 'parseable/'+str(year)+'-eventnum_max.csv', "rb"))
	eventnum_maxes = starmap()
#	for vals in csvlines:
#		gameID = vals[0]
#		eventnum_maxes[gameID] = dict(zip(fields_eventnum_maxes,vals))

def snarf_games(dir, year):
	csvlines = csv.reader(open(dir + 'csv/'+str(year)+'-games.csv', "rb"))
	for vals in csvlines:
		gameID = vals[0]
		games[gameID] = dict(zip(fields_games,vals))


def main():
	year = 2006
	dir  = '/Volumes/work/DataSources/Data_MLB/retrosheet/retrosheet-eventfiles/'
	snarf_eventnum_max(dir, year)
	snarf_games       (dir, year)
	gameIDs = games.keys(); gameIDs.sort()
	for key in gameIDs:
		print str(key) + '\t' + str(eventnum_maxes[key]) + '\t' + str(games[key]['h_pitstart'])

main()

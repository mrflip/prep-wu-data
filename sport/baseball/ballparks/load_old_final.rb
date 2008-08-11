#!/usr/bin/env ruby
require 'imw/utils'; include IMW; as_dset __FILE__
require 'ballparks_model'


parks_tree = DataSet.load([:fixd, 'parkinfo-all.yaml'])

parks_tree['park'].each do |park_id, parkinfo|
  park = Park.find_or_create({:id => park_id},{
      :beg_date   => parkinfo.delete('beg'),
      :end_date   => parkinfo.delete('end'),
      :name       => parkinfo.delete('name'),
      :num_games  => parkinfo.delete('games'),
      :streetaddr => parkinfo.delete('streetaddr'),
      :extaddr    => parkinfo.delete('extaddr'),
      :city       => parkinfo.delete('city'),
      :state      => parkinfo.delete('state'),
      :country    => parkinfo.delete('country'),
      :zip        => parkinfo.delete('zip'),
      :tel        => parkinfo.delete('tel'),
      :lat        => parkinfo.delete('lat'),
      :lng        => parkinfo.delete('lng'),
      :url        => parkinfo.delete('url'),
      :spanishurl => parkinfo.delete('spanishurl'),
      :logofile   => parkinfo.delete('logofile'),
      :is_current => parkinfo.delete('active'),
    })
  comms = parkinfo.delete('comment')
  teams = parkinfo.delete('team')
  names = parkinfo.delete('othername')
  comms.each do |comminfo|
    ParkComment.create({ :park_id => comminfo['parkID'], :comment => comminfo['comment'] })
  end if comms
  teams.each do |teaminfo|
    team = Team.find_or_create({ :id => teaminfo.delete('teamID') })
    ParkTeam.create({
        :park_id          => park.id,
        :team_id          => team.id,
        :beg_date         => teaminfo.delete('beg'),
        :end_date         => teaminfo.delete('end'),
        :num_games        => teaminfo.delete('games'),
        :neutralsite      => teaminfo.delete('neutralsite'),
        :parkname_bdb     => teaminfo.delete('parknameBDB')
      })
  end if teams
  names.each do |name|
    ParkOtherName.create({
        :park_id          => park.id,
        :name             => name.delete('name'),
        :beg_year         => name.delete('beg'),
        :end_year         => name.delete('end'),
        :is_official      => name.delete('auth'),
        :is_current       => name.delete('curr'),
      })
  end if names
end

#
#  This file is part of TSDBExplorer.
#
#  TSDBExplorer is free software: you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the
#  Free Software Foundation, either version 3 of the License, or (at your
#  option) any later version.
#
#  TSDBExplorer is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
#  Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with TSDBExplorer.  If not, see <http://www.gnu.org/licenses/>.
#
#  $Id$
#

require 'spec_helper'

describe ScheduleController do

  render_views

  # it "should display a planned schedule originating from CIF in advanced mode" do
  #   TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
  #   session[:mode] = "advanced"
  #   get :schedule_by_uid, :uid => 'C43391', :year => '2010', :month => '12', :day => '12'
  #   response.code.should eql("200")
  #   response.body.should =~ /originated from CIF/
  # end
  # 
  # it "should display a planned schedule originating from VSTP in advanced mode" do
  #   vstp_data = File.open('test/fixtures/tdnet/vstp_create_1.xml').read
  #   vstp_message = TSDBExplorer::TDnet::process_vstp_message(vstp_data)
  #   vstp_message.status.should eql(:ok)
  #   session[:mode] = "advanced"
  #   get :schedule_by_uid, :uid => '20203', :year => '2011', :month => '11', :day => '14'
  #   response.code.should eql("200")
  #   response.body.should =~ /originated from VSTP/
  # end
  # 
  # it "should return an error if passed an invalid schedule" do
  #   get :schedule_by_uid, :uid => 'Z99999'
  #   response.code.should eql("404")
  #   response.body.should =~ /schedule Z99999/
  # end
  # 
  # it "should return an error if passed a valid schedule and invalid run date" do
  #   TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
  #   get :schedule_by_uid_and_run_date, :uid => 'C43391', :year => '2010', :month => '12', :day => '13'
  #   response.code.should eql("404")
  #   response.body.should =~ /schedule C43391/
  #   response.body.should =~ /running on 2010-12-13/
  # end
  # 
  # it "should return an error if passed an invalid schedule and invalid run date" do
  #   get :schedule_by_uid_and_run_date, :uid => 'Z99999', :year => '2011', :month => '01', :day => '01'
  #   response.code.should eql("404")
  #   response.body.should =~ /schedule Z99999/
  # end
  # 
  # it "should highlight a train that has not yet been activated by TRUST" do
  #   TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/euston_to_glasgow.cif')
  #   get :schedule_by_uid_and_run_date, :uid => 'P64836', :year => '2011', :month => '11', :day => '02'
  #   response.code.should eql("200")
  #   response.body.should =~ /Real-time information/
  #   response.body.should =~ /not yet available/
  # end
  # 
  # it "should highlight a train that has been activated by TRUST, but not left its origin" do
  #   TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/euston_to_glasgow.cif')
  #   TSDBExplorer::TDnet::process_trust_message('000120111102183031TRUST               TSIA                                721S06MY02201111021830317241020111102193000P648362017101100000020091211000000CP1S06M000007241020111102193000AN6522112001   ')
  #   get :schedule_by_uid_and_run_date, :uid => 'P64836', :year => '2011', :month => '11', :day => '02'
  #   response.code.should eql("200")
  #   response.body.should =~ /Real-time information/
  #   response.body.should =~ /departed London Euston/
  # end
  # 
  # it "should highlight a train that has been activated by TRUST, and departed from its origin" do
  #   TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/euston_to_glasgow.cif')
  #   get :schedule_by_uid_and_run_date, :uid => 'P64836', :year => '2011', :month => '11', :day => '02'
  #   TSDBExplorer::TDnet::process_trust_message('000120111102183031TRUST               TSIA                                721S06MY02201111021830317241020111102193000P648362017101100000020091211000000CP1S06M000007241020111102193000AN6522112001   ')
  #   TSDBExplorer::TDnet::process_trust_message('000320111102193006TRUST               SMART                               721S06MY0220111102192900724102011110219300020111102193000     00000000000000DDA  DE131721S06MY02221120016565001E72316002 Y   72410Y')
  #   response.code.should eql("200")
  #   response.body.should =~ /Real-time information/
  #   response.body.should =~ /available for this train/
  # end
  # 
  # it "should not display real-time information for bus services" do
  #   TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_bus.cif')
  #   get :schedule_by_uid_and_run_date, :uid => 'G39152', :year => '2011', :month => '05', :day => '22'
  #   response.code.should eql("200")
  #   response.body.should_not =~ /Real-time information/
  # end
  # 
  # it "should not display real-time information for ship services" do
  #   TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_ship.cif')
  #   get :schedule_by_uid_and_run_date, :uid => 'P87065', :year => '2011', :month => '05', :day => '22'
  #   response.code.should eql("200")
  #   response.body.should_not =~ /Real-time information/
  # end


  # Schedule display functionality

  it "should redirect to the root URL if passed no schedule UID" do
    get :index
    response.should redirect_to root_url
  end

  it "should display an error message if passed an invalid schedule UID" do
    get :schedule_by_uid, :uid => 'FOOBAR'
    response.body.should =~ /couldn't find the schedule/
    response.body.should =~ /FOOBAR/
  end


  # Search functionality

  it "should redirect to the root URL if passed no parameters" do
    get :search
    response.should redirect_to root_url
  end

  it "should redirect to the root URL if passed no search term" do
    get :search, :term => ''
    response.should redirect_to root_url
  end

  it "should display an error if asked to search by an invalid method" do
    get :search, :by => 'foo', :term => 'BAR'
    response.status.should eql(400)
    response.body.should =~ /We don't know how to search by foo/
  end


  # Search by train identity

  it "should display an error if the train ID could not be found for the date requested" do
    get :search, :by => 'train_id', :term => '9Z99', :date => '2012-01-01'
    response.code.should eql('404')
    response.body.should =~ /We couldn't find any trains/
    response.body.should =~ /Sunday 1st January 2012/
    response.body.should =~ /9Z99/
  end

  it "should display an error if the train ID requested does not exist and the date is blank" do
    get :search, :by => 'train_id', :term => '9Z99', :date => ''
    response.code.should eql('404')
    response.body.should =~ /We couldn't find any trains/
    response.body.should =~ /9Z99/
  end

  it "should display an error if the train ID requested does not exist" do
    get :search, :by => 'train_id', :term => '9Z99'
    response.code.should eql('404')
    response.body.should =~ /We couldn't find any trains/
    response.body.should =~ /9Z99/
  end

  it "should allow searching for a schedule by train ID and date" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :search, :by => 'train_id', :term => '2N53', :date => '2011-05-15'
    response.should redirect_to :action => 'schedule_by_uid_and_run_date', :uid => 'C43391', :year => '2011', :month => '05', :day => '15'
  end

  it "should allow searching for a schedule by train ID in lower case and date" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :search, :by => 'train_id', :term => '2n53', :date => '2011-05-15'
    response.should redirect_to :action => 'schedule_by_uid_and_run_date', :uid => 'C43391', :year => '2011', :month => '05', :day => '15'
  end

  it "should show a list of matches if there is more than one" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/multiple_identity_2d46.cif')
    get :search, :by => 'train_id', :term => '2D46', :date => '2011-05-22'
    response.code.should eql('200')
    response.body.should =~ /more than one schedule/
    response.body.should =~ /L10500/
    response.body.should =~ /L04914/
    response.body.should =~ /L94144/
    response.body.should =~ /W01949/
    response.body.should =~ /W01952/
  end


  # Search by schedule UID

  it "should display an error if the schedule UID does not exist" do
    get :search, :by => 'schedule_uid', :term => 'Z99999'
    response.code.should eql('404')
    response.body.should =~ /We couldn't find any schedules/
    response.body.should =~ /Z99999/
  end

  it "should display an error if the schedule UID is not valid for the date requested" do
    get :search, :by => 'schedule_uid', :term => 'Z99999', :date => '2012-01-01'
    response.code.should eql('404')
    response.body.should =~ /We couldn't find any schedules/
    response.body.should =~ /Sunday 1st January 2012/
    response.body.should =~ /Z99999/
  end

  it "should allow searching for a schedule by UID and date" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :search, :by => 'schedule_uid', :term => 'C43391', :date => '2011-05-15'
    response.should redirect_to :action => 'schedule_by_uid_and_run_date', :uid => 'C43391', :year => '2011', :month => '05', :day => '15'
  end

  it "should allow searching for a schedule by UID in lower-case and date" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :search, :by => 'schedule_uid', :term => 'c43391', :date => '2011-05-15'
    response.should redirect_to :action => 'schedule_by_uid_and_run_date', :uid => 'C43391', :year => '2011', :month => '05', :day => '15'
  end

end

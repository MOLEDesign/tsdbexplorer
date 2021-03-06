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
#  $Id: main_controller_spec.rb 108 2011-04-19 20:25:19Z pwh $
#

require 'spec_helper'

describe MainController do

  before do
    ActionController::Base.perform_caching = true
  end

  render_views
  fixtures :users

  before(:each) do
    @user = users(:user)
    @admin_user = users(:admin_user)
    $REDIS.flushall
  end

  it "should show an informational page when called with an empty database" do
    get :setup
    response.code.should eql("200")
    response.body.should =~ /To use this site, you will need the latest timetable and station names data files/
  end

  it "should show a message when the site is in to maintenance mode" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index
    response.code.should eql("200")
    TSDBExplorer::Realtime::set_maintenance_mode('Test message')
    get :index
    response.code.should eql("503")
    response.body.should include('Test message')
    response.should render_template('common/maintenance_mode')
  end
                     
  it "should not show a message when the site is taken out of maintenance mode" do
    TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    get :index
    response.code.should eql("200")
    TSDBExplorer::Realtime::set_maintenance_mode('Test message')
    get :index
    response.code.should eql("503")
    TSDBExplorer::Realtime::clear_maintenance_mode
    get :index
    response.code.should_not eql("503")
    response.body.should_not include('Test message')
    response.should_not render_template('common/maintenance_mode')
  end

  it "should not display the latest schedule date if no CIF data has been imported" do
    get :setup
    response.code.should eql("200")
    response.body.should_not =~ /Schedules are available for dates up to/
  end

  it "should show a date selector on the main page" do
    result = TSDBExplorer::CIF::process_cif_file('test/fixtures/cif/record_bs_new_fullextract.cif')
    result.status.should eql(:ok)
    get :index
    response.code.should eql("200")
    response.body.should =~ /Today/
  end

  it "should show a time selector on the main page"

  it "should show a link to the admin page when an administrator is logged in" do
    sign_in @admin_user
    get :index
    response.body.should =~ /<li class=\"nav-header\">Administration<\/li>/
  end

  it "should not show a link to the admin page when a non-administrator is logged in" do
    sign_in @user
    get :index
    response.body.should_not =~ /<li class=\"nav-header\">Administration<\/li>/
  end

  it "should not show a link to the admin page when no user is logged in" do
    get :index
    response.body.should_not =~ /<li class=\"nav-header\">Administration<\/li>/
  end


  # Preferences

  it "should not show a settings menu in normal mode" do
    get :index
    response.body.should_not =~ /Settings/
  end

  it "should show a settings menu in advanced mode" do
    session['advanced'] = true
    get :index
    response.body.should =~ /Settings/
  end

  it "should not show an option to highlight VAR/STP schedules in normal mode" do
    get :index
    response.body.should_not =~ /Highlight schedules/
  end
  
  it "should show an option to highlight VAR/STP schedules in advanced mode" do
    session['advanced'] = true
    get :index
    response.body.should =~ /Highlight schedules/
  end

end

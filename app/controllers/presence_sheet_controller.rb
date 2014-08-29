class PresenceSheetController < ApplicationController
  def new
  end

  def create
    DateTime.now.beginning_of_week.advance(:days => 7)

  end
end

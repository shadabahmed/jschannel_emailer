class RepoScrapeState < ActiveRecord::Base

  def self.[](lang)
  	entry(lang)
  end	
  
  class << self
    #private(:new, :create)

    def entry(lang)
    	where(:language => lang).first_or_create	
    end	
  end
end

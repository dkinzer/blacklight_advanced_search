require 'rails/generators'

class BlacklightAdvancedSearchGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  require File.expand_path('../assets_generator.rb', __FILE__)  
  def inject_asset_requires
    BlacklightAdvancedSearch::AssetsGenerator.start
  end
  
  
  def install_localized_search_form
    if options[:force] or yes?("Install local search form with advanced link? (y/N)", :green)
      # We're going to copy the search from from actual currently loaded
      # Blacklight into local app as custom local override -- but add our link at the end too. 
      source_file = File.read(File.join(Blacklight.root, "app/views/catalog/_search_form.html.erb"))

      new_file_contents = source_file + "\n\n<%= link_to 'More options', advanced_search_path(params), :class=>'advanced_search'%>"

      create_file("app/views/catalog/_search_form.html.erb", new_file_contents)      
    end
  end

  def install_catalog_controller_mixin
    inject_into_class "app/controllers/catalog_controller.rb", "CatalogController" do
      '  include BlacklightAdvancedSearch::Controller'
    end
  end

  def copy_helper
    copy_file "advanced_search_helper.rb", "app/helpers/advanced_search_helper.rb"
    inject_into_class 'app/helpers/application_helper.rb', ApplicationHelper, "  include AdvancedSearchHelper"
  end    

end

require_dependency 'model_extensions'
require_dependency 'controller_extensions'

# Uncomment this if you reference any of your controllers in activate
begin
  require_dependency 'application_controller'
rescue MissingSourceFile
  require_dependency 'application'
end

class PageGroupPermissionsExtension < Radiant::Extension

  version "#{File.read(File.expand_path(File.dirname(__FILE__)) + '/VERSION')}"
  description "Enables you to organize users into groups and apply group-based edit permissions to the page hierarchy."
  url "https://github.com/avonderluft/radiant-page_group_permissions-extension"  

  def activate
    if Group.table_exists?
      User.module_eval &UserModelExtensions
      Page.module_eval &PageModelExtensions
      Admin::PagesController.module_eval &PageControllerExtensions
      UserActionObserver.instance.send :add_observer!, Group
      
      if self.respond_to?(:tab)
        add_tab "Settings" do
          add_item "Groups", "/admin/groups", :after => "Users", :visibility => [:admin]
        end
      else
        admin.tabs.add "Groups", "/admin/groups", :after => "Layouts", :visibility => [:admin]
      end
      admin.pages.index.add :node, "page_group_td", :before => "status_column"
      admin.pages.index.add :sitemap_head, "page_group_th", :before => "status_column_header"
      admin.pages.edit.add :layout, "page_group_form_part", :after => "edit_published_at"
    end
  end

end
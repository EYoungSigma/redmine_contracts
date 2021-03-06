require 'test_helper'
require 'performance_test_help'

# Performance logs
#
class ContractShowTest < ActionController::PerformanceTest
  def setup
    @project = Project.generate!(:identifier => 'main').reload
    @contract = Contract.generate!(:project => @project)
    @manager = User.generate_user_with_permission_to_manage_budget(:project => @project).reload
    @fixed_deliverable = FixedDeliverable.generate!(:contract => @contract, :manager => @manager, :title => 'The Title')
    @hourly_deliverable = HourlyDeliverable.generate!(:contract => @contract, :manager => @manager, :title => 'An Hourly')

    @rate = Rate.generate!(:project => @project, :user => @manager, :date_in_effect => Date.today, :amount => 100)
    
    configure_overhead_plugin
    100.times do
      generate_issues_and_time_entries_for_deliverable(@hourly_deliverable, @project)
      generate_issues_and_time_entries_for_deliverable(@fixed_deliverable, @project)
    end
    
    # Load the app
    login_as @manager.login, 'contracts'
    visit_contracts_for_project(@project)
  end
  
  def test_contract_show
    click_link @contract.id
  end

  private

  def generate_issues_and_time_entries_for_deliverable(deliverable, project)
    @issue1 = Issue.generate_for_project!(project)
    @time_entry1 = TimeEntry.generate!(:issue => @issue1,
                                       :project => project,
                                       :activity => @billable_activity,
                                       :spent_on => Date.today,
                                       :hours => 10,
                                       :user => @manager)
    @time_entry2 = TimeEntry.generate!(:issue => @issue1,
                                       :project => project,
                                       :activity => @non_billable_activity,
                                       :spent_on => Date.today,
                                       :hours => 20,
                                       :user => @manager)

    deliverable.issues << @issue1

  end
end

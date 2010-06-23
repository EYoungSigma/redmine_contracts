class DeliverablesController < InheritedResources::Base
  unloadable

  respond_to :html

  before_filter :find_contract
  before_filter :authorize

  def create
    @deliverable = begin_of_association_chain.deliverables.build(params[:deliverable])
    @deliverable.type = 'FixedDeliverable'
    create! { contract_url(@project, @contract) }
  end

  protected

  def begin_of_association_chain
    @contract
  end
  
  private
  
  def find_contract
    @contract = Contract.find(params[:contract_id])
    @project = @contract.project
  end

end
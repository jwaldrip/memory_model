# RSpec matcher to spec delegations.
#
# Usage:
#
#     describe Post do
#       it { should delegate(:name).to(:author).with_prefix } # post.author_name
#       it { should delegate(:month).to(:created_at) }
#       it { should delegate(:year).to(:created_at) }
#     end

RSpec::Matchers.define :delegate do |target_method|
  match do |delegator|
    source_method = @prefix ? :"#{@to}_#{target_method}" : target_method
    @delegator = delegator
    begin
      @delegator.send(@to)
    rescue NoMethodError
      raise "#{@delegator} does not respond to #{@to}!"
    end
    allow(@delegator).to receive(@to).and_return(double 'receiver', target_method => :called)
    args = (target_method =~ /[^\]]=$/) ? [:called] : []
    @delegator.send(source_method, *args) == :called
  end

  description do
    "delegate :#{target_method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end

  failure_message_for_should do |text|
    "expected #{@delegator} to delegate :#{target_method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end

  failure_message_for_should_not do |text|
    "expected #{@delegator} not to delegate :#{target_method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end

  chain(:to) { |receiver| @to = receiver }
  chain(:with_prefix) { @prefix = true }

end
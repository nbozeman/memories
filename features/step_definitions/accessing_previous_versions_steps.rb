Given /^a document with versions$/ do
  @doc = Book.create :name => 'version 1'
  (2..10).each do |i|
    @doc.name = "version #{i}"
    @doc.save
  end
end

When /^I call the "versions" method$/ do 
  @versions = @doc.versions
end

Then /^I should get back an array proxy for previous versions$/ do
  @versions.should be_kind_of(Memories::VersionsProxy)
end

Given /^a "versions" array proxy for a document$/ do
  Given %{a document with versions}
  When %{I call the "versions" method}
end

When /^I call the \[\] method on the proxy with an integer that corresponds to an existing version$/ do
  @version = @versions[1]
end

Then /^I should get back that version of the document$/ do
  @version.name.should == "version 1"
end

When /^I call the \[\] method on the proxy with an integer that does not correspond to a version$/ do
  @version = @versions[25]
end

Then /^I should get back nil$/ do
  @version.should be_nil
end

When /^I call the \[\] method on the proxy with a range of valid versions$/ do
  @document_versions = @versions[(1..8)]
end

Then /^I should get back an array consisting of those valid versions$/ do
  @document_versions.count.should == 8
  @document_versions.each_with_index do |document, i|
    document.name.should == "version #{i+1}"
  end
end

When /^I call the \[\] method on the proxy with a range that includes versions that don't exist$/ do
  @document_versions = @versions[5..15]
end

Then /^I should get back an array containing the versions that existed$/ do
  @document_versions.count.should == 6
  @document_versions.each_with_index do |document, i|
    document.name.should == "version #{i+5}"
  end
end

When /^I call the \[\] method on the proxy with a range that does not include any valid versions$/ do
  @document_versions = @versions[15..50]
end

Then /^I should get back an empty array$/ do
  @document_versions.should == []
end

When /^I call the \[\] method on the proxy with a string corresponding to a valid version$/ do
  @version = @versions[@doc["_attachments"].keys.sort.first]
end

When /^I call the \[\] method on the proxy with an string that does not correspond to a valid version$/ do
  @version = @versions['jkfldsajklfdsa']
end

When /^I call the \#last method on the proxy$/ do
  @last = @versions.last
end

Then /^I should get the latest version of the document$/ do
  @doc.name.should == @last.name
end

When /^I update the document$/ do
  @doc.name = 'update!'
  @doc.save
end

When /^I call the \#first method on the proxy$/ do
  @first = @versions.first
end

Then /^I should get the first version of the document$/ do
  @first.name.should == "version 1"
end

When /^I call the \[\] method on the proxy with a range that includes the latest version$/ do
  @version_range = @versions[1..@doc.current_version]
end

Then /^I should recieve an array where the last element is the latest version$/ do
  @version_range.last.name.should == @doc.name
end

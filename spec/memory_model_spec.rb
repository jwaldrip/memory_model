describe MemoryModel do

  describe ".truncate!" do
    it "Should return true" do
      subject.truncate!.should be_true
    end
  end

end

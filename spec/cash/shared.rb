module Cash
  shared_examples_for "#fetch([...])" do
    describe '#fetch([])' do
      it 'returns the empty hash' do
        Story.fetch([]).should == {}
      end
    end
  
    describe 'when there is a total cache miss' do
      it 'yields the keys to the block' do
        Story.fetch(["yabba", "dabba"]) { |*missing_ids| ["doo", "doo"] }.should == {
          "Story:1/yabba" => "doo",
          "Story:1/dabba" => "doo"
        }
      end
    end

    describe 'when there is a partial cache miss' do
      it 'yields just the missing ids to the block' do
        Story.set("yabba", "dabba")
        Story.fetch(["yabba", "dabba"]) { |*missing_ids| "doo" }.should == {
          "Story:1/yabba" => "dabba",
          "Story:1/dabba" => "doo"
        }
      end
    end
  end
  shared_examples_for 'the records are written-through in sorted order' do
    describe 'when there are not already records matching the index' do
      it 'initializes the index' do
        fairy_tale = FairyTale.create!(:title => 'title')
        FairyTale.get("title/#{fairy_tale.title}").should == [fairy_tale.id]
      end
    end

    describe 'when there are already records matching the index' do
      before do
        @fairy_tale1 = FairyTale.create!(:title => 'title')
        FairyTale.get("title/#{@fairy_tale1.title}").should == sorted_and_serialized_records(@fairy_tale1)
      end

      describe 'when the index is populated' do
        it 'appends to the index' do
          fairy_tale2 = FairyTale.create!(:title => @fairy_tale1.title)
          FairyTale.get("title/#{@fairy_tale1.title}").should == sorted_and_serialized_records(@fairy_tale1, fairy_tale2)
        end
      end

      describe 'when the index is not populated' do
        before do
          $memcache.flush_all
        end

        it 'initializes the index' do
          fairy_tale2 = FairyTale.create!(:title => @fairy_tale1.title)
          FairyTale.get("title/#{@fairy_tale1.title}").should == sorted_and_serialized_records(@fairy_tale1, fairy_tale2)
        end
      end
    end
  end
end
       
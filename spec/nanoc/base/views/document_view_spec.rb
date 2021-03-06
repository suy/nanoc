shared_examples 'a document view' do
  describe '#== and #eql?' do
    let(:document) { entity_class.new('content', {}, '/asdf/') }
    let(:view) { described_class.new(document, nil) }

    context 'comparing with document with same identifier' do
      let(:other) { entity_class.new('content', {}, '/asdf/') }

      it 'is equal' do
        expect(view).to eq(other)
        expect(view).to eql(other)
      end
    end

    context 'comparing with document with different identifier' do
      let(:other) { entity_class.new('content', {}, '/fdsa/') }

      it 'is not equal' do
        expect(view).not_to eq(other)
        expect(view).not_to eql(other)
      end
    end

    context 'comparing with document view with same identifier' do
      let(:other) { Nanoc::LayoutView.new(entity_class.new('content', {}, '/asdf/'), nil) }

      it 'is equal' do
        expect(view).to eq(other)
        expect(view).to eql(other)
      end
    end

    context 'comparing with document view with different identifier' do
      let(:other) { Nanoc::LayoutView.new(entity_class.new('content', {}, '/fdsa/'), nil) }

      it 'is not equal' do
        expect(view).not_to eq(other)
        expect(view).not_to eql(other)
      end
    end

    context 'comparing with other object' do
      let(:other) { nil }

      it 'is not equal' do
        expect(view).not_to eq(other)
        expect(view).not_to eql(other)
      end
    end
  end

  describe '#[]' do
    let(:document) { entity_class.new('stuff', { animal: 'donkey' }, '/foo/') }
    let(:view) { described_class.new(document, nil) }

    subject { view[key] }

    before do
      expect(Nanoc::Int::NotificationCenter).to receive(:post).with(:visit_started, document).ordered
      expect(Nanoc::Int::NotificationCenter).to receive(:post).with(:visit_ended, document).ordered
    end

    context 'with existant key' do
      let(:key) { :animal }
      it { is_expected.to eql('donkey') }
    end

    context 'with non-existant key' do
      let(:key) { :weapon }
      it { is_expected.to eql(nil) }
    end
  end

  describe '#attributes' do
    let(:item) { entity_class.new('stuff', { animal: 'donkey' }, '/foo/') }
    let(:view) { described_class.new(item, nil) }

    before do
      expect(Nanoc::Int::NotificationCenter).to receive(:post).with(:visit_started, item).ordered
      expect(Nanoc::Int::NotificationCenter).to receive(:post).with(:visit_ended, item).ordered
    end

    subject { view.attributes }

    it 'returns attributes' do
      expect(subject).to eql(animal: 'donkey')
    end
  end

  describe '#fetch' do
    let(:item) { entity_class.new('stuff', { animal: 'donkey' }, '/foo/') }
    let(:view) { described_class.new(item, nil) }

    before do
      expect(Nanoc::Int::NotificationCenter).to receive(:post).with(:visit_started, item).ordered
      expect(Nanoc::Int::NotificationCenter).to receive(:post).with(:visit_ended, item).ordered
    end

    context 'with existant key' do
      let(:key) { :animal }

      subject { view.fetch(key) }

      it { should eql?('donkey') }
    end

    context 'with non-existant key' do
      let(:key) { :weapon }

      context 'with fallback' do
        subject { view.fetch(key, 'nothing sorry') }
        it { should eql?('nothing sorry') }
      end

      context 'with block' do
        subject { view.fetch(key) { 'nothing sorry' } }
        it { should eql?('nothing sorry') }
      end

      context 'with no fallback and no block' do
        subject { view.fetch(key) }

        it 'raises' do
          expect { subject }.to raise_error(KeyError)
        end
      end
    end
  end

  describe '#key?' do
    let(:document) { entity_class.new('stuff', { animal: 'donkey' }, '/foo/') }
    let(:view) { described_class.new(document, nil) }

    before do
      expect(Nanoc::Int::NotificationCenter).to receive(:post).with(:visit_started, document).ordered
      expect(Nanoc::Int::NotificationCenter).to receive(:post).with(:visit_ended, document).ordered
    end

    subject { view.key?(key) }

    context 'with existant key' do
      let(:key) { :animal }
      it { should eql?(true) }
    end

    context 'with non-existant key' do
      let(:key) { :weapon }
      it { should eql?(false) }
    end
  end

  describe '#hash' do
    let(:document) { double(:document, identifier: '/foo/') }
    let(:view) { described_class.new(document, nil) }

    subject { view.hash }

    it { should == described_class.hash ^ '/foo/'.hash }
  end
end

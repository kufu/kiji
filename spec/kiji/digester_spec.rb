# frozen_string_literal: true

require 'spec_helper'

describe Kiji::Digester do
  describe '#hexdigest' do
    my_digester = Kiji::Digester.new(:sha256)
    file_content = File.read('spec/fixtures/sample_application_form.xml')
    it { expect(my_digester.hexdigest(file_content)).to eq '307890a1c39531008829d43fb16db82e0922f46e629a04c00ebf2728d532017e' }
  end
  describe '#base64' do
    my_digester = Kiji::Digester.new(:sha256)
    file_content = File.read('spec/fixtures/sample_application_form.xml')
    it { expect(my_digester.base64(file_content)).to eq 'MHiQocOVMQCIKdQ/sW24Lgki9G5imgTADr8nKNUyAX4=' }
  end
end

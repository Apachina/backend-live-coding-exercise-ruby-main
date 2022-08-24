# frozen_string_literal: true

Dir['./services/*.rb'].sort.each { |file| require file }
require 'rspec'

RSpec.describe UserQuestionnaireService do
  subject(:questionnaire_service) { described_class.new }

  before do
    stub_const('UserQuestionnaireService::ANSWERS_STORE_NAME', 'test.answers.pstore')
    stub_const('UserQuestionnaireService::RATINGS_STORE_NAME', 'test.raitings.pstore')
    allow(questionnaire_service).to receive(:gets).and_return('Yes', 'y', 'n', 'no', 'NO')
  end

  after(:each) do
    if File.exist?(UserQuestionnaireService::ANSWERS_STORE_NAME)
      File.delete(UserQuestionnaireService::ANSWERS_STORE_NAME)
    end
    if File.exist?(UserQuestionnaireService::RATINGS_STORE_NAME)
      File.delete(UserQuestionnaireService::RATINGS_STORE_NAME)
    end
  end

  describe '#do_prompt' do
    it 'returns without any errors' do
      expect { questionnaire_service.do_prompt }.to_not raise_error
    end
  end

  describe '#do_report' do
    it 'returns text with ratings' do
      questionnaire_service.do_prompt
      expect { questionnaire_service.do_report }.to output(/[Your raiting is][Your raiting is]/).to_stdout
    end
  end

  describe '#validate_answer' do
    context 'when answer is valid' do
      it 'returns without errors' do
        questionnaire_service.instance_variable_set(:@answer, %w[Yes YES yes YEs YeS yeS y].sample)
        expect { questionnaire_service.send(:validate_answer) }.to_not raise_error
      end
    end

    context 'when answer is not valid' do
      it 'returns error message' do
        questionnaire_service.instance_variable_set(:@answer, 'another text')
        expect do
          questionnaire_service.send(:validate_answer)
        end.to output("Please, write only Yes|No or y|n \n").to_stdout
      end
    end
  end

  describe '#display_error_message' do
    it 'returns error message' do
      expect do
        questionnaire_service.send(:display_error_message)
      end.to output("Please, write only Yes|No or y|n \n").to_stdout
    end

    it 'puts another gets' do
      questionnaire_service.instance_variable_set(:@answer, 'another text')
      questionnaire_service.send(:display_error_message)
      expect(questionnaire_service.instance_variable_get('@answer')).to eq 'yes'
    end
  end

  describe '#rating' do
    it 'counts rating' do
      questionnaire_service.do_prompt
      # in receive gets only 2 answers is positive
      expect(questionnaire_service.send(:rating)).to eq(100 * 2 / described_class::QUESTIONS.size)
    end
  end

  describe '#overage_rating' do
    context 'when was one questionnaire' do
      it 'counts overage rating' do
        questionnaire_service.do_prompt
        expect(questionnaire_service.send(:overage_rating)).to eq(
          questionnaire_service.ratings_store.all_stored.sum /
            questionnaire_service.ratings_store.keys.last
        )
      end
    end

    context 'when was two questionnaire' do
      let(:another_questionnaire_service) { described_class.new }

      before do
        allow(another_questionnaire_service).to receive(:gets).and_return('Yes', 'y', 'YES', 'yEs', 'YEs')
      end

      it 'counts overage rating' do
        questionnaire_service.do_prompt
        another_questionnaire_service.do_prompt
        expect(another_questionnaire_service.send(:overage_rating)).to eq(
          another_questionnaire_service.ratings_store.all_stored.sum /
            another_questionnaire_service.ratings_store.keys.last
        )
      end
    end
  end

  describe '#count_right_answers' do
    it 'counts right answers' do
      questionnaire_service.do_prompt
      # in receive gets only 2 answers is positive
      expect(questionnaire_service.send(:count_right_answers)).to eq 2
    end
  end

  describe '#question_number' do
    before do
      questionnaire_service.do_prompt
    end

    context 'when first questionnaire' do
      it 'returns current question number' do
        expect(questionnaire_service.send(:question_number)).to eq 1
      end
    end

    context 'when not the first questionnaire' do
      let(:another_questionnaire_service) { described_class.new }

      before do
        allow(another_questionnaire_service).to receive(:gets).and_return('Yes', 'y', 'YES', 'yEs', 'YEs')
      end

      it 'returns current question number' do
        expect(another_questionnaire_service.send(:question_number)).to eq 2
      end
    end
  end
end

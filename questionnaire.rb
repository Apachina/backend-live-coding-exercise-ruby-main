# frozen_string_literal: true

Dir['./services/*.rb'].sort.each { |file| require file }

questionnaire = UserQuestionnaireService.new
questionnaire.do_prompt
questionnaire.do_report

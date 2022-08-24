# frozen_string_literal: true

require './questions'

# UserQuestionnaireService is responsible for the working with user questions
# returns personal rating and overage
class UserQuestionnaireService
  attr_reader :answers_store, :ratings_store

  ANSWERS_STORE_NAME = 'answers.pstore'
  RATINGS_STORE_NAME = 'ratings.pstore'
  POSITIVE_ANSWERS = %w[yes y].freeze
  NEGATIVE_ANSWERS = %w[no n].freeze
  ALLOWED_ANSWERS = POSITIVE_ANSWERS + NEGATIVE_ANSWERS

  def initialize
    @answers_store = StoreService.new(ANSWERS_STORE_NAME)
    @ratings_store = StoreService.new(RATINGS_STORE_NAME)
  end

  def do_prompt
    Questions::LIST.each_key do |question_key|
      print Questions::LIST[question_key]
      @answer = gets.chomp.downcase

      validate_answer

      # saving answers as array in file where key is question_number
      answers_store.merge_to_array_by_key(question_number, @answer)
    end

    # saving ratings in another file to separate data logic,
    # where key is question_number
    ratings_store.save_by_key(question_number, rating)
  end

  def do_report
    print "Your rating is #{rating}\n"
    print "Average rating is #{overage_rating}\n"
  end

  private

  # pass validation if answer include in ['yes', 'y']
  # or display error asking to write valid data
  def validate_answer
    display_error_message unless ALLOWED_ANSWERS.include? @answer
  end

  def display_error_message
    print "Please, write only Yes|No or y|n \n"
    @answer = gets.chomp.downcase
    validate_answer
  end

  def rating
    @rating ||= 100 * count_right_answers / Questions::LIST.size
  end

  def overage_rating
    @overage_rating = ratings_store.all_stored.sum / ratings_store.keys.last
  end

  def count_right_answers
    @count_right_answers = answers_store.read_by_key(question_number)
                                        .select { |answer| POSITIVE_ANSWERS.include? answer }.count
  end

  # current question number
  # always started from 1
  def question_number
    @question_number ||= answers_store.keys.last.to_i + 1
  end
end

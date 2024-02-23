# frozen_string_literal: true

namespace :ml do
  desc 'Train the machine learning model using Python script'
  task train: :environment do
    dataset_path = Rails.root.join('lib', 'models', 'bank.csv').to_s
    script_path = Rails.root.join('lib', 'python', 'train_model.py').to_s
    trained_model_path = Rails.root.join('lib', 'models', 'trained_model.pkl').to_s
    label_encoders_path = Rails.root.join('lib', 'models', 'label_encoders.pkl').to_s

    system('python3', script_path, dataset_path, trained_model_path, label_encoders_path)
    puts 'Training complete. Model and label encoders saved.'
  end
  desc 'Train the machine learning model using Python script catboost'
  task traincb: :environment do
    dataset_path = Rails.root.join('lib', 'models', 'bank.csv').to_s
    script_path = Rails.root.join('lib', 'python', 'train_model_catboost.py').to_s
    system('python3', script_path, dataset_path)
  end
end

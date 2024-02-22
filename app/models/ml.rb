# frozen_string_literal: true

require 'rumale'
train_size = (x.shape[0] * 0.8).to_i
x_train = x[0...train_size, true]
x_test = x[train_size..-1, true]
y_train = y[0...train_size]
y_test = y[train_size..]

rf = Rumale::Ensemble::RandomForestClassifier.new(n_estimators: 100, random_seed: 42)
rf.fit(x_train, y_train)

y_pred = rf.predict(x_test)

accuracy = Rumale::EvaluationMeasure::Accuracy.new.score(y_test, y_pred)
puts "Accuracy: #{accuracy}"

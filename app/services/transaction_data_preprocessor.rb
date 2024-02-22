class TransactionDataPreprocessor
  def self.process(data)
    # Convert the data to JSON string
    data_json = data.to_json

    # Execute the Python script with Open3 to capture stdout, stderr, and process status safely
    require 'open3'
    stdout, stderr, status = Open3.capture3("python3 lib/python/preprocess_data.py", stdin_data: data_json)

    if status.success?
      JSON.parse(stdout)
    else
      { error: "Failed to execute Python script: #{stderr}" }
    end
  rescue JSON::ParserError => e
    { error: "Failed to parse JSON output from Python script: #{e.message}" }
  end
end

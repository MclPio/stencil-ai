# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

message_collections = [
  {
    "role": "system",
    "content": "You are a helpful assistant, give coding feedback or something",
    "input_tokens": 10,
    "output_tokens": nil,
    "created_at": "2025-03-22T10:00:00Z",
    "updated_at": "2025-03-22T10:00:00Z"
  },
  {
    "role": "user",
    "content": "Hello, can you help me with my project?",
    "input_tokens": 10,
    "output_tokens": nil,
    "created_at": "2025-03-22T10:00:00Z",
    "updated_at": "2025-03-22T10:00:00Z"
  },
  {
    "role": "assistant",
    "content": "Of course! What do you need assistance with?",
    "input_tokens": nil,
    "output_tokens": 12,
    "created_at": "2025-03-22T10:01:00Z",
    "updated_at": "2025-03-22T10:01:00Z"
  },
  {
    "role": "user",
    "content": "I’m stuck on setting up the database schema.",
    "input_tokens": 9,
    "output_tokens": nil,
    "created_at": "2025-03-22T10:02:00Z",
    "updated_at": "2025-03-22T10:02:00Z"
  },
  {
    "role": "assistant",
    "content": "Let’s start with your models. What tables do you need?",
    "input_tokens": nil,
    "output_tokens": 11,
    "created_at": "2025-03-22T10:03:00Z",
    "updated_at": "2025-03-22T10:03:00Z"
  }
]

user = User.create!(email_address: "user0@world.co", password: "1234", name: "Joe Smith")
project = Project.create!(title: "AI Oven", user: user)
conversation = Conversation.create!(title: "First Attempt", project: project)
messages = message_collections.each do |message|
  Message.create!(role: message[:role], content: message[:content], input_tokens: message[:input_tokens],
              output_tokens: message[:output_tokens], conversation: conversation)
end

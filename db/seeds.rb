# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Dir[Rails.root.join('db', 'stencils', '*.rb')].each { |file| require file }

message_collections = [
  {
    "role": "system",
    "content": "You are a helpful assistant, give coding feedback or something",
    "created_at": "2025-03-22T10:00:00Z",
    "updated_at": "2025-03-22T10:00:00Z"
  },
  {
    "role": "user",
    "content": "Hello, can you help me with my project?",
    "created_at": "2025-03-22T10:00:00Z",
    "updated_at": "2025-03-22T10:00:00Z"
  },
  {
    "role": "assistant",
    "content": "Of course! What do you need assistance with?",
    "created_at": "2025-03-22T10:01:00Z",
    "updated_at": "2025-03-22T10:01:00Z"
  },
  {
    "role": "user",
    "content": "I’m stuck on setting up the database schema.",
    "created_at": "2025-03-22T10:02:00Z",
    "updated_at": "2025-03-22T10:02:00Z"
  },
  {
    "role": "assistant",
    "content": "Let’s start with your models. What tables do you need?",
    "created_at": "2025-03-22T10:03:00Z",
    "updated_at": "2025-03-22T10:03:00Z"
  },
  {
    "role": "assistant",
    "content": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi nec massa ut risus porttitor auctor nec eget felis.
    Aliquam sed lorem mi. Vestibulum nibh odio, auctor vitae eros non, tempus sodales leo. Curabitur pulvinar sapien consectetur
    sapien pharetra convallis. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.
    Nunc tempus neque id vehicula rhoncus. Cras ultrices porta massa, in ultrices lectus volutpat blandit.
    Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Fusce lobortis finibus eros sit amet laoreet.
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin rhoncus non orci a aliquet. Aliquam erat volutpat. Fusce placerat nunc in est imperdiet semper.
    Vivamus elit nisi, hendrerit non ultricies sit amet, placerat vitae risus. Fusce sed tellus est. Suspendisse ut cursus turpis. Donec iaculis eros magna",
    "created_at": "2025-03-22T10:03:00Z",
    "updated_at": "2025-03-22T10:03:00Z"
  }
]

stencil_admin = User.create!(email_address: "stencil@world.co", password: "1234", name: "free_stencil", account_type: "admin")
invite = Invite.create!(admin: stencil_admin, reusable: true)

user0 = User.create!(email_address: "user0@world.co", password: "1234", name: "Joe Smith", account_type: "paid", invite_code: invite.invite_code)
user1 = User.create!(email_address: "user1@world.co", password: "1234", name: "Mikey Hanma", account_type: "paid", invite_code: invite.invite_code)
free_user = User.create!(email_address: "free@world.co", password: "1234", name: "Moe Free1", account_type: "free", invite_code: invite.invite_code)

2.times do |i|
  project = Project.create!(title: "AI Oven #{i}", user: user0)
  conversation = project.conversation
  message_collections.each do |message|
    Message.create!(role: message[:role], content: message[:content], conversation: conversation)
  end
end

2.times do |i|
  project = Project.create!(title: "AI Oven #{i}", user: user1)
  conversation = project.conversation
  message_collections.each do |message|
    Message.create!(role: message[:role], content: message[:content], conversation: conversation)
  end
end

2.times do |i|
  stencil = ArtifactStencil.create!(name: "Stencil #{i}", prompt: "I like pizza, say it with me WAHOOO #{i}",
                          description: "HALLO", published: true, user: user0)
  favorite_stencil = FavoriteArtifactStencil.create!(artifact_stencil: stencil, user: user1)
end

2.times do |i|
  stencil = ArtifactStencil.create!(name: "Stencil #{i}", prompt: "I like pizza, say it with me WAHOOO #{i}",
                          description: "HALLO", published: true, user: user1)
  favorite_stencil = FavoriteArtifactStencil.create!(artifact_stencil: stencil, user: user0)
end

[ Stencils::Erd, Stencils::Roadmap, Stencils::ValueFlow ].each do |stencil|
  stencil_admin.artifact_stencils.create!(
    name: stencil.name,
    description: stencil.description,
    prompt: stencil.system_prompt,
    category: stencil.category,
    published: true
  )
end

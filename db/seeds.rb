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
    Vivamus elit nisi, hendrerit non ultricies sit amet, placerat vitae risus. Fusce sed tellus est. Suspendisse ut cursus turpis. Donec iaculis eros magna,
    nec sollicitudin lectus dignissim non. Donec at sapien sed sem pellentesque varius. Mauris vitae viverra nulla. In hac habitasse platea dictumst.
    Nam vehicula ante non felis convallis sollicitudin. Maecenas finibus nisi a purus pulvinar dapibus. Duis nisi nisi, tempor ut lacus a,
    tristique ullamcorper neque. Suspendisse sed orci a odio placerat maximus. Donec in blandit eros. Sed blandit tincidunt viverra.
    Etiam in efficitur mauris. Aenean sollicitudin faucibus elementum. Etiam ullamcorper cursus volutpat. Nulla consequat lorem at laoreet pretium.
    Aliquam non viverra purus. Nam viverra, est vel hendrerit tincidunt, justo tortor euismod lorem, quis dapibus lorem tortor non arcu.
    Cras sit amet volutpat metus. Suspendisse potenti. Ut egestas dolor in dui mollis, quis tristique libero iaculis. Fusce egestas vehicula tempus.
    Nulla at dui ut nunc laoreet blandit. Vivamus quis nisi volutpat, accumsan quam ut, commodo justo. Aenean tincidunt posuere accumsan.
    Maecenas non eros quis nisl faucibus dapibus a dapibus ante. Maecenas neque elit, posuere id efficitur sit amet, malesuada in nulla.
    Donec quam turpis, sodales at elit consequat, luctus lobortis nibh. Sed sapien massa, rutrum nec mattis in, tincidunt ultrices mauris.
    Praesent fringilla aliquet tellus nec fringilla. Proin aliquam porta purus. Sed semper nulla ligula, vel iaculis ante hendrerit nec. Morbi placerat nunc elit,
    sit amet vehicula diam eleifend a. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Aliquam aliquam ac odio eget viverra.
    Aliquam bibendum viverra nibh non sodales. In enim quam, convallis ac placerat vel, malesuada et enim. In in metus quis ex luctus gravida at vel felis.
    Aenean rutrum mauris non congue gravida. Donec pretium odio ut luctus iaculis. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae;
    Fusce sagittis ac ante scelerisque molestie. Donec volutpat interdum turpis vel porta. Praesent id accumsan felis, quis sollicitudin arcu. Nam at suscipit odio.",
    "created_at": "2025-03-22T10:03:00Z",
    "updated_at": "2025-03-22T10:03:00Z"
  }
]

user = User.create!(email_address: "user0@world.co", password: "1234", name: "Joe Smith", account_type: "admin")

5.times do |i|
  project = Project.create!(title: "AI Oven #{i}", user: user)
  conversation = project.conversation
  messages = message_collections.each do |message|
    Message.create!(role: message[:role], content: message[:content], conversation: conversation)
  end
end



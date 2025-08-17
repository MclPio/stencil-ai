# Core Functionality

## Front to Back

### Project
app/views/projects
1. app/views/projects/index.html.erb, @projects
1. app/views/projects/new.html.erb, @project
1. app/views/projects/show.html.erb @project
1. app/views/projects/update.turbo_stream.erb
1. app/views/projects/update.turbo_stream.erb @project, multiple turbo stream updates were put here for spa feel...

app/controllers/projects_controller.rb
1. new
1. index
1. create, validate_project_limit_for_user, additionally creates conversation, as shown in app/models/project.rb
1. update
1. destroy

### Conversations
app/views/conversations
1. @project, @conversation
1. app/views/conversations/show.html.erb
    1. partial: layouts/flash_messages
    1. partial: projects/menu, locals: { project: @project, projects: @projects }
    1. partial: chat, locals: { conversation: @conversation  }
        1. partial: "conversations/#{message.role}_role", locals: { message: message }
            1. app/views/conversations/_assistant_role.html.erb
            1. app/views/conversations/_user_role.html.erb
    1. partial: "message_form_disabled", locals: { conversation: @conversation }
    1. partial: "message_form", locals: { conversation: @conversation }

app/controllers/conversations_controller.rb # used for setting @project, @projects, @conversation
app/controllers/messages_controller.rb # probably involved here since the form uses it...
1. if statement for either ContentGenerationJob or ProcessLlmChatJob.

### Artifact Stencils: This is basically for creating and showing a stencil
app/views/artifact_stencils
1. app/views/artifact_stencils/show.html.erb, @artifact_stencil
1. app/views/artifact_stencils/new.html.erb, @artifact_stencil
1. app/views/artifact_stencils/_errors.html.erb, hmmm not sure why we have our own errors here...

app/controllers/artifact_stencils_controller.rb # basic crud controller


### Favorite Artifact Stencils
app/views/favorite_artifact_stencils
1. app/views/favorite_artifact_stencils/index.html.erb, weird index: @user_artifact_stencils, @free_artifact_stencils, @favorite_artifact_stencils

app/controllers/favorite_artifact_stencils_controller.rb # another basic crud controller.

### Other
app/views/layouts
1. app/views/layouts/_flash_messages_timed.html.erb
1. app/views/layouts/_flash_messages.html.erb
1. app/views/layouts/_navbar.html.erb

app/views/invites
1. app/views/invites/index.html.erb, @invites
1. app/views/invites/new.html.erb, @invites
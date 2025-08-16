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

### Artifact Stencils
app/views/artifact_stencils

### Favorite Artifact Stencils
app/views/favorite_artifact_stencils

### Other
app/views/layouts
app/views/invites

Stencil-AI Data Flow
**Projects**
we just need to get index of projects to the page view…

@projects
app/controllers/projects_controller.rb → app/views/projects/index.html.erb

----

**Conversations**

**Sidebar**
@projects.artifact_stencils # To get only subscribed stencils per project.
artifact_stencil_id -> messages_controller.rb

**Chat**
Needs to be accepting live output streaming.

@user_messsage # send it to the chat
@assistant_message # send it to the chat (via streaming)
@artifact_shortcut # add shortcut to chat, update artifact in artifacts tab, and update selection.

**Message Form**
Needs to be accepting user messages
 -> messages_controller.rb

**Artifacts**

----

**Stencils** # Need to figure out new layout before implementing
we need to get an index of stencils to the page view… for now, later a redesign with stencil packs is needed…
@favorite_artifact_stencils
@free_artifact_stencils
@user_artifact_stencils

app/controllers/favorite_artifact_stencils_controller.rb → app/views/favorite_artifact_stencils/index.html.erb


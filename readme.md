## Gitlab Tools

### Setup Gitlab for etckeeper
Create a project/user to use with etckeeper. After you created an SSH key on the target server use it in the following CLI. It will create the project named after the server in the parent project group you specify. Use the parent group of the target project i.e. for all Sonar servers use the project_id of the Sonar group.

An external user named after the server_name will also be created. They will be granted `maintainer` access to the project so they can push to the repository from the server.

```
ruby project.rb API_TOKEN GITLAB_GROUP_ID SERVER_NAME "ROOT_SSH_KEY_ON_SERVER"
```

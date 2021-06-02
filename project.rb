require 'httparty'
require "awesome_print"
require 'cli/ui'
require 'byebug'


def post(url, data)
  response = HTTParty.post(url, body: data, headers: { 'PRIVATE-TOKEN' => @access_token })
  JSON.parse(response.body)
end

def get(url)
  response = HTTParty.get(url, { headers: { 'PRIVATE-TOKEN': @access_token } })
  JSON.parse(response.body)
end

def setup_gitlab
  project_id = create_project
  user_id = create_user(project_id)
  add_user_to_project(project_id, user_id)
  add_ssh_key(user_id)
end

def create_user(project_id)
  email_prefix = @email.split('@')[0]
  email_suffix = @email.split('@')[1]
  data = { email: "#{email_prefix}+#{@server_name}@#{email_suffix}", name: @server_name, username: @server_name , external: true, force_random_password: true}
  response = post("#{@base_url}/users", data)
  user_id = response['id']
  puts "Created user #{user_id}"
  user_id
end

def add_user_to_project(project_id, user_id)
  maintainer_access_level = 40
  data = { user_id: user_id, access_level: maintainer_access_level }
  post("#{@base_url}/projects/#{project_id}/members", data)
  puts "Added user to project"
end

def add_ssh_key(user_id)
  data = { title: @server_name, key: @ssh_key}
  post("#{@base_url}/users/#{user_id}/keys", data)
  puts "Added SSH key to user"
end

def create_project
  data = { namespace_id: @namespace_id, name: @server_name }
  response = post("#{@base_url}/projects", data)
  puts "Created Project with repo URL: #{response['ssh_url_to_repo']}"
  response['id']
end

def get_groupname
  response = get("#{@base_url}/groups/#{@namespace_id}")
  response['name']
end

def get_subprojects
  response = get("#{@base_url}/groups/#{@namespace_id}")
  group_projects = response['projects']
  project_names = []
  group_projects.each do |project|
    project_names << project['name']
  end

  project_names
end

if ARGV.length != 6
  puts "Input access_token namespace_id server_name ssh_key base_url and email"
  exit
end

@access_token = ARGV[0]
@namespace_id = ARGV[1]
@server_name = ARGV[2]
@ssh_key = ARGV[3]
@base_url = ARGV[4]
@email = ARGV[5]

subproject_list = get_subprojects.join(', ')

CLI::UI::Prompt.ask("Use Namespace #{get_groupname} with projects: #{subproject_list}?") do |handler|
  handler.option('y') { |selection| setup_gitlab }
  handler.option('n') { |selection| puts 'Goodbye' }
end

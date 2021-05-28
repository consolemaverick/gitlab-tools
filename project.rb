require 'httparty'
require "awesome_print"
require 'cli/ui'
require 'byebug'

def show_projects
  projects = HTTParty.get('https://gitlab.ekohe.com/api/v4/projects', @headers)
  ap(JSON.parse(projects.body))
end

def create_project(namespace_id)
  data = { namespace_id: namespace_id, name: 'test3' }.merge(@headers)
  puts data
  response = HTTParty.post("#{@base_url}/projects", body: data.to_json)
  ap response.body
end

if ARGV.length != 2
  puts "Input access_token followed by namespace_id"
  exit
end
access_token = ARGV[0]
@headers = { headers: { 'PRIVATE-TOKEN': access_token } }
namespace_id = ARGV[1]

@base_url = 'https://gitlab.ekohe.com/api/v4/'

response = HTTParty.get("#{@base_url}/groups/#{namespace_id}", @headers)
json_response = JSON.parse(response.body)

group_name = json_response['name']
group_projects = json_response['projects']
project_names = []
group_projects.each do |project|
  project_names << project['name']
end

CLI::UI::Prompt.ask("Use Namespace #{group_name} with projects: #{project_names.join(', ')}?") do |handler|
  handler.option('y') { |selection| create_project(namespace_id) }
  handler.option('n') { |selection| puts 'Goodbye' }
end

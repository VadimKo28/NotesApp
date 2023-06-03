require 'roda'
require 'sequel'
require 'json'

DB = Sequel.sqlite

DB.create_table? :notes do 
  primary_key :id
  String :name
  String :description
end


class App < Roda
  plugin :json
     
  route do |r|
    r.on "notes" do
      r.get do
        notes = DB[:notes].all
        { notes: notes }.to_json
      end
    end

    r.on "add_note" do 
      r.post do
        if request.env['HTTP_X_API_KEY'] != 'secret'
          response.status = 403
          response.write('Invalid API Key')
        else
          note_name = r.params['name']
          note_description = r.params['description']
            unless note_name && note_description
              response.status = 422
              response.write('Missing name or description')
            else
              note_id = DB[:notes].insert(name: note_name, description: note_description)
              { id: note_id }.to_json
            end
        end
      end
    end
  end
end

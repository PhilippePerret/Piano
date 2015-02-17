require "spec_helper"

describe "Test session #{relative_path __FILE__}" do
  
  describe "La session courante" do
    it 'existe' do
      expect(app.session).to_not eq(nil)
      expect(app.session).to be_instance_of App::Session
      expect(app.session.scgi).to be_instance_of CGI::Session
      session_id = app.session.id
      expect(session_id).to_not eq(nil)
    end
  end
  
end
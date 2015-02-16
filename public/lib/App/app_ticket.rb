# encoding: UTF-8
=begin

  Méthodes d'instance de traitement d'un ticket

=end
class App
  
  def traite_ticket_if_any
    ticket_id = param('ti').to_s
    protection_ticket = param('tp').to_s
    return if ticket_id == "" || protection_ticket == ""
    require_module 'tickets'
    Ticket::new(ticket_id).treate protection_ticket.to_i
  end
  
  ##
  #
  # Crée un nouveau ticket et retourne l'instance App::Ticket
  #
  def new_ticket_with_code code
    require_module 'tickets'
    ticket = App::Ticket::new
    ticket.create_with_code code
    return ticket
  end
end
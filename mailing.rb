# encoding: UTF-8
# frozen_string_literal: true
=begin

  Appeler ce module dans un module définissant :

  MAILS     : la liste Array des adresses email
  DATA_MAIL : les données du mail à envoyer (cf. manuel)

=end

DELAI_ENTRE_MESSAGES = 30 unless defined?(DELAI_ENTRE_MESSAGES)

require_relative 'lib/Mail'

mail = Mail.new(DATA_MAIL)

MAILS.each do |email|
  mail.to = email
  mail.deliver
  sleep DELAI_ENTRE_MESSAGES
end

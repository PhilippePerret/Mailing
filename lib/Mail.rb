# encoding: UTF-8
# frozen_string_literal: true
=begin
  
  Pour la construction et l'envoi de messages

=end
require 'net/smtp'

class Mail
class << self

def smtp_data
  @data ||= begin
    require File.join(Dir.home,'.secret','mail.rb')
    MAILS_DATA[:smtp]
  end
end

## 
# Pour envoyer le mail +mail+ (instance Mail)
def send(mail)
  Net::SMTP.start(
    smtp_data[:server], 
    smtp_data[:port], 
    smtp_data[:domain], 
    smtp_data[:user_name], 
    smtp_data[:password]
    ) do |smtp|
    begin
      # puts "Message à déliver : <<<<<<<\n#{mail.content}\n>>>>>>>>>>>\n\n"
      smtp.send_message( mail.content, mail.from, mail.to)
    rescue Net::SMTPSyntaxError => e
      puts "ERREUR DE SYNTAXE : #{e.message}"
    end
  end
end

end #/<<self


# --- INSTANCE ---

attr_reader :data
def initialize(data)
  @data = data  
end

##
# Pour envoyer le mail
def deliver
  self.class.send(self)
end

def to=(destinataire)
  @to = destinataire
end
def to
  @to ||= data[:to]||data[:destinataire]
end

def from;     @from     ||= data[:from]     end

##
# Le sujet du mail
# ----------------
# S'il n'est pas défini explicitement dans les data, et que le
# message est un fichier markdown, il est alors défini dans les 
# métadonnées, avec le titre subject:
# 
def subject
  @subject ||= begin
    data[:subject] || begin
      message # retirera le titre s'il est défini
      (@metadata||{})['subject']
    end
  end
end

##
# Le message
# ----------
# La donnée :message peut être de 3 natures :
#   1. le code HTML du message
#   2. un chemin d'accès à un fichier HTML ou TEXT
#   3. un chemin d'accès à un fichier Markdown
# 
def message
  @message ||= begin
    mc = data[:message]  
    if File.exist?(mc)
      # 
      # C'est un chemin d'accès à un fichier. Si c'est un fichier
      # markdown, on le traduit en HTML. Sinon, on le prend tel quel.
      # 
      is_markdown_file = ['.md','.mmd','.markdown'].include?(File.extname(mc).downcase)
      mc = File.read(mc).force_encoding('utf-8')
      if is_markdown_file
        require 'kramdown'
        if mc =~ /\A---/
          preamble  = mc[/\A---.*?^---/m]
          mc        = mc[preamble.size..-1]
          @metadata = YAML.load(preamble)
        end
        mc = Kramdown::Document.new(mc).to_html
      end
    end
    mc
  end
end

def attachments
  @attachments ||= begin
    if data.key?(:attachment) && not(data.key?(:attachments))
      [ data[:attachment] ]
    else
      data[:attachments] || []
    end
  end
end

##
# Le contenu complet, avec entête et tout le tintouin
def content
  <<-MAILCONTENT
From: #{from}
To: #{to}
Subject: #{subject}
Date: #{Time.now}
MIME-Version: 1.0
Content-type: #{content_type}
#{full_content_with_attachments}
  MAILCONTENT
end


##
# Retourne le contenu, avec les fichiers attachés s'il y en a
#
def full_content_with_attachments
  if attachment?
    #
    # Des fichiers joints, il faut composer le contenu avec 
    # multiparties
    #
    c = []
    c << "--#{boundary}"
    c << "Content-Type: text/html"
    c << "Content-Transfer-Encoding:8bit"
    c << ""
    c << message
    c << "--#{boundary}"
    attachments.each do |attachment|
      if attachment.is_a?(String)
        # <= le chemin d'accès seul
        #  => On en tire les données
        dfile = {name: File.basename(attachment), path: attachment}
      elsif attachment.is_a?(Hash)
        # <= Une table de données
        #  => On prend ce qu'il faut
        dfile = attachment
      end
      c << "Content-Type: #{attachment_content_type_for(dfile[:path])}; name = \"#{dfile[:name]}\""
      c << "Content-Transfer-Encoding:base64"
      c << "Content-Disposition: attachment; filename = \"#{dfile[:name]}\""
      c << ""
      c << [File.read(dfile[:path])].pack('m')
      c << "--#{boundary}"
    end
    #
    # On ajoute le dernier '--'
    #
    c[-1] = "#{c.last}--"

    c.join("\r\n")
  else
    #
    # Pas de fichier joint => on n'envoie le message tel quel
    #
    "\n#{message}"
  end
end

##
# Retourne le content-type pour le fichier joint +joint+
#
def attachment_content_type_for(joint)
  case File.extname(joint).downcase
  when '.txt'      then 'text/plain'
  when '.html'     then 'plain/html'
  when '.pdf'      then 'application/octet-stream' #'application/x-pdf'
  when '.jpg', '.jpeg' then 'image/jpeg'
  when '.png'      then 'image/png'
  when '.gif'      then 'image/gif'
  when '.doc', '.docx' then 'application/msword'
  else 
    'plain/text' # par défaut
  end
end

##
# Retourne le type de contenu en fonction du fait qu'il y a ou non
# des fichiers joints
# 
def content_type
  @content_type ||= begin
    if attachment?
      "multipart/mixed; boundary = #{boundary}"
    else
      "text/html"
    end
  end
end

def attachment?
  attachments.count > 0
end

##
# Quand il y a des fichiers joints, il faut définir une frontière
#
def boundary
  @boundary ||= "UNIQUE#{Time.now.to_i}BOUNDARY"
end

end #/Mail

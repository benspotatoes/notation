class ReadEntry < ActiveRecord::Base
  attr_accessor :user_id, :body, :tags, :title

  belongs_to :entry, foreign_key: :entry_primary_id

  has_attached_file :attachment,
                    storage: :s3,
                    s3_credentials: Proc.new { |cred| cred.instance.s3_credentials },
                    default_url: '',
                    path: '/:class/:attachment/:token-:filename'

  before_save :check_for_minimum_requirements
  before_create :set_entry_details
  before_create :generate_paperclip_token

  validates_attachment_content_type :attachment, content_type: ['application/pdf']

  def attachment_url
    attachment.try(:url)
  end

  def check_for_minimum_requirements
    if !url.empty?
      self.attachment = nil
      set_url_details
    elsif attachment.file?
      self.url = nil
    end
  end

  def set_url_details
    page = AGENT.get(url)

    if entry.nil?
      self.title = page.title
    else
      entry.update_attribute(:title, page.title)
    end
    self.host = page.uri.host
  end

  def set_entry_details
    entry = Entry.new(user_id: user_id, title: title, entry_type: 3)

    if body
      entry.body = body
    end

    if tags
      entry.tags = tags
    end

    entry.save!
    self.entry_primary_id = entry.id
  end

  def public_id
    entry.public_id
  end

  def s3_credentials
    if Rails.env.development?
      {
        bucket: S3_BUCKET_NAME,
        access_key_id: AWS_ACCESS_KEY_ID,
        secret_access_key: AWS_SECRET_ACCESS_KEY
      }
    else
      {
        bucket: ENV['S3_BUCKET_NAME'],
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      }
    end
  end

  private
    def generate_paperclip_token
      self.token = Digest::SHA1.hexdigest("#{SecureRandom.hex(16)}#{Time.now.to_i}")
    end

    Paperclip.interpolates :token do |resource, style|
      resource.instance.token
    end
end

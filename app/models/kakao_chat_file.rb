# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

require 'shellwords'

class KakaoChatFile < ApplicationModel
  include ApplicationModel::CanAssets

  belongs_to :session, class_name: 'KakaoConsultationSession', foreign_key: 'session_id'
  belongs_to :message, class_name: 'KakaoConsultationMessage', foreign_key: 'message_id', optional: true
  belongs_to :uploaded_by, class_name: 'User', foreign_key: 'uploaded_by_id', optional: true

  validates :filename, presence: true
  validates :content_type, presence: true
  validates :file_size, presence: true, numericality: { greater_than: 0 }
  validates :storage_path, presence: true

  # 카카오 상담톡 송신 가능한 파일 목록
  # 일반적인 파일 확장자 : pdf, odp, ppt, pptx, key, show, doc, docx, hwp, txt, rtf, xml, wks, wps, xps, md, odf, odt, pages, ods, csv, tsv, xls,
  #                     xlsx, numbers, cell, psd, ai, sketch, tif, tiff, tga, webp, zip, gz, bz2, rar, 7z, lzh, alz
  # 이미지 파일 확장자 : jpg, jpeg, gif, bmp, png, tiff
  # 비디오 파일 확장자 : mp4, m4v, avi, asf, wmv, mkv, ts, mpg, mpeg, mov, flv, ogv
  # 오디오 파일 확장자 : mp3, wav, flac, tta, tak, aac, wma, ogg, m4a  

  # 파일 타입 분류
  CONTENT_TYPE_CATEGORIES = {
    image: %w[
      image/jpeg image/jpg image/png image/gif image/bmp image/webp image/svg+xml
      image/tiff image/tga
    ],
    video: %w[
      video/mp4 video/m4v video/avi video/x-msvideo video/wmv video/x-ms-wmv
      video/mkv video/webm video/flv video/x-flv video/quicktime video/mov
      video/mpeg video/mpg video/x-mpeg video/mp2t video/vnd.dlna.mpeg-tts
      video/ogg video/ogv application/x-shockwave-flash
    ],
    audio: %w[
      audio/mp3 audio/mpeg audio/wav audio/wave audio/x-wav audio/flac
      audio/x-flac audio/aac audio/mp4 audio/m4a audio/wma audio/x-ms-wma
      audio/ogg audio/tta audio/tak
    ],
    document: %w[
      application/pdf text/plain text/rtf text/xml text/markdown text/csv
      application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
      application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
      application/vnd.ms-powerpoint application/vnd.openxmlformats-officedocument.presentationml.presentation
      application/vnd.oasis.opendocument.text application/vnd.oasis.opendocument.spreadsheet
      application/vnd.oasis.opendocument.presentation application/vnd.oasis.opendocument.formula
      application/vnd.ms-works application/vnd.ms-xpsdocument
      application/vnd.apple.keynote application/vnd.apple.pages application/vnd.apple.numbers
      application/x-hwp application/haansofthwp application/vnd.hancom.hwp
      application/octet-stream application/json application/xml
      image/vnd.adobe.photoshop application/postscript
    ],
    archive: %w[
      application/zip application/x-zip-compressed application/gzip application/x-gzip
      application/x-bzip2 application/x-rar-compressed application/vnd.rar
      application/x-7z-compressed application/x-lzh-compressed application/x-alz-compressed
    ],
    other: %w[
      application/octet-stream text/csv application/json application/xml text/html
      application/vnd.ms-fontobject font/woff font/woff2 application/font-woff
    ]
  }.freeze

  # 최대 파일 크기 (10MB)
  MAX_FILE_SIZE = 10.megabytes

  # 허용된 파일 확장자 (카카오톡 지원 파일 기준)
  ALLOWED_EXTENSIONS = %w[
    jpg jpeg gif bmp png tiff tif tga webp
    mp4 m4v avi asf wmv mkv ts mpg mpeg mov flv ogv
    mp3 wav flac tta tak aac wma ogg m4a
    pdf odp ppt pptx key show doc docx hwp txt rtf xml wks wps xps md 
    odf odt pages ods csv tsv xls xlsx numbers cell psd ai sketch
    zip gz bz2 rar 7z lzh alz
  ].freeze

  before_validation :set_defaults
  before_destroy :remove_physical_file

  scope :images, -> { where(content_type: CONTENT_TYPE_CATEGORIES[:image]) }
  scope :videos, -> { where(content_type: CONTENT_TYPE_CATEGORIES[:video]) }
  scope :documents, -> { where(content_type: CONTENT_TYPE_CATEGORIES[:document]) }

  def file_category
    CONTENT_TYPE_CATEGORIES.each do |category, types|
      return category if types.include?(content_type)
    end
    :other
  end

  def image?
    file_category == :image
  end

  def video?
    file_category == :video
  end

  def audio?
    file_category == :audio
  end

  def document?
    file_category == :document
  end

  def extension
    File.extname(filename).downcase.delete('.')
  end

  def file_size_human
    ActionController::Base.helpers.number_to_human_size(file_size)
  end

  def full_storage_path
    Rails.root.join('storage', 'kakao_chat', storage_path)
  end

  def exists?
    File.exist?(full_storage_path)
  end

  def read_file
    return nil unless exists?
    File.read(full_storage_path)
  end

  # 썸네일 생성 (이미지 파일만) - ImageMagick CLI 방식
  def generate_thumbnail(size = '150x150')
    return nil unless image? && exists?
    
    # ImageMagick CLI 사용 가능 여부 확인
    unless command_available?('convert')
      Rails.logger.warn "ImageMagick not available - thumbnail generation skipped"
      return nil
    end
    
    thumbnail_path = Rails.root.join('storage', 'kakao_chat', 'thumbnails', "#{id}_#{size}.jpg")
    
    # 썸네일 디렉토리 생성
    FileUtils.mkdir_p(File.dirname(thumbnail_path))
    
    # 이미 존재하면 반환
    return File.read(thumbnail_path) if File.exist?(thumbnail_path)
    
    # ImageMagick CLI로 썸네일 생성
    begin
      input_path = full_storage_path.to_s.shellescape
      output_path = thumbnail_path.to_s.shellescape
      
      # ImageMagick convert 명령어 실행
      command = "convert #{input_path} -resize #{size} -quality 85 #{output_path}"
      
      success = system(command)
      
      if success && File.exist?(thumbnail_path)
        File.read(thumbnail_path)
      else
        Rails.logger.error "Failed to generate thumbnail for file #{id}: ImageMagick convert command failed"
        nil
      end
    rescue => e
      Rails.logger.error "Failed to generate thumbnail for file #{id}: #{e.message}"
      nil
    end
  end

  # URL 생성
  def download_url
    Rails.application.routes.url_helpers.url_for(
      controller: 'kakao_chat',
      action: 'download_file',
      file_id: id,
      only_path: true
    )
  rescue
    "/api/v1/kakao_chat/files/#{id}"
  end

  def preview_url
    Rails.application.routes.url_helpers.url_for(
      controller: 'kakao_chat',
      action: 'preview_file',
      file_id: id,
      only_path: true
    )
  rescue
    "/api/v1/kakao_chat/files/#{id}/preview"
  end

  def thumbnail_url
    return nil unless image?
    Rails.application.routes.url_helpers.url_for(
      controller: 'kakao_chat',
      action: 'file_thumbnail',
      file_id: id,
      only_path: true
    )
  rescue
    "/api/v1/kakao_chat/files/#{id}/thumbnail"
  end

  private

  def command_available?(command)
    system("which #{command.shellescape} > /dev/null 2>&1")
  end

  def set_defaults
    if filename.present?
      self.original_filename ||= filename
    end
    
    if content_type.blank? && filename.present?
      self.content_type = Marcel::MimeType.for(Pathname.new(filename))
    end
  end

  def remove_physical_file
    return unless storage_path.present?
    
    # 원본 파일 삭제
    file_path = full_storage_path
    File.delete(file_path) if File.exist?(file_path)
    
    # 썸네일 삭제
    thumbnail_dir = Rails.root.join('storage', 'kakao_chat', 'thumbnails')
    Dir.glob("#{thumbnail_dir}/#{id}_*.jpg").each do |thumbnail_file|
      File.delete(thumbnail_file) if File.exist?(thumbnail_file)
    end
  rescue => e
    Rails.logger.error "Failed to remove file #{id}: #{e.message}"
  end
end

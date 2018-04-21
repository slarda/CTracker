class GameLink < ActiveRecord::Base

  enum kind: {unknown: 0, photos: 1, video: 2, video_youtube: 3, video_vimeo: 4, video_facebook: 5}

  belongs_to :linked_to, polymorphic: true
  belongs_to :user

end
